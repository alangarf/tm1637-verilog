module tm1637_tb;
    reg clk, rst;

    reg [7:0] data_byte;
    reg data_latch, data_stop_bit;

    wire busy, scl_en, scl_out, sda_en, sda_out;
    reg sda_in;

    wire [3:0] cur_state;
    wire [3:0] next_state;

    tm1637 u_tm1637 (
        .clk            (clk),
        .rst            (rst),
        .data_latch     (data_latch),
        .data_byte      (data_byte),
        .data_stop_bit  (data_stop_bit),
        .busy           (busy),
        .scl_en         (scl_en),
        .scl_out        (scl_out),
        .sda_en         (sda_en),
        .sda_out        (sda_out),
        .sda_in         (sda_in)
    );

    initial
    begin
        $dumpfile ("src/tm1637/tm1637_tb.vcd");
        $dumpvars;
        clk = 0;
        rst = 0;
        data_byte = 0;
        data_latch = 0;
        data_stop_bit = 0;
        sda_in = 0;
        #10000
        // trigger reset
        rst = 1;
        #50
        rst = 0;
        #10000
        // send data command
        data_byte = 8'b01000000;
        data_stop_bit = 1;
        data_latch = 1;
        #10
        data_latch = 0;
        #80000
        // send location command
        data_byte = 8'b11000000;
        data_stop_bit = 0;
        data_latch = 1;
        #10
        data_latch = 0;
        #80000
        // send '1'
        data_byte = 8'b00000110;
        data_latch = 1;
        #10
        data_latch = 0;
        #80000
        // send '2'
        data_byte = 8'b01011011;
        data_latch = 1;
        #10
        data_latch = 0;
        #80000
        // send '3'
        data_byte = 8'b01001111;
        data_latch = 1;
        #10
        data_latch = 0;
        #80000
        // send '4'
        data_byte = 8'b01100110;
        data_stop_bit = 1;
        data_latch = 1;
        #10
        data_latch = 0;
        #80000
        // send display command
        data_byte = 8'b10001111;
        data_stop_bit = 1;
        data_latch = 1;
        #10
        data_latch = 0;

        #300000
        $finish;
    end

    always @(posedge clk)
    begin
        ;
    end

    always
        #5 clk = !clk;

endmodule
