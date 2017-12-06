module tm1637(
    input clk,
    input rst,

    input data_latch,
    input [7:0] data_byte,
    input data_stop_bit,
    output busy,

    output scl_en,
    output scl_out,
    input scl_in,

    output sda_en,
    output sda_out,
    input sda_in,
    );

    reg [7:0] write_byte;
    reg [3:0] write_bit_count;
    reg write_stop_bit;

    reg [4:0] state;
    reg [4:0] next_state;

    reg [15:0] wait_count;

    localparam [9:0] wait_time = 512; // at 12MHz that's about 47uS

    localparam [4:0]
        S_IDLE=0,
        S_WAIT=1,
        S_WAIT1=2,
        S_START=3,
        S_WRITE=4,
        S_WRITE1=5,
        S_WRITE2=6,
        S_WRITE3=7,
        S_ACK=8,
        S_ACK1=9,
        S_ACK2=10,
        S_STOP=11,
        S_STOP1=12,
        S_STOP2=13,
        S_STOP3=14;

    always @(posedge clk) begin
        if (rst) begin
            // out is set low so enable is used to pull lines low.
            // pull ups on pins will pull high.
            scl_out <= 0;
            sda_out <= 0;

            // output disabled, so lines pulled high
            scl_en <= 0;
            sda_en <= 0;

            // set up FSM
            state = S_IDLE;
            next_state = S_IDLE;

            wait_count <= 0;
            write_bit_count <= 0;

            // reset busy flag
            busy <= 0;

        end else begin
            if (data_latch) begin
                // segments have been latch
                write_byte <= data_byte;
                write_stop_bit <= data_stop_bit;

                state = S_START;
                busy <= 1;

            end else begin  
                case (state)
                    S_IDLE: begin
                        // idle waiting for a latch
                        scl_en <= 0;
                        sda_en <= 0;
                        busy <= 0;
                    end

                    S_WAIT: begin
                        // setting up for a wait
                        wait_count <= 0;
                        state = S_WAIT1;
                    end

                    S_WAIT1: begin
                        // watching the counter till our wait is over
                        wait_count <= wait_count + 1;

                        if (wait_count == wait_time)
                            state = next_state;
                    end

                    S_START: begin
                        // send the start signal to the bus, then wait
                        sda_en <= 1;

                        state = S_WAIT;
                        next_state = S_WRITE;
                    end

                    S_WRITE: begin
                        // tick the clock
                        scl_en <= 1;

                        // reset the bit counts
                        write_bit_count <= 0;

                        state = S_WAIT;
                        next_state = S_WRITE1;
                    end

                    S_WRITE1:begin
                        // write a bit
                        // 1 to drive bus to low
                        // 0 to HiZ the bus and let pull up do the work
                        sda_en <= ~write_byte[write_bit_count];

                        state = S_WAIT;
                        next_state = S_WRITE2;
                    end

                    S_WRITE2: begin
                        // tock the clock
                        scl_en <= 0;

                        state = S_WAIT;
                        next_state = S_WRITE3;
                    end

                    S_WRITE3: begin
                        if (write_bit_count <= 4'd7) begin
                            // tick the clock for the next bit
                            scl_en <= 1;

                            // advance the counter and send next bit
                            write_bit_count <= write_bit_count + 1;
                            state = S_WRITE1;

                        end else begin
                            // all bits sent, tock the clock
                            scl_en <= 0;

                            state = S_WAIT;
                            next_state = S_ACK;
                        end
                    end

                    S_ACK: begin
                        // check the display acknowledged
                        scl_en <= 1;
                        sda_en <= 0;

                        state = S_WAIT;
                        next_state = S_ACK1;
                    end

                    S_ACK1: begin
                        // tock the clock
                        scl_en <= 0;

                        state = S_WAIT;
                        next_state = S_ACK2;
                    end

                    S_ACK2: begin
                        // listen for the ack and ack back
                        if (sda_in == 0)
                            sda_en <= 1;

                        state = S_WAIT;
                        next_state = write_stop_bit ? S_STOP : S_IDLE;    
                    end

                    S_STOP: begin
                        // send stop signal
                        scl_en <= 1;

                        state = S_WAIT;
                        next_state = S_STOP1;    
                    end

                    S_STOP1: begin
                        sda_en <= 1;

                        state = S_WAIT;
                        next_state = S_STOP2;    
                    end

                    S_STOP2: begin
                        scl_en <= 0;

                        state = S_WAIT;
                        next_state = S_STOP3;
                    end

                    S_STOP3: begin
                        sda_en <= 0;

                        state = S_WAIT;
                        next_state = S_IDLE;
                    end
                endcase
            end
        end
    end
endmodule
