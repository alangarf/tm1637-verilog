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
    reg data_latch;
    reg [15:0] data_in;
    reg busy;

    decimal u_decimal (
        clk,
        rst,

        data_latch,
        data_in,
        busy,

        scl_en,
        scl_out,
        sda_en,
        sda_out,
        sda_in
    );

    reg [15:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            data_in <= 0;

            rst <= 0;

        end else if (counter == 0 && !busy) begin
            data_in <= data_in + 1;
            data_latch <= 1;

        end else begin
            data_latch <= 0;

        end

        counter <= counter + 1;

        leds <= data_in[7:0];
    end

endmodule
