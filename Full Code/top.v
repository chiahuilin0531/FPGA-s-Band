module top(
   input clk,
   input rst,
   input play, 
   input stop,
   input volUp,
   input volDown,
   input back,
   output [3:0] vgaRed,
   output [3:0] vgaGreen,
   output [3:0] vgaBlue,
   output hsync,
   output vsync,
   output [3:0]AN,
   output [6:0]SEG,
   output [4:0] led_vol,
   output audio_mclk, // master clock
   output audio_lrck, // left-right clock
   output audio_sck, // serial clock
   output audio_sdin, // serial audio data input
   output audio_mclk_2, // master clock
   output audio_lrck_2, // left-right clock
   output audio_sck_2, // serial clock
   output audio_sdin_2, // serial audio data input
   output audio_mclk_3, // master clock
   output audio_lrck_3, // left-right clock
   output audio_sck_3, // serial clock
   output audio_sdin_3, // serial audio data input
   
   inout PS2_CLK,
   inout PS2_DATA
);

    wire clk_25MHz;
    wire clk_segment;
	wire clk_fsm;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    
    wire enable_mouse_display, valid;
    wire [9 : 0] MOUSE_X_POS , MOUSE_Y_POS;
    wire MOUSE_LEFT , MOUSE_MIDDLE , MOUSE_RIGHT , MOUSE_NEW_EVENT;
    wire [3 : 0] mouse_cursor_red , mouse_cursor_green , mouse_cursor_blue;
    wire [11:0] mouse_pixel = {mouse_cursor_red, mouse_cursor_green, mouse_cursor_blue};
	
	wire [2:0] HomeScreenVolume, MainThemeVolume, ChordThemeVolume, BassThemeVolume, BeatThemeVolume;
	wire [4:0] MainThemeOut, ChordThemeOut, BassThemeOut;
	wire [1:0] BeatThemeOut;

    clock_divisor clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
      .clk17(clk_segment),
	  .clk21(clk_fsm)
    );
	
	wire play_debounce, stop_debounce, volUp_debounce, volDown_debounce, back_debounce;
	debounce debounce0(play_debounce, play, clk_segment);
	debounce debounce1(stop_debounce, stop, clk_segment);
	debounce debounce2(volUp_debounce, volUp, clk_segment);
	debounce debounce3(volDown_debounce, volDown, clk_segment);
	debounce debounce4(back_debounce, back, clk_segment);
	
	wire play_1pulse, stop_1pulse, volUp_1pulse, volDown_1pulse, back_1pulse, MOUSE_LEFT_1pulse;
	onepulse onepulse0(play_debounce, clk_fsm, play_1pulse);
	onepulse onepulse1(stop_debounce, clk_fsm, stop_1pulse);
	onepulse onepulse2(volUp_debounce, clk_fsm, volUp_1pulse);
	onepulse onepulse3(volDown_debounce, clk_fsm, volDown_1pulse);
	onepulse onepulse4(back_debounce, clk_fsm, back_1pulse);
	onepulse onepulse5(MOUSE_LEFT, clk_fsm, MOUSE_LEFT_1pulse);

	speaker speaker0(
    .clk(clk), // clock from crystal
    .rst(rst), // active high reset: BTNC
    .HomeScreenVolume(HomeScreenVolume),
    .MainThemeVolume(MainThemeVolume),
    .ChordThemeVolume(ChordThemeVolume),
    .BassThemeVolume(BassThemeVolume),
    .BeatThemeVolume(BeatThemeVolume),
    .MainThemeOut(MainThemeOut),
    .ChordThemeOut(ChordThemeOut),
    .BassThemeOut(BassThemeOut),
    .BeatThemeOut(BeatThemeOut),
    .audio_mclk(audio_mclk), // master clock
    .audio_lrck(audio_lrck), // left-right clock
    .audio_sck(audio_sck), // serial clock
    .audio_sdin(audio_sdin), // serial audio data input
    .audio_mclk_2(audio_mclk_2), // master clock
    .audio_lrck_2(audio_lrck_2), // left-right clock
    .audio_sck_2(audio_sck_2), // serial clock
    .audio_sdin_2(audio_sdin_2), // serial audio data input
    .audio_mclk_3(audio_mclk_3), // master clock
    .audio_lrck_3(audio_lrck_3), // left-right clock
    .audio_sck_3(audio_sck_3), // serial clock
    .audio_sdin_3(audio_sdin_3) // serial audio data input
);

   pixel_gen pixel_gen_inst(
	   .clk(clk_fsm),
	   .clk_segment(clk_segment),
	   .clk_25MHz(clk_25MHz),
	   .reset(rst),
	   .play_puase(play_1pulse),
	   .stop(stop_1pulse),
	   .volUp(volUp_1pulse),
	   .volDown(volDown_1pulse),
	   .back(back_1pulse),
       .h_cnt(h_cnt),
	   .v_cnt(v_cnt),
       .MOUSE_X_POS(MOUSE_X_POS),
	   .MOUSE_Y_POS(MOUSE_Y_POS),
       .valid(valid),
       .enable_mouse_display(enable_mouse_display),
       .mouse_pixel(mouse_pixel),
       .MOUSE_LEFT(MOUSE_LEFT_1pulse),
       .vgaRed(vgaRed),
       .vgaGreen(vgaGreen),
       .vgaBlue(vgaBlue),
	   .led_vol(led_vol),
	   .AN(AN),
       .SEG(SEG),
	   .HomeScreenVolume(HomeScreenVolume),
	   .MainThemeVolume(MainThemeVolume),
	   .ChordThemeVolume(ChordThemeVolume),
	   .BaseThemeVolume(BassThemeVolume),
	   .BeatThemeVolume(BeatThemeVolume),
	   .MainThemeOut(MainThemeOut),
	   .ChordThemeOut(ChordThemeOut),
	   .BaseThemeOut(BassThemeOut),
	   .BeatThemeOut(BeatThemeOut)
    );
    

    vga_controller vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );
    
    mouse mouse_ctrl_inst(
        .clk(clk),
        .h_cntr_reg(h_cnt),
        .v_cntr_reg(v_cnt),
        .enable_mouse_display(enable_mouse_display),
        .MOUSE_X_POS(MOUSE_X_POS),
        .MOUSE_Y_POS(MOUSE_Y_POS),
        .MOUSE_LEFT(MOUSE_LEFT),
        .MOUSE_MIDDLE(MOUSE_MIDDLE),
        .MOUSE_RIGHT(MOUSE_RIGHT),
        .MOUSE_NEW_EVENT(MOUSE_NEW_EVENT),
        .mouse_cursor_red(mouse_cursor_red),
        .mouse_cursor_green(mouse_cursor_green),
        .mouse_cursor_blue(mouse_cursor_blue),
        .PS2_CLK(PS2_CLK),
        .PS2_DATA(PS2_DATA)
    );

    
	
endmodule
