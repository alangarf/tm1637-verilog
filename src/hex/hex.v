module tm1637_hex(
    input clk,
    input rst,

    input hex_latch,
    input [15:0] hex_data,
    output hex_busy,

    output scl_en,
    output scl_out,

    output sda_en,
    output sda_out,
    input sda_in,   
    output [7:0] debug
    );

    reg [6:0] hex3;
    reg [6:0] hex2;
    reg [6:0] hex1;
    reg [6:0] hex0;
    hex_to_seg hex_disp0 (
        hex_data[3:0],
        hex0
    );

    hex_to_seg hex_disp1 (
        hex_data[7:4],
        hex1
    );

    hex_to_seg hex_disp2 (
        hex_data[11:8],
        hex2
    );

    hex_to_seg hex_disp3 (
        hex_data[15:12],
        hex3
    );

    // setup the tm1637 module and registers
    reg [7:0] tm_byte;
    reg tm_latch;
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

    reg [3:0] state;
    reg [3:0] next_state;

    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE;
            next_state <= S_IDLE;
            hex_busy <= 0;

        end else if (hex_latch) begin
            // check we're not busy, if not accept the new data
            state <= S_DATAMODE;
            hex_busy <= 1;

        end else if (hex_busy && tm_busy == 0) begin
            case (state)
                S_DATAMODE: begin
                    // | 0 | 1 | x | x | N | I | W | 0 |
                    // N = Normal mode (0), I = Address increment (0),
                    // W = Write (0)
                    tm_byte <= 8'b01000000;
                    tm_stop_bit <= 1;
                    tm_latch <= 1;

                    state <= S_LATCH;
                    next_state <= S_LOCATION;
                end

                S_LOCATION: begin
                    // | 1 | 1 | x | x | 0 | 0 | U | L |
                    // U = upper addr, L = lower addr
                    tm_byte <= 8'b11000000;
                    tm_stop_bit <= 0;
                    tm_latch <= 1;

                    state <= S_LATCH;
                    next_state <= S_WRITE_HEX3;
                end

                S_WRITE_HEX3: begin
                    tm_byte <= {1'd0, hex3[6:0]};
                    tm_stop_bit <= 0;
                    tm_latch <= 1;

                    state <= S_LATCH;
                    next_state <= S_WRITE_HEX2;
                end

                S_WRITE_HEX2: begin
                    tm_byte <= {1'd0, hex2[6:0]};
                    tm_stop_bit <= 0;
                    tm_latch <= 1;

                    state <= S_LATCH;
                    next_state <= S_WRITE_HEX1;
                end

                S_WRITE_HEX1: begin
                    tm_byte <= {1'd0, hex1[6:0]};
                    tm_stop_bit <= 0;
                    tm_latch <= 1;

                    state <= S_LATCH;
                    next_state <= S_WRITE_HEX0;
                end

                S_WRITE_HEX0: begin
                    tm_byte <= {1'd0, hex0[6:0]};
                    tm_stop_bit <= 1;
                    tm_latch <= 1;

                    state <= S_LATCH;
                    next_state <= S_DISPLAY;
                end

                S_DISPLAY: begin
                    // | 1 | 0 | x | x | D | U | M | L |
                    // D = Display on/off, U = upper brightness bit,
                    // M = mid brightness bit, L = low brightness bit
                    tm_byte <= 8'b10001111;
                    tm_stop_bit <= 1;
                    tm_latch <= 1;

                    state <= S_LATCH;
                    next_state <= S_IDLE;
                end

                S_LATCH: begin
                    tm_latch <= 0;
                    state <= next_state;
                end

                S_IDLE: begin
                    hex_busy <= 0;
                end
            endcase
        end
    end

    assign debug[7] = tm_busy;
    assign debug[6] = hex_busy;
    assign debug[5] = hex_latch;
    assign debug[4:3] = 0;
    assign debug[2:0] = state;

endmodule
