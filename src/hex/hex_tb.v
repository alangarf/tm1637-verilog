module hex_tb;
    reg clk, rst;

    reg [15:0] data_in;
    reg data_latch;

    wire busy, tm_busy, scl_en, scl_out, sda_en, sda_out;
    reg sda_in;

    hex u_hex (
        .clk        (clk),
        .rst        (rst),
        .data_latch (data_latch),
        .data_in    (data_in),
        .busy       (busy),
        .scl_en     (scl_en),
        .scl_out    (scl_out),
        .sda_en     (sda_en),
        .sda_out    (sda_out),
        .sda_in     (sda_in),
        .tm_busy    (tm_busy)
    );

    initial
    begin
        $dumpfile ("src/hex/hex_tb.vcd");
        $dumpvars;
        clk = 0;
        rst = 0;
        data_latch = 0;
        data_in = 0;
        sda_in = 0;
        #10000
        // trigger reset
        rst = 1;
        #50
        rst = 0;
        #50
        data_in = 16'hBEEF;
        data_latch = 1;
        #50
        data_latch = 0;

        #450000
        $finish;
    end

    always @(posedge clk)
    begin
        ;
    end

    always
        #5 clk = !clk;

endmodule
