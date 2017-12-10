module tm1637(
    clk,
    rst,
    data_latch,
    data_in,
    data_stop_bit,
    busy,
    scl_en,
    scl_out,
    sda_en,
    sda_out,
    sda_in
    );

    input clk;
    input rst;
    input data_latch;
    input [7:0] data_in;
    input data_stop_bit;
    input sda_in;

    output reg busy;
    output reg scl_en;
    output reg scl_out;
    output reg sda_en;
    output reg sda_out;

    reg [7:0] write_byte;
    reg [2:0] write_bit_count;
    reg write_stop_bit;

    reg [3:0] cur_state;
    reg [3:0] next_state;

    reg [9:0] wait_count;
    localparam [9:0] wait_time = 256; // at 12MHz that's about 47uS

    localparam [3:0]
        S_IDLE      = 4'h0,
        S_WAIT      = 4'h1,
        S_WAIT1     = 4'h2,
        S_START     = 4'h3,
        S_WRITE     = 4'h4,
        S_WRITE1    = 4'h5,
        S_WRITE2    = 4'h6,
        S_WRITE3    = 4'h7,
        S_ACK       = 4'h8,
        S_ACK1      = 4'h9,
        S_ACK2      = 4'hA,
        S_STOP      = 4'hB,
        S_STOP1     = 4'hC,
        S_STOP2     = 4'hD,
        S_STOP3     = 4'hE;

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
            cur_state <= S_IDLE;
            next_state <= S_IDLE;

            wait_count <= 0;
            write_bit_count <= 0;

            // reset busy flag
            busy <= 0;

        end else begin
            if (data_latch) begin
                // data has been latch
                write_byte <= data_in;
                write_stop_bit <= data_stop_bit;

                // let's rock!
                cur_state <= S_START;
                busy <= 1;

            end else begin
                case (cur_state)
                    S_IDLE: begin
                        // idle waiting for a latch
                        scl_en <= 0;
                        sda_en <= 0;
                        busy <= 0;
                    end

                    S_WAIT: begin
                        // setting up for a wait
                        wait_count <= 0;
                        cur_state <= S_WAIT1;
                    end

                    S_WAIT1: begin
                        // watching the counter till our wait is over
                        wait_count <= wait_count + 1;

                        if (wait_count == wait_time)
                            cur_state <= next_state;
                    end

                    S_START: begin
                        // send the start signal to the bus, then wait
                        sda_en <= 1;

                        cur_state <= S_WAIT;
                        next_state <= S_WRITE;
                    end

                    S_WRITE: begin
                        // tick the clock
                        scl_en <= 1;

                        // reset the bit counts
                        write_bit_count <= 0;

                        cur_state <= S_WAIT;
                        next_state <= S_WRITE1;
                    end

                    S_WRITE1:begin
                        // write a bit
                        // 1 to drive bus to low
                        // 0 to HiZ the bus and let pull up do the work
                        sda_en <= ~write_byte[write_bit_count];

                        cur_state <= S_WAIT;
                        next_state <= S_WRITE2;
                    end

                    S_WRITE2: begin
                        // tock the clock
                        scl_en <= 0;

                        cur_state <= S_WAIT;
                        next_state <= S_WRITE3;
                    end

                    S_WRITE3: begin
                        if (write_bit_count != 7) begin
                            // advance the bit counter
                            write_bit_count <= write_bit_count + 1;

                            // tick the clock for the next bit
                            scl_en <= 1;
                            cur_state <= S_WRITE1;

                        end else begin
                            // all bits sent, tock the clock
                            scl_en <= 0;

                            cur_state <= S_WAIT;
                            next_state <= S_ACK;
                        end
                    end

                    S_ACK: begin
                        // check the display acknowledged
                        scl_en <= 1;
                        sda_en <= 0;

                        cur_state <= S_WAIT;
                        next_state <= S_ACK1;
                    end

                    S_ACK1: begin
                        // tock the clock
                        scl_en <= 0;

                        cur_state <= S_WAIT;
                        next_state <= S_ACK2;
                    end

                    S_ACK2: begin
                        // listen for the ack and ack back
                        if (sda_in == 0)
                            sda_en <= 1;

                        cur_state <= S_WAIT;
                        next_state <= write_stop_bit ? S_STOP : S_IDLE;
                    end

                    S_STOP: begin
                        // send stop signal
                        scl_en <= 1;

                        cur_state <= S_WAIT;
                        next_state <= S_STOP1;
                    end

                    S_STOP1: begin
                        sda_en <= 1;

                        cur_state <= S_WAIT;
                        next_state <= S_STOP2;
                    end

                    S_STOP2: begin
                        scl_en <= 0;

                        cur_state <= S_WAIT;
                        next_state <= S_STOP3;
                    end

                    S_STOP3: begin
                        sda_en <= 0;

                        cur_state <= S_WAIT;
                        next_state <= S_IDLE;
                    end

                    default: begin
                        cur_state <= S_IDLE;
                    end
                endcase
            end
        end
    end
endmodule
