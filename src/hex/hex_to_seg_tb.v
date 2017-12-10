module hex_to_seg_tb;
    reg [3:0] hex_digit;
    wire [6:0] seg;

    hex_to_seg u_hex_to_seg (
        .hex_digit  (hex_digit),
        .seg        (seg)
    );

    integer i;

    initial
    begin
        $dumpfile ("src/hex/hex_to_seg_tb.vcd");
        $dumpvars;
        for (i = 0; i < 17; i = i + 1) begin
            #10
            hex_digit = i;
        end
    end
endmodule
