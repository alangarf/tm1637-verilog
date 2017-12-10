module bcd_tb;
    reg [13:0] number;
    wire [3:0] thousands;
    wire [3:0] hundreds;
    wire [3:0] tens;
    wire [3:0] ones;

    bcd u_bcd (
        .number     (number),
        .thousands  (thousands),
        .hundreds   (hundreds),
        .tens       (tens),
        .ones       (ones)
    );

    integer i;

    initial
    begin
        $dumpfile ("src/decimal/bcd_tb.vcd");
        $dumpvars;
        for (i = 5; i < 15; i = i + 1) begin
            #1
            number = i;
        end
        for (i = 95; i < 105; i = i + 1) begin
            #1
            number = i;
        end
        for (i = 995; i < 1005; i = i + 1) begin
            #1
            number = i;
        end
        for (i = 9995; i <= 9999; i = i + 1) begin
            #1
            number = i;
        end
        #10
        number = 0;
    end
endmodule
