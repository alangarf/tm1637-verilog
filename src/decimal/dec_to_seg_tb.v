module dec_to_seg_tb;
    reg [3:0] dec_digit;
    wire [6:0] seg;

    dec_to_seg u_dec_to_seg (
        .dec_digit  (dec_digit),
        .seg        (seg)
    );

    integer i;

    initial
    begin
        $dumpfile ("src/decimal/dec_to_seg_tb.vcd");
        $dumpvars;
        for (i = 0; i <= 12; i = i + 1) begin
            #10
            dec_digit = i;
        end
    end
endmodule
