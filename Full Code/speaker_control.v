module speaker_control(
    clk,  // clock from the crystal
    rst,  // active high reset
    
    audio_in_left, // left channel audio data input
    audio_in_right, // right channel audio data input
    audio_in_left_2, // left channel audio data input
    audio_in_right_2, // right channel audio data input
    audio_in_left_3, // left channel audio data input
    audio_in_right_3, // right channel audio data input
    
    audio_mclk, // master clock
    audio_lrck, // left-right clock, Word Select clock, or sample rate_L clock
    audio_sck, // serial clock
    audio_sdin, // serial audio data input
    
    
    audio_mclk_2, // master clock
    audio_lrck_2, // left-right clock
    audio_sck_2, // serial clock
    audio_sdin_2, // serial audio data input
    
    audio_mclk_3, // master clock
    audio_lrck_3, // left-right clock
    audio_sck_3, // serial clock
    audio_sdin_3 // serial audio data input
);

    // I/O declaration
    input clk;  // clock from the crystal
    input rst;  // active high reset
    input [15:0] audio_in_left; // left channel audio data input
    input [15:0] audio_in_right; // right channel audio data input
    input [15:0] audio_in_left_2; // left channel audio data input
    input [15:0] audio_in_right_2; // right channel audio data input
    input [15:0] audio_in_left_3; // left channel audio data input
    input [15:0] audio_in_right_3; // right channel audio data input
    output audio_mclk; // master clock
    output audio_lrck; // left-right clock
    output audio_sck; // serial clock
    output audio_sdin; // serial audio data input
    output audio_mclk_2; // master clock
    output audio_lrck_2; // left-right clock
    output audio_sck_2; // serial clock
    output audio_sdin_2; // serial audio data input
    output audio_mclk_3; // master clock
    output audio_lrck_3; // left-right clock
    output audio_sck_3; // serial clock
    output audio_sdin_3; // serial audio data input
    reg audio_sdin;
    reg audio_sdin_2;
    reg audio_sdin_3;

    // Declare internal signal nodes 
    wire [8:0] clk_cnt_next;
    reg [8:0] clk_cnt;
    reg [15:0] audio_left, audio_right;

    // Counter for the clock divider
    assign clk_cnt_next = clk_cnt + 1'b1;

    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            clk_cnt <= 9'd0;
        else
            clk_cnt <= clk_cnt_next;

    // Assign divided clock output
    assign audio_mclk = clk_cnt[1];
    assign audio_lrck = clk_cnt[8];
    assign audio_sck = 1'b1; // use internal serial clock mode

    // audio input data buffer
    always @(posedge clk_cnt[8] or posedge rst)
        if (rst == 1'b1)
            begin
                audio_left <= 16'd0;
                audio_right <= 16'd0;
            end
        else
            begin
                audio_left <= audio_in_left;
                audio_right <= audio_in_right;
            end

    always @*
        case (clk_cnt[8:4])
            5'b00000: audio_sdin = audio_right[0];
            5'b00001: audio_sdin = audio_left[15];
            5'b00010: audio_sdin = audio_left[14];
            5'b00011: audio_sdin = audio_left[13];
            5'b00100: audio_sdin = audio_left[12];
            5'b00101: audio_sdin = audio_left[11];
            5'b00110: audio_sdin = audio_left[10];
            5'b00111: audio_sdin = audio_left[9];
            5'b01000: audio_sdin = audio_left[8];
            5'b01001: audio_sdin = audio_left[7];
            5'b01010: audio_sdin = audio_left[6];
            5'b01011: audio_sdin = audio_left[5];
            5'b01100: audio_sdin = audio_left[4];
            5'b01101: audio_sdin = audio_left[3];
            5'b01110: audio_sdin = audio_left[2];
            5'b01111: audio_sdin = audio_left[1];
            5'b10000: audio_sdin = audio_left[0];
            5'b10001: audio_sdin = audio_right[15];
            5'b10010: audio_sdin = audio_right[14];
            5'b10011: audio_sdin = audio_right[13];
            5'b10100: audio_sdin = audio_right[12];
            5'b10101: audio_sdin = audio_right[11];
            5'b10110: audio_sdin = audio_right[10];
            5'b10111: audio_sdin = audio_right[9];
            5'b11000: audio_sdin = audio_right[8];
            5'b11001: audio_sdin = audio_right[7];
            5'b11010: audio_sdin = audio_right[6];
            5'b11011: audio_sdin = audio_right[5];
            5'b11100: audio_sdin = audio_right[4];
            5'b11101: audio_sdin = audio_right[3];
            5'b11110: audio_sdin = audio_right[2];
            5'b11111: audio_sdin = audio_right[1];
            default: audio_sdin = 1'b0;
        endcase


    // Declare internal signal nodes 
    wire [8:0] clk_cnt_next_2;
    reg [8:0] clk_cnt_2;
    reg [15:0] audio_left_2, audio_right_2;

    // Counter for the clock divider
    assign clk_cnt_next_2 = clk_cnt_2 + 1'b1;

    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            clk_cnt_2 <= 9'd0;
        else
            clk_cnt_2 <= clk_cnt_next_2;

    // Assign divided clock output
    assign audio_mclk_2 = clk_cnt_2[1];
    assign audio_lrck_2 = clk_cnt_2[8];
    assign audio_sck_2 = 1'b1; // use internal serial clock mode

    // audio input data buffer
    always @(posedge clk_cnt_2[8] or posedge rst)
        if (rst == 1'b1)
            begin
                audio_left_2 <= 16'd0;
                audio_right_2 <= 16'd0;
            end
        else
            begin
                audio_left_2 <= audio_in_left_2;
                audio_right_2 <= audio_in_right_2;
            end

    always @*
        case (clk_cnt_2[8:4])
            5'b00000: audio_sdin_2 = audio_right_2[0];
            5'b00001: audio_sdin_2 = audio_left_2[15];
            5'b00010: audio_sdin_2 = audio_left_2[14];
            5'b00011: audio_sdin_2 = audio_left_2[13];
            5'b00100: audio_sdin_2 = audio_left_2[12];
            5'b00101: audio_sdin_2 = audio_left_2[11];
            5'b00110: audio_sdin_2 = audio_left_2[10];
            5'b00111: audio_sdin_2 = audio_left_2[9];
            5'b01000: audio_sdin_2 = audio_left_2[8];
            5'b01001: audio_sdin_2 = audio_left_2[7];
            5'b01010: audio_sdin_2 = audio_left_2[6];
            5'b01011: audio_sdin_2 = audio_left_2[5];
            5'b01100: audio_sdin_2 = audio_left_2[4];
            5'b01101: audio_sdin_2 = audio_left_2[3];
            5'b01110: audio_sdin_2 = audio_left_2[2];
            5'b01111: audio_sdin_2 = audio_left_2[1];
            5'b10000: audio_sdin_2 = audio_left_2[0];
            5'b10001: audio_sdin_2 = audio_right_2[15];
            5'b10010: audio_sdin_2 = audio_right_2[14];
            5'b10011: audio_sdin_2 = audio_right_2[13];
            5'b10100: audio_sdin_2 = audio_right_2[12];
            5'b10101: audio_sdin_2 = audio_right_2[11];
            5'b10110: audio_sdin_2 = audio_right_2[10];
            5'b10111: audio_sdin_2 = audio_right_2[9];
            5'b11000: audio_sdin_2 = audio_right_2[8];
            5'b11001: audio_sdin_2 = audio_right_2[7];
            5'b11010: audio_sdin_2 = audio_right_2[6];
            5'b11011: audio_sdin_2 = audio_right_2[5];
            5'b11100: audio_sdin_2 = audio_right_2[4];
            5'b11101: audio_sdin_2 = audio_right_2[3];
            5'b11110: audio_sdin_2 = audio_right_2[2];
            5'b11111: audio_sdin_2 = audio_right_2[1];
            default: audio_sdin_2 = 1'b0;
        endcase
        
        
    // Declare internal signal nodes 
    wire [8:0] clk_cnt_next_3;
    reg [8:0] clk_cnt_3;
    reg [15:0] audio_left_3, audio_right_3;

    // Counter for the clock divider
    assign clk_cnt_next_3 = clk_cnt_3 + 1'b1;

    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            clk_cnt_3 <= 9'd0;
        else
            clk_cnt_3 <= clk_cnt_next_3;

    // Assign divided clock output
    assign audio_mclk_3 = clk_cnt_3[1];
    assign audio_lrck_3 = clk_cnt_3[8];
    assign audio_sck_3 = 1'b1; // use internal serial clock mode

    // audio input data buffer
    always @(posedge clk_cnt_3[8] or posedge rst)
        if (rst == 1'b1)
            begin
                audio_left_3 <= 16'd0;
                audio_right_3 <= 16'd0;
            end
        else
            begin
                audio_left_3 <= audio_in_left_3;
                audio_right_3 <= audio_in_right_3;
            end

    always @*
        case (clk_cnt_3[8:4])
            5'b00000: audio_sdin_3 = audio_right_3[0];
            5'b00001: audio_sdin_3 = audio_left_3[15];
            5'b00010: audio_sdin_3 = audio_left_3[14];
            5'b00011: audio_sdin_3 = audio_left_3[13];
            5'b00100: audio_sdin_3 = audio_left_3[12];
            5'b00101: audio_sdin_3 = audio_left_3[11];
            5'b00110: audio_sdin_3 = audio_left_3[10];
            5'b00111: audio_sdin_3 = audio_left_3[9];
            5'b01000: audio_sdin_3 = audio_left_3[8];
            5'b01001: audio_sdin_3 = audio_left_3[7];
            5'b01010: audio_sdin_3 = audio_left_3[6];
            5'b01011: audio_sdin_3 = audio_left_3[5];
            5'b01100: audio_sdin_3 = audio_left_3[4];
            5'b01101: audio_sdin_3 = audio_left_3[3];
            5'b01110: audio_sdin_3 = audio_left_3[2];
            5'b01111: audio_sdin_3 = audio_left_3[1];
            5'b10000: audio_sdin_3 = audio_left_3[0];
            5'b10001: audio_sdin_3 = audio_right_3[15];
            5'b10010: audio_sdin_3 = audio_right_3[14];
            5'b10011: audio_sdin_3 = audio_right_3[13];
            5'b10100: audio_sdin_3 = audio_right_3[12];
            5'b10101: audio_sdin_3 = audio_right_3[11];
            5'b10110: audio_sdin_3 = audio_right_3[10];
            5'b10111: audio_sdin_3 = audio_right_3[9];
            5'b11000: audio_sdin_3 = audio_right_3[8];
            5'b11001: audio_sdin_3 = audio_right_3[7];
            5'b11010: audio_sdin_3 = audio_right_3[6];
            5'b11011: audio_sdin_3 = audio_right_3[5];
            5'b11100: audio_sdin_3 = audio_right_3[4];
            5'b11101: audio_sdin_3 = audio_right_3[3];
            5'b11110: audio_sdin_3 = audio_right_3[2];
            5'b11111: audio_sdin_3 = audio_right_3[1];
            default: audio_sdin_3 = 1'b0;
        endcase
        
endmodule