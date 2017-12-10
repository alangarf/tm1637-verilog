module decimal(
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

    input clk;
    input rst;
    input data_latch;
    input [13:0] data_in;
    input sda_in;

    output reg busy;
    output wire scl_en;
    output wire scl_out;
    output wire sda_en;
    output wire sda_out;

    // convert binary to bcd
    reg [3:0] thousands;
    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] ones;

    bcd u_bcd (
        data_in,
        thousands,
        hundreds,
        tens,
        ones
    );

    // take dec to digits
    reg [3:0] dec_in;
    wire [6:0] seg_out;

    dec_to_seg u_dec_to_seg (
        dec_in,
        seg_out
    );

    // setup the tm1637 module and registers
    reg [7:0] tm_byte;
    reg tm_latch;
    reg tm_stop_bit;
    wire tm_busy;

    tm1637 u_tm1637 (
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

    localparam [3:0]
        S_IDLE          = 4'h0,
        S_DATAMODE      = 4'h1,
        S_LOCATION      = 4'h2,
        S_WRITE_HEX0    = 4'h3,
        S_WRITE_HEX1    = 4'h4,
        S_WRITE_HEX2    = 4'h5,
        S_WRITE_HEX3    = 4'h6,
        S_DISPLAY       = 4'h7,
        S_LATCH         = 4'h8;

    reg [3:0] cur_state;
    reg [3:0] next_state;

    always @(posedge clk) begin
        if (rst) begin
            cur_state <= S_IDLE;
            next_state <= S_IDLE;
            busy <= 0;

        end else if (data_latch) begin
            // if we're already busy, we will just interupt the
            // current display sequence. The current command will
            // be completed first, then the display will start
            // receiving the new data that was freshly latched
            cur_state <= S_DATAMODE;
            busy <= 1;

        end else if (busy && tm_busy == 0) begin
            case (cur_state)
                S_IDLE: begin
                    busy <= 0;
                end

                S_DATAMODE: begin
                    // | 0 | 1 | x | x | N | I | W | 0 |
                    // N = Normal mode (0), I = Address increment (0),
                    // W = Write (0)
                    tm_byte <= 8'b01000000;
                    tm_stop_bit <= 1;
                    tm_latch <= 1;

                    cur_state <= S_LATCH;
                    next_state <= S_LOCATION;
                end

                S_LOCATION: begin
                    // | 1 | 1 | x | x | 0 | 0 | U | L |
                    // U = upper addr, L = lower addr
                    tm_byte <= 8'b11000000;
                    tm_stop_bit <= 0;
                    tm_latch <= 1;

                    // load first digit into dec_to_seg
                    dec_in <= thousands;

                    cur_state <= S_LATCH;
                    next_state <= S_WRITE_HEX3;
                end

                S_WRITE_HEX3: begin
                    tm_byte <= {1'd0, seg_out};
                    tm_stop_bit <= 0;
                    tm_latch <= 1;

                    // load second digit into dec_to_seg
                    dec_in <= hundreds;

                    cur_state <= S_LATCH;
                    next_state <= S_WRITE_HEX2;
                end

                S_WRITE_HEX2: begin
                    tm_byte <= {1'd0, seg_out};
                    tm_stop_bit <= 0;
                    tm_latch <= 1;

                    // load second digit into dec_to_seg
                    dec_in <= tens;

                    cur_state <= S_LATCH;
                    next_state <= S_WRITE_HEX1;
                end

                S_WRITE_HEX1: begin
                    tm_byte <= {1'd0, seg_out};
                    tm_stop_bit <= 0;
                    tm_latch <= 1;

                    // load second digit into dec_to_seg
                    dec_in <= ones;

                    cur_state <= S_LATCH;
                    next_state <= S_WRITE_HEX0;
                end

                S_WRITE_HEX0: begin
                    tm_byte <= {1'd0, seg_out};
                    tm_stop_bit <= 1;
                    tm_latch <= 1;

                    cur_state <= S_LATCH;
                    next_state <= S_DISPLAY;
                end

                S_DISPLAY: begin
                    // | 1 | 0 | x | x | D | U | M | L |
                    // D = Display on/off, U = upper brightness bit,
                    // M = mid brightness bit, L = low brightness bit
                    tm_byte <= 8'b10001111;
                    tm_stop_bit <= 1;
                    tm_latch <= 1;

                    cur_state <= S_LATCH;
                    next_state <= S_IDLE;
                end

                S_LATCH: begin
                    tm_latch <= 0;
                    cur_state <= next_state;
                end
            endcase
        end
    end
endmodule
