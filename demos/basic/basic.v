module top(
    input clk,
    inout tm_scl,
    inout tm_sda,
    output led0,
    output led1,
    output led2,
    output led3,
    output led4,
    output led5,
    output led6,
    output led7
    );

    // setup reset and counter registers
    reg rst = 1;
    reg [18:0] counter;
    reg [7:0] instruction_step;

    // set up tm1637 i2c-like bus
    // yosys has issues doing tristate the usual way
    // so have to define the SB_IO block manually
    reg scl_en;
    reg scl_out;
    SB_IO #(
        .PIN_TYPE(6'b101001),
        .PULLUP(1'b 0)
    ) tm_scl_io (
        .PACKAGE_PIN(tm_scl),
        .OUTPUT_ENABLE(scl_en),
        .D_OUT_0(scl_out)
    );

    reg sda_en;
    reg sda_out;
    reg sda_in;
    SB_IO #(
        .PIN_TYPE(6'b101001),
        .PULLUP(1'b 0)
    ) tm_sda_io (
        .PACKAGE_PIN(tm_sda),
        .OUTPUT_ENABLE(sda_en),
        .D_OUT_0(sda_out),
        .D_IN_0(sda_in)
    );

    // setup led outputs on dev board
    reg [7:0] leds;
    assign led0 = leds[0];
    assign led1 = leds[1];
    assign led2 = leds[2];
    assign led3 = leds[3];
    assign led4 = leds[4];
    assign led5 = leds[5];
    assign led6 = leds[6];
    assign led7 = leds[7];

    // setup the tm1637 module and registers
    reg tm_latch;
    reg [7:0] tm_byte;
    reg tm_stop_bit;
    reg tm_busy;

    tm1637 disp (
        clk,
        rst,

        tm_latch,
        tm_byte,
        tm_stop_bit,
        tm_busy,

        scl_en,
        scl_out,
        sda_en,
        sda_out,
        sda_in
    );

    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            instruction_step <= 0;

            tm_latch <= 0;
            tm_byte <= 0;
            tm_stop_bit <= 0;

            rst <= 0;

        end else begin
            if (counter == 0 && tm_busy == 0 && instruction_step < 11) begin
                case (instruction_step)
                    4: begin
                        // | 0 | 1 | x | x | N | I | W | 0 |
                        // N = Normal mode (0), I = Address increment (0),
                        // W = Write (0)
                        tm_byte <= 8'b01000000;
                        tm_stop_bit <= 1;
                        tm_latch <= 1;
                    end
                    5: begin
                        // | 1 | 1 | x | x | 0 | 0 | U | L |
                        // U = upper addr, L = lower addr
                        tm_byte <= 8'b11000000;
                        tm_stop_bit <= 0;
                        tm_latch <= 1;
                    end
                    6: begin
                        // write '1'
                        tm_byte <= 8'b00000110;
                        tm_stop_bit <= 0;
                        tm_latch <= 1;
                    end
                    7: begin
                        // write '2'
                        tm_byte <= 8'b01011011;
                        tm_stop_bit <= 0;
                        tm_latch <= 1;
                    end
                    8: begin
                        // write '3'
                        tm_byte <= 8'b01001111;
                        tm_stop_bit <= 0;
                        tm_latch <= 1;
                    end
                    9: begin
                        // write '4'
                        tm_byte <= 8'b01100110;
                        tm_stop_bit <= 1;
                        tm_latch <= 1;
                    end
                    10: begin
                        // | 1 | 0 | x | x | D | U | M | L |
                        // D = Display on/off, U = upper brightness bit,
                        // M = mid brightness bit, L = low brightness bit
                        tm_byte <= 8'b10001111;
                        tm_stop_bit <= 1;
                        tm_latch <= 1;
                    end
                endcase
                    
                instruction_step <= instruction_step + 1;

            end else if (tm_busy == 1) begin
                tm_latch <= 0;
            end

            counter <= counter + 1;

            // output the busy flag
            leds[7] <= tm_busy;
            leds[6:0] <= tm_byte[6:0];
        end
    end

endmodule
