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
    reg hex_latch;
    reg [15:0] hex_data;
    reg hex_busy;
    reg [7:0] debug;

    tm1637_hex hex_disp (
        clk,
        rst,

        hex_latch,
        hex_data,
        hex_busy,

        scl_en,
        scl_out,
        sda_en,
        sda_out,
        sda_in,

        debug
    );

    reg [4:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            hex_data <= 0;

            rst <= 0;

        end else if (counter == 0 && !hex_busy) begin
            hex_data <= hex_data + 1;
            hex_latch <= 1;

        end else begin
            hex_latch <= 0;

        end

        counter <= counter + 1;

        leds <= debug;
    end

endmodule
