module pixel_gen(
   input clk,
   input clk_segment,
   input clk_25MHz,
   input reset,
   input play_puase, 
   input stop,
   input volUp,
   input volDown,
   input back,
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   input [9:0] MOUSE_X_POS,
   input [9:0] MOUSE_Y_POS,
   input valid,
   input enable_mouse_display,
   input [11:0] mouse_pixel,
   input MOUSE_LEFT,
   output reg [3:0] vgaRed,
   output reg [3:0] vgaGreen,
   output reg [3:0] vgaBlue,
   output reg [4:0] led_vol,
   output [3:0]AN,
   output [6:0]SEG,
   output reg [2:0] HomeScreenVolume,
   output reg [2:0] MainThemeVolume,
   output reg [2:0] ChordThemeVolume,
   output reg [2:0] BaseThemeVolume,
   output reg [2:0] BeatThemeVolume,
   output reg [4:0] MainThemeOut,
   output reg [4:0] ChordThemeOut,
   output reg [4:0] BaseThemeOut,
   output reg [1:0] BeatThemeOut
);
///screen state
`define HomeScreen 3'b000
`define MainTheme  3'b001
`define ChordTheme 3'b010
`define BaseTheme  3'b011
`define BeatTheme  3'b100
reg [2:0]screen_state, next_screen_state;
reg screen_flag, next_screen_flag;
always@(posedge clk, posedge reset) begin
	if(reset) begin
		screen_state <= `HomeScreen;
		screen_flag <= 0;
	end
	else begin
		screen_state <= next_screen_state;
		screen_flag <= next_screen_flag;
	end
end

always@(*) begin
	next_screen_state = screen_state;
	next_screen_flag = 0;
	case(screen_state)
		`HomeScreen: begin
			if(MOUSE_LEFT) begin
				if(MOUSE_Y_POS<=120) next_screen_state = `MainTheme;
				else if(MOUSE_Y_POS<=240) next_screen_state = `BaseTheme;
				else if(MOUSE_Y_POS<=360) next_screen_state = `ChordTheme;
				else next_screen_state = `BeatTheme;		
				next_screen_flag = 1;
			end
		end
		`MainTheme: begin
			if(back) begin
				next_screen_state = `HomeScreen;
				next_screen_flag = 1;
			end
		end
		`BaseTheme: begin
			if(back) begin
				next_screen_state = `HomeScreen;
				next_screen_flag = 1;
			end
		end
		`ChordTheme: begin
			if(back) begin
				next_screen_state = `HomeScreen;
				next_screen_flag = 1;
			end
		end
		`BeatTheme: begin
			if(back) begin
				next_screen_state = `HomeScreen;
				next_screen_flag = 1;
			end
			if(MOUSE_LEFT) begin
				if(MOUSE_Y_POS<=120) next_screen_state = `MainTheme;
				else if(MOUSE_Y_POS<=240) next_screen_state = `BaseTheme;
				else if(MOUSE_Y_POS<=360) next_screen_state = `ChordTheme;		
				next_screen_flag = 1;
			end
		end
	endcase
end

///Input Music Data
integer i;
reg [4:0] MainThemeData[31:0], next_MainThemeData[31:0], MainThemeOut_input, next_MainThemeOut_input;
reg [4:0] ChordThemeData[3:0], next_ChordThemeData[3:0], Chord, next_Chord, ChordThemeOut_input, next_ChordThemeOut_input;
reg [4:0] BaseThemeData[31:0], next_BaseThemeData[31:0], BaseThemeOut_input, next_BaseThemeOut_input;
reg [1:0] BeatThemeData[31:0], next_BeatThemeData[31:0], BeatThemeOut_input, next_BeatThemeOut_input;
always@(posedge clk, posedge reset) begin
	if(reset) begin
		for(i=0; i<32; i=i+1) MainThemeData[i] <= 31;
		MainThemeOut_input <= 31;
		for(i=0; i<4; i=i+1) ChordThemeData[i] <= 31;
		Chord <= 31;
		ChordThemeOut_input <= 31;
		for(i=0; i<32; i=i+1) BaseThemeData[i] <= 31;
		BaseThemeOut_input <= 31;
		for(i=0; i<32; i=i+1) BeatThemeData[i] <= 3;
		BeatThemeOut_input <= 3;
	end
	else begin
		for(i=0; i<32; i=i+1) MainThemeData[i] <= next_MainThemeData[i];
		MainThemeOut_input <= next_MainThemeOut_input;
		for(i=0; i<4; i=i+1) ChordThemeData[i] <= next_ChordThemeData[i];
		Chord <= next_Chord;
		ChordThemeOut_input <= next_ChordThemeOut_input;
		for(i=0; i<32; i=i+1) BaseThemeData[i] <= next_BaseThemeData[i];
		BaseThemeOut_input <= next_BaseThemeOut_input;
		for(i=0; i<32; i=i+1) BeatThemeData[i] <= next_BeatThemeData[i];
		BeatThemeOut_input <= next_BeatThemeOut_input;
	end
end

always@(*) begin
	for(i=0; i<32; i=i+1) next_MainThemeData[i] = MainThemeData[i];
	next_MainThemeOut_input = 31;
	for(i=0; i<4; i=i+1) next_ChordThemeData[i] = ChordThemeData[i];
	next_Chord = Chord;
	next_ChordThemeOut_input = 31;
	for(i=0; i<32; i=i+1) next_BaseThemeData[i] = BaseThemeData[i];
	next_BaseThemeOut_input = 31;
	for(i=0; i<32; i=i+1) next_BeatThemeData[i] = BeatThemeData[i];
	next_BeatThemeOut_input = 3;
	
	if(screen_state==`MainTheme && MOUSE_LEFT && MOUSE_X_POS>=128 && MOUSE_X_POS<=576 && MOUSE_Y_POS>=96 && MOUSE_Y_POS<=396) begin
		if(MainThemeData[(MOUSE_X_POS-128)/14] == (MOUSE_Y_POS-96)/12) next_MainThemeData[(MOUSE_X_POS-128)/14] = 31;
		else begin 
			next_MainThemeData[(MOUSE_X_POS-128)/14] = (MOUSE_Y_POS-96)/12;
			next_MainThemeOut_input = 24 - (MOUSE_Y_POS-96)/12;
		end
	end
	if(screen_state==`ChordTheme && MOUSE_LEFT) begin
		if(MOUSE_X_POS>=270 && MOUSE_X_POS<=590 && MOUSE_Y_POS>=80 && MOUSE_Y_POS<=160) begin
			next_ChordThemeData[(MOUSE_X_POS-270)/80] = Chord;
		end
		else if(MOUSE_X_POS>=50 && MOUSE_X_POS<=590 && MOUSE_Y_POS>=310 && MOUSE_Y_POS<=355) begin
			if(Chord == 2*((MOUSE_X_POS-50)/45)) next_Chord = 31;
			else begin 
				next_Chord = 2*((MOUSE_X_POS-50)/45);
				next_ChordThemeOut_input = 2*((MOUSE_X_POS-50)/45);
			end
		end
		else if(MOUSE_X_POS>=50 && MOUSE_X_POS<=590 && MOUSE_Y_POS>=356 && MOUSE_Y_POS<=400) begin
			if(Chord == 2*((MOUSE_X_POS-50)/45) + 1) next_Chord = 31;
			else begin
				next_Chord = 2*((MOUSE_X_POS-50)/45) + 1;
				next_ChordThemeOut_input = 2*((MOUSE_X_POS-50)/45) + 1;
			end
		end
	end
	if(screen_state==`BaseTheme && MOUSE_LEFT && MOUSE_X_POS>=128 && MOUSE_X_POS<=576 && MOUSE_Y_POS>=96 && MOUSE_Y_POS<=396) begin
		if(BaseThemeData[(MOUSE_X_POS-129)/14] == (MOUSE_Y_POS-96)/12) next_BaseThemeData[(MOUSE_X_POS-129)/14] = 31;
		else begin 
			next_BaseThemeData[(MOUSE_X_POS-129)/14] = (MOUSE_Y_POS-96)/12;
			next_BaseThemeOut_input = 24 - (MOUSE_Y_POS-96)/12;
		end
	end
	if(screen_state==`BeatTheme && MOUSE_LEFT && MOUSE_X_POS>=128 && MOUSE_X_POS<=576 && MOUSE_Y_POS>=381 && MOUSE_Y_POS<=457) begin
		if(BeatThemeData[(MOUSE_X_POS-128)/14] == (MOUSE_Y_POS-381)/38) next_BeatThemeData[(MOUSE_X_POS-128)/14] = 3;
		else begin 
			next_BeatThemeData[(MOUSE_X_POS-128)/14] = (MOUSE_Y_POS-381)/38;
			next_BeatThemeOut_input = (MOUSE_Y_POS-381)/38;
		end
	end
end


///play
`define PlayInit 2'b00
`define Play     2'b01
`define Puase	 2'b10
reg[1:0] play_state, next_play_state, BeatThemeOut_play, next_BeatThemeOut_play;
reg[4:0] play_cnt, next_play_cnt, Out7Seg, MainThemeOut_play, BaseThemeOut_play, ChordThemeOut_play;
reg[4:0] next_MainThemeOut_play, next_BaseThemeOut_play, next_ChordThemeOut_play;
reg play, next_play, play_flag, next_play_flag;
always@(posedge clk, posedge reset) begin
	if(reset) begin
		play_state <= 0;
		play_cnt <= 0;
		play_flag <= 0;
		play <= 0;
		MainThemeOut_play <= 31;
		ChordThemeOut_play <= 31;
		BaseThemeOut_play <= 31;
		BeatThemeOut_play <= 31;
	end
	else begin
		play_state <= next_play_state;
		play_cnt <= next_play_cnt;
		play_flag <= next_play_flag;
		play <= next_play;
		MainThemeOut_play <= next_MainThemeOut_play;
		ChordThemeOut_play <= next_ChordThemeOut_play;
		BaseThemeOut_play <= next_BaseThemeOut_play;
		BeatThemeOut_play <= next_BeatThemeOut_play;
	end
end

wire play_fin;
reg play_start;
counter counter0(clk, play_start, play_fin);
always@(*) begin
	next_play_state = play_state;
	next_play_cnt = play_cnt;
	next_play = play;
	next_play_flag = 0;
	play_start = 0;
	Out7Seg = 31;
	next_MainThemeOut_play = 31;
	next_ChordThemeOut_play = 31;
	next_BaseThemeOut_play = 31;
	next_BeatThemeOut_play = 31;
	
	if(screen_state != `ChordTheme) begin
		if(play_puase && play==1) next_play = 0;
		if(play_puase && play==0) next_play = 1;
		case(play_state)
			`PlayInit: begin
				if(play) begin 
					next_play_state = `Play;
					next_play_flag = 1;
					play_start = 1;
				end
			end
			`Play: begin
				if(screen_state == `HomeScreen) begin
					if(MainThemeData[play_cnt] <= 24) begin
						Out7Seg = 24 - MainThemeData[play_cnt];
						if(play_flag) next_MainThemeOut_play = 24 - MainThemeData[play_cnt];
					end
					if(BaseThemeData[play_cnt] <= 24 && play_flag) begin
						next_BaseThemeOut_play = 24 - BaseThemeData[play_cnt];
					end
					if(BeatThemeData[play_cnt] <= 1 && play_flag) begin
						next_BeatThemeOut_play = BeatThemeData[play_cnt];
						if(ChordThemeData[play_cnt] <= 23) next_ChordThemeOut_play = ChordThemeData[play_cnt];
					end
				end
				else if(screen_state == `MainTheme && MainThemeData[play_cnt] <= 24) begin
					Out7Seg = 24 - MainThemeData[play_cnt];
					if(play_flag) next_MainThemeOut_play = 24 - MainThemeData[play_cnt];
				end
				else if(screen_state == `BaseTheme && BaseThemeData[play_cnt] <= 24) begin
					Out7Seg = 24 - BaseThemeData[play_cnt];
					if(play_flag) next_BaseThemeOut_play = 24 - BaseThemeData[play_cnt];
				end
				else if(screen_state == `BeatTheme && BeatThemeData[play_cnt] <= 1 && play_flag) begin
					next_BeatThemeOut_play = BeatThemeData[play_cnt];
				end
				
				if((play_cnt==31&&play_fin) || stop || screen_flag) begin
					next_play_state = `PlayInit;
					next_play_cnt = 0;
					next_play = 0;
				end
				else if(play == 0) begin
					next_play_state = `Puase;
				end
				else if(play_fin) begin
					next_play_cnt = play_cnt + 1;
					next_play_flag = 1;
					play_start = 1;
				end
			end
			`Puase: begin
				if(screen_state==`HomeScreen || screen_state==`MainTheme) begin
					if(MainThemeData[play_cnt] <= 24) Out7Seg = 24 - MainThemeData[play_cnt];
					else Out7Seg = 31;
				end
				else if(screen_state == `BaseTheme) begin
					if(BaseThemeData[play_cnt] <= 24) Out7Seg = 24 - BaseThemeData[play_cnt];
					else Out7Seg = 31;
				end
				
				if(stop || screen_flag) begin
					next_play_state = `PlayInit;
					next_play_cnt = 0;
					next_play = 0;
				end
				else if(play) begin
					next_play_state = `Play;
				end
			end
		endcase
	end
end

///out data
always@(*) begin
	if(play_state == `Play)	begin
		MainThemeOut = MainThemeOut_play;
		BaseThemeOut = BaseThemeOut_play;
		ChordThemeOut = ChordThemeOut_play;
		BeatThemeOut = BeatThemeOut_play;
	end
	else begin
		MainThemeOut = MainThemeOut_input;
		BaseThemeOut = BaseThemeOut_input;
		ChordThemeOut = ChordThemeOut_input;
		BeatThemeOut = BeatThemeOut_input;
	end
end

///7-segmant
segment_display segment_display0(
    .clk(clk_segment),
	.screen_state(screen_state),
    .MusicOut(Out7Seg),
    .AN(AN),
    .SEG(SEG)
);

///Volume
reg[2:0] next_HomeScreenVolume, next_MainThemeVolume, next_ChordThemeVolume, next_BaseThemeVolume, next_BeatThemeVolume, Volume;
always@(posedge clk, posedge reset) begin
	if(reset) begin 
		HomeScreenVolume <= 3;
		MainThemeVolume <= 3;
		ChordThemeVolume <= 3;
		BaseThemeVolume <= 3;
		BeatThemeVolume <= 3;
	end
	else begin 
		HomeScreenVolume <= next_HomeScreenVolume;
		MainThemeVolume <= next_MainThemeVolume;
		ChordThemeVolume <= next_ChordThemeVolume;
		BaseThemeVolume <= next_BaseThemeVolume;
		BeatThemeVolume <= next_BeatThemeVolume;
	end
end
	
always@(*) begin
	next_HomeScreenVolume = HomeScreenVolume;
	next_MainThemeVolume = MainThemeVolume;
	next_ChordThemeVolume = ChordThemeVolume;
	next_BaseThemeVolume = BaseThemeVolume;
	next_BeatThemeVolume = BeatThemeVolume;
	if(screen_state==`HomeScreen && volUp && HomeScreenVolume<5) next_HomeScreenVolume = HomeScreenVolume + 1;
	if(screen_state==`HomeScreen && volDown && HomeScreenVolume>0) next_HomeScreenVolume = HomeScreenVolume - 1;
	if(screen_state==`MainTheme && volUp && MainThemeVolume<5) next_MainThemeVolume = MainThemeVolume + 1;
	if(screen_state==`MainTheme && volDown && MainThemeVolume>0) next_MainThemeVolume = MainThemeVolume - 1;
	if(screen_state==`ChordTheme && volUp && ChordThemeVolume<5) next_ChordThemeVolume = ChordThemeVolume + 1;
	if(screen_state==`ChordTheme && volDown && ChordThemeVolume>0) next_ChordThemeVolume = ChordThemeVolume - 1;
	if(screen_state==`BaseTheme && volUp && BaseThemeVolume<5) next_BaseThemeVolume = BaseThemeVolume + 1;
	if(screen_state==`BaseTheme && volDown && BaseThemeVolume>0) next_BaseThemeVolume = BaseThemeVolume - 1;
	if(screen_state==`BeatTheme && volUp && BeatThemeVolume<5) next_BeatThemeVolume = BeatThemeVolume + 1;
	if(screen_state==`BeatTheme && volDown && BeatThemeVolume>0) next_BeatThemeVolume = BeatThemeVolume - 1;
end
	
always@(*) begin
	case(screen_state)
		`HomeScreen: Volume = HomeScreenVolume;
		`MainTheme:  Volume = MainThemeVolume;
		`ChordTheme: Volume = ChordThemeVolume;
		`BaseTheme:  Volume = BaseThemeVolume;
		`BeatTheme:  Volume = BeatThemeVolume;
	endcase
end

always@(*) begin
	case(Volume)
		0: led_vol = 5'b0_0000;
		1: led_vol = 5'b0_0001;
		2: led_vol = 5'b0_0011;
		3: led_vol = 5'b0_0111;
		4: led_vol = 5'b0_1111;
		5: led_vol = 5'b1_1111;
	endcase
end

///pixel_gen
reg [15:0] pixel_addr_80;
wire pixel_80;
blk_mem_gen_3 blk_mem_gen_3_0(
    .clka(clk_25MHz),
    .wea(0),
    .addra(pixel_addr_80),
    .dina(),
    .douta(pixel_80)
); 

reg [13:0] pixel_addr_45;
wire pixel_45;
blk_mem_gen_0 blk_mem_gen_0_0(
    .clka(clk_25MHz),
    .wea(0),
    .addra(pixel_addr_45),
    .dina(),
    .douta(pixel_45)
); 

reg [5:0] pixel_addr_8_0;
wire pixel_8_0;
blk_mem_gen_2 blk_mem_gen_2_0(
    .clka(clk_25MHz),
    .wea(0),
    .addra(pixel_addr_8_0),
    .dina(),
    .douta(pixel_8_0)
); 

reg [5:0] pixel_addr_8_1;
wire pixel_8_1;
blk_mem_gen_1 blk_mem_gen_1_0(
    .clka(clk_25MHz),
    .wea(0),
    .addra(pixel_addr_8_1),
    .dina(),
    .douta(pixel_8_1)
); 

reg [12:0] pixel_addr_piano;
wire pixel_piano;
blk_mem_gen_piano blk_mem_gen_piano_0(
    .clka(clk_25MHz),
    .wea(0),
    .addra(pixel_addr_piano),
    .dina(),
    .douta(pixel_piano)
); 

reg [12:0] pixel_addr_guitar;
wire pixel_guitar;
blk_mem_gen_guitar blk_mem_gen_guitar_0(
    .clka(clk_25MHz),
    .wea(0),
    .addra(pixel_addr_guitar),
    .dina(),
    .douta(pixel_guitar)
); 

reg [12:0] pixel_addr_base;
wire pixel_base;
blk_mem_gen_bass blk_mem_gen_bass_0(
    .clka(clk_25MHz),
    .wea(0),
    .addra(pixel_addr_base),
    .dina(),
    .douta(pixel_base)
); 

reg [12:0] pixel_addr_beat;
wire pixel_beat;
blk_mem_gen_beat blk_mem_gen_beat_0(
    .clka(clk_25MHz),
    .wea(0),
    .addra(pixel_addr_beat),
    .dina(),
    .douta(pixel_beat)
); 

always@(*) begin
    if(!valid) begin
        {vgaRed, vgaGreen, vgaBlue} = 12'h0;
    end else if(enable_mouse_display) begin
        {vgaRed, vgaGreen, vgaBlue} = mouse_pixel;
    end else begin
		{vgaRed, vgaGreen, vgaBlue} = 12'hfff;
		if(screen_state==`HomeScreen || screen_state==`BeatTheme) begin
			if((h_cnt>=241&& h_cnt<=352)||(h_cnt>=465 && h_cnt<=576))begin
				{vgaRed, vgaGreen, vgaBlue} = 12'heee;
			end
			
			if(h_cnt==0 || h_cnt==640 || v_cnt==0 || v_cnt==120 || v_cnt==240 || v_cnt==360 || v_cnt==479)
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			else if(h_cnt==1 || h_cnt==639 || v_cnt==1 || v_cnt==119 || v_cnt==121 || v_cnt==239 || v_cnt==241 || v_cnt==359 || v_cnt==361 || v_cnt==478)
				{vgaRed, vgaGreen, vgaBlue} = 12'h444;
			else if(h_cnt==2 || h_cnt==638 || v_cnt==2 || v_cnt==118 || v_cnt==122 || v_cnt==238 || v_cnt==242 || v_cnt==358 || v_cnt==362 || v_cnt==477)
				{vgaRed, vgaGreen, vgaBlue} = 12'h888;
			else if(h_cnt>=128 && h_cnt<=577 && (v_cnt==21||v_cnt==97||v_cnt==141||v_cnt==217||v_cnt==261||v_cnt==337||v_cnt==381||v_cnt==457||v_cnt==419))
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			else if(screen_state==`BeatTheme && (h_cnt==3||h_cnt==637) && v_cnt>=363 && v_cnt<=476)
				{vgaRed, vgaGreen, vgaBlue} = 12'h792;
			else if(screen_state==`BeatTheme && h_cnt>=3 && h_cnt<=637 && (v_cnt==363||v_cnt==476))
				{vgaRed, vgaGreen, vgaBlue} = 12'h792;
			else if((h_cnt==128||h_cnt==577)&&(v_cnt>=21&&v_cnt<=97))
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			else if((h_cnt==128||h_cnt==577)&&(v_cnt>=141&&v_cnt<=217))
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			else if((h_cnt==128||h_cnt==577)&&(v_cnt>=261&&v_cnt<=337))
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			else if((h_cnt==128||h_cnt==577)&&(v_cnt>=381&&v_cnt<=457))
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			else if(v_cnt>=382 && v_cnt<=456 && h_cnt>=129 && h_cnt<=575 && (h_cnt-128)%14==0)
				{vgaRed, vgaGreen, vgaBlue} = 12'h666;
			else if(h_cnt>=129 && h_cnt<=576 && v_cnt>=22 && v_cnt<=96 && MainThemeData[(h_cnt-129)/14]==(v_cnt-22)/3) begin
				if(screen_state==`HomeScreen && play_state != `PlayInit && play_cnt==(h_cnt-129)/14) {vgaRed, vgaGreen, vgaBlue} = 12'hf85;
				else {vgaRed, vgaGreen, vgaBlue} = 12'hf40;
			end
			else if(h_cnt>=129 && h_cnt<=576 && v_cnt>=142 && v_cnt<=216 && BaseThemeData[(h_cnt-129)/14]==(v_cnt-142)/3) begin
				if(screen_state==`HomeScreen && play_state != `PlayInit && play_cnt==(h_cnt-129)/14) {vgaRed, vgaGreen, vgaBlue} = 12'he84;
				else {vgaRed, vgaGreen, vgaBlue} = 12'h941;
			end
			else if(h_cnt>=129 && h_cnt<=576 && v_cnt>=381 && v_cnt<=457 && BeatThemeData[(h_cnt-129)/14]==(v_cnt-381)/38) begin
				if(play_state != `PlayInit && play_cnt==(h_cnt-129)/14) begin
					{vgaRed, vgaGreen, vgaBlue} = 12'h9c9;
				end
				else {vgaRed, vgaGreen, vgaBlue} = 12'h792;
			end
			else if(h_cnt>=20 && h_cnt<=109 && v_cnt>=16 && v_cnt<=105) begin
				pixel_addr_piano = h_cnt-20 + (v_cnt-16)*90;
				if(pixel_piano && h_cnt>22) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if(h_cnt>=20 && h_cnt<=109 && v_cnt>=136 && v_cnt<=225) begin
				pixel_addr_base = h_cnt-20 + (v_cnt-136)*90;
				if(pixel_base && h_cnt>22) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if(h_cnt>=20 && h_cnt<=109 && v_cnt>=256 && v_cnt<=345) begin
				pixel_addr_guitar = h_cnt-20 + (v_cnt-256)*90;
				if(pixel_guitar && h_cnt>22) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if(h_cnt>=20 && h_cnt<=109 && v_cnt>=376 && v_cnt<=465) begin
				pixel_addr_beat = h_cnt-20 + (v_cnt-376)*90;
				if(pixel_beat && h_cnt>22) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if(h_cnt>=129 && h_cnt<=241 && v_cnt>=262 && v_cnt<=336) begin
				if(screen_state==`HomeScreen && play_state!=`PlayInit && BeatThemeData[play_cnt]<=2 && play_cnt<=7)
					{vgaRed, vgaGreen, vgaBlue} = 12'hfe9;
					
				if(h_cnt>=162 && h_cnt<=206 && v_cnt>=277 && v_cnt<=321) begin
					pixel_addr_45 = 0;
					case(ChordThemeData[0]/2)
						0: pixel_addr_45 = h_cnt-161 + 45*2 + (v_cnt-276)*315;	
						1: pixel_addr_45 = h_cnt-161 + 45*2 + (v_cnt-276)*315;	
						2: pixel_addr_45 = h_cnt-161 + 45*3 + (v_cnt-276)*315;	
						3: pixel_addr_45 = h_cnt-161 + 45*3 + (v_cnt-276)*315;	
						4: pixel_addr_45 = h_cnt-161 + 45*4 + (v_cnt-276)*315;	
						5: pixel_addr_45 = h_cnt-161 + 45*5 + (v_cnt-276)*315;	
						6: pixel_addr_45 = h_cnt-161 + 45*5 + (v_cnt-276)*315;	
						7: pixel_addr_45 = h_cnt-161 + 45*6 + (v_cnt-276)*315;	
						8: pixel_addr_45 = h_cnt-161 + 45*6 + (v_cnt-276)*315;	
						9: pixel_addr_45 = h_cnt-161 + 45*0 + (v_cnt-276)*315;	
						10: pixel_addr_45 = h_cnt-161 + 45*0 + (v_cnt-276)*315;	
						11: pixel_addr_45 = h_cnt-161 + 45*1 + (v_cnt-276)*315;		
					endcase
					
					pixel_addr_8_0 = 0;
					if(h_cnt>=199 && h_cnt<=206 && v_cnt>=277 && v_cnt<=284) begin
						case(ChordThemeData[0]/2)
							1: pixel_addr_8_0 = h_cnt-198 + (v_cnt-276)*8;		
							3: pixel_addr_8_0 = h_cnt-198 + (v_cnt-276)*8;			
							6: pixel_addr_8_0 = h_cnt-198 + (v_cnt-276)*8;			
							8: pixel_addr_8_0 = h_cnt-198 + (v_cnt-276)*8;		
							10: pixel_addr_8_0 = h_cnt-198 + (v_cnt-276)*8;		
						endcase
					end
					
					pixel_addr_8_1 = 0;
					if(h_cnt>=198 && h_cnt<=205 && v_cnt>=314 && v_cnt<=321 && ChordThemeData[0]%2==1 && ChordThemeData[0]!=31)
						pixel_addr_8_1 = h_cnt-197 + (v_cnt-313)*8;		
						
					if(pixel_45 && h_cnt>=164) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					else if(pixel_8_0) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					else if(pixel_8_1) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
				end
			end
			else if(h_cnt>=242 && h_cnt<=353 && v_cnt>=262 && v_cnt<=336) begin
				if(screen_state==`HomeScreen && play_state!=`PlayInit && BeatThemeData[play_cnt]<=2 && 8<=play_cnt && play_cnt<=15)
					{vgaRed, vgaGreen, vgaBlue} = 12'hfe9;
					
				if(h_cnt>=275 && h_cnt<=319 && v_cnt>=277 && v_cnt<=321) begin
					pixel_addr_45 = 0;
					case(ChordThemeData[1]/2)
						0: pixel_addr_45 = h_cnt-274 + 45*2 + (v_cnt-276)*315;	
						1: pixel_addr_45 = h_cnt-274 + 45*2 + (v_cnt-276)*315;	
						2: pixel_addr_45 = h_cnt-274 + 45*3 + (v_cnt-276)*315;	
						3: pixel_addr_45 = h_cnt-274 + 45*3 + (v_cnt-276)*315;	
						4: pixel_addr_45 = h_cnt-274 + 45*4 + (v_cnt-276)*315;	
						5: pixel_addr_45 = h_cnt-274 + 45*5 + (v_cnt-276)*315;	
						6: pixel_addr_45 = h_cnt-274 + 45*5 + (v_cnt-276)*315;	
						7: pixel_addr_45 = h_cnt-274 + 45*6 + (v_cnt-276)*315;	
						8: pixel_addr_45 = h_cnt-274 + 45*6 + (v_cnt-276)*315;	
						9: pixel_addr_45 = h_cnt-274 + 45*0 + (v_cnt-276)*315;	
						10: pixel_addr_45 = h_cnt-274 + 45*0 + (v_cnt-276)*315;	
						11: pixel_addr_45 = h_cnt-274 + 45*1 + (v_cnt-276)*315;		
					endcase
					
					pixel_addr_8_0 = 0;
					if(h_cnt>=312 && h_cnt<=319 && v_cnt>=277 && v_cnt<=284) begin
						case(ChordThemeData[1]/2)
							1: pixel_addr_8_0 = h_cnt-311 + (v_cnt-276)*8;		
							3: pixel_addr_8_0 = h_cnt-311 + (v_cnt-276)*8;			
							6: pixel_addr_8_0 = h_cnt-311 + (v_cnt-276)*8;			
							8: pixel_addr_8_0 = h_cnt-311 + (v_cnt-276)*8;		
							10: pixel_addr_8_0 = h_cnt-311 + (v_cnt-276)*8;		
						endcase
					end
					
					pixel_addr_8_1 = 0;
					if(h_cnt>=311 && h_cnt<=318 && v_cnt>=314 && v_cnt<=321 && ChordThemeData[1]%2==1 && ChordThemeData[1]!=31)
						pixel_addr_8_1 = h_cnt-310 + (v_cnt-313)*8;		
						
					if(pixel_45 && h_cnt>=277) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					else if(pixel_8_0) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					else if(pixel_8_1) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
				end
			end
			else if(h_cnt>=354 && h_cnt<=465 && v_cnt>=262 && v_cnt<=336) begin
				if(screen_state==`HomeScreen && play_state!=`PlayInit && BeatThemeData[play_cnt]<=2 && play_cnt>=16 && play_cnt<=23)
					{vgaRed, vgaGreen, vgaBlue} = 12'hfe9;
					
				if(h_cnt>=387 && h_cnt<=431 && v_cnt>=277 && v_cnt<=321) begin
					pixel_addr_45 = 0;
					case(ChordThemeData[2]/2)
						0: pixel_addr_45 = h_cnt-386 + 45*2 + (v_cnt-276)*315;	
						1: pixel_addr_45 = h_cnt-386 + 45*2 + (v_cnt-276)*315;	
						2: pixel_addr_45 = h_cnt-386 + 45*3 + (v_cnt-276)*315;	
						3: pixel_addr_45 = h_cnt-386 + 45*3 + (v_cnt-276)*315;	
						4: pixel_addr_45 = h_cnt-386 + 45*4 + (v_cnt-276)*315;	
						5: pixel_addr_45 = h_cnt-386 + 45*5 + (v_cnt-276)*315;	
						6: pixel_addr_45 = h_cnt-386 + 45*5 + (v_cnt-276)*315;	
						7: pixel_addr_45 = h_cnt-386 + 45*6 + (v_cnt-276)*315;	
						8: pixel_addr_45 = h_cnt-386 + 45*6 + (v_cnt-276)*315;	
						9: pixel_addr_45 = h_cnt-386 + 45*0 + (v_cnt-276)*315;	
						10: pixel_addr_45 = h_cnt-386 + 45*0 + (v_cnt-276)*315;	
						11: pixel_addr_45 = h_cnt-386 + 45*1 + (v_cnt-276)*315;		
					endcase
					
					pixel_addr_8_0 = 0;
					if(h_cnt>=424 && h_cnt<=431 && v_cnt>=277 && v_cnt<=284) begin
						case(ChordThemeData[2]/2)
							1: pixel_addr_8_0 = h_cnt-423 + (v_cnt-276)*8;		
							3: pixel_addr_8_0 = h_cnt-423 + (v_cnt-276)*8;			
							6: pixel_addr_8_0 = h_cnt-423 + (v_cnt-276)*8;			
							8: pixel_addr_8_0 = h_cnt-423 + (v_cnt-276)*8;		
							10: pixel_addr_8_0 = h_cnt-423 + (v_cnt-276)*8;		
						endcase
					end
					
					pixel_addr_8_1 = 0;
					if(h_cnt>=423 && h_cnt<=430 && v_cnt>=314 && v_cnt<=321 && ChordThemeData[2]%2==1 && ChordThemeData[2]!=31)
						pixel_addr_8_1 = h_cnt-422 + (v_cnt-313)*8;		
						
					if(pixel_45 && h_cnt>=389) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					else if(pixel_8_0) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					else if(pixel_8_1) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
				end
			end
			else if(h_cnt>=466 && h_cnt<=576 && v_cnt>=262 && v_cnt<=336) begin
				if(screen_state==`HomeScreen && play_state!=`PlayInit && BeatThemeData[play_cnt]<=2 && play_cnt>=24 && play_cnt<=31)
					{vgaRed, vgaGreen, vgaBlue} = 12'hfe9;
					
				if(h_cnt>=499 && h_cnt<=543 && v_cnt>=277 && v_cnt<=321) begin
					pixel_addr_45 = 0;
					case(ChordThemeData[3]/2)
						0: pixel_addr_45 = h_cnt-498 + 45*2 + (v_cnt-276)*315;	
						1: pixel_addr_45 = h_cnt-498 + 45*2 + (v_cnt-276)*315;	
						2: pixel_addr_45 = h_cnt-498 + 45*3 + (v_cnt-276)*315;	
						3: pixel_addr_45 = h_cnt-498 + 45*3 + (v_cnt-276)*315;	
						4: pixel_addr_45 = h_cnt-498 + 45*4 + (v_cnt-276)*315;	
						5: pixel_addr_45 = h_cnt-498 + 45*5 + (v_cnt-276)*315;	
						6: pixel_addr_45 = h_cnt-498 + 45*5 + (v_cnt-276)*315;	
						7: pixel_addr_45 = h_cnt-498 + 45*6 + (v_cnt-276)*315;	
						8: pixel_addr_45 = h_cnt-498 + 45*6 + (v_cnt-276)*315;	
						9: pixel_addr_45 = h_cnt-498 + 45*0 + (v_cnt-276)*315;	
						10: pixel_addr_45 = h_cnt-498 + 45*0 + (v_cnt-276)*315;	
						11: pixel_addr_45 = h_cnt-498 + 45*1 + (v_cnt-276)*315;		
					endcase
					
					pixel_addr_8_0 = 0;
					if(h_cnt>=536 && h_cnt<=543 && v_cnt>=277 && v_cnt<=284) begin
						case(ChordThemeData[3]/2)
							1: pixel_addr_8_0 = h_cnt-535 + (v_cnt-276)*8;		
							3: pixel_addr_8_0 = h_cnt-535 + (v_cnt-276)*8;			
							6: pixel_addr_8_0 = h_cnt-535 + (v_cnt-276)*8;			
							8: pixel_addr_8_0 = h_cnt-535 + (v_cnt-276)*8;		
							10: pixel_addr_8_0 = h_cnt-535 + (v_cnt-276)*8;		
						endcase
					end
					
					pixel_addr_8_1 = 0;
					if(h_cnt>=535 && h_cnt<=542 && v_cnt>=314 && v_cnt<=321 && ChordThemeData[3]%2==1 && ChordThemeData[3]!=31)
						pixel_addr_8_1 = h_cnt-534 + (v_cnt-313)*8;		
						
					if(pixel_45 && h_cnt>=501) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					else if(pixel_8_0) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					else if(pixel_8_1) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
				end
			end
		end
		else if(screen_state == `MainTheme) begin
			if(((h_cnt>=240 && h_cnt<=352)||(h_cnt>=464 && h_cnt<=576)) && v_cnt>=96 && v_cnt<=396) begin
				{vgaRed, vgaGreen, vgaBlue} = 12'heee;
			end
			
			if(h_cnt>=128 && h_cnt<=576 && v_cnt>=96 && v_cnt<=396 && ((h_cnt-128)%28==0 || v_cnt==96 || v_cnt==396)) begin
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if(h_cnt>=128 && h_cnt<=576 && v_cnt>=96 && v_cnt<=396 && ((v_cnt-96)%12==0 || ((h_cnt-142)%28==0 && h_cnt>=142))) begin
				{vgaRed, vgaGreen, vgaBlue} = 12'h666;
			end
			else if((h_cnt==110 && v_cnt>=96 && v_cnt<=396)) begin
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if((v_cnt==96 || v_cnt==108 || v_cnt==192 || v_cnt==252 || v_cnt==336 || v_cnt==396) && h_cnt>=110 && h_cnt<=128) begin
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if(h_cnt>=12 && h_cnt<=101 && v_cnt>=195 && v_cnt<=284) begin
				pixel_addr_piano = h_cnt-12 + (v_cnt-195)*90;
				if(pixel_piano && h_cnt>14) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if(h_cnt>=110 && h_cnt<=120 && v_cnt>=96 && v_cnt<=396) begin
				case((v_cnt-96)/12)
					2: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					4: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					6: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					9: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					11: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					14: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					16: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					18: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					21: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					23: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					default: {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
				endcase
			end
			else if(h_cnt>=120 && h_cnt<=128 && v_cnt>=96 && v_cnt<=396 && (v_cnt-126)%12==0) begin
				case((v_cnt-126)/12)
					0: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					2: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					4: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					7: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					9: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					12: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					14: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					16: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					19: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					21: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					default: {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
				endcase
			end
			else if(h_cnt>=128 && h_cnt<=576 && v_cnt>=96 && v_cnt<=396 && MainThemeData[(h_cnt-128)/14]==(v_cnt-96)/12) begin
				if(play_state != `PlayInit && play_cnt==(h_cnt-128)/14) {vgaRed, vgaGreen, vgaBlue} = 12'hf85;
				else {vgaRed, vgaGreen, vgaBlue} = 12'hf40;
			end
		end
		else if(screen_state == `ChordTheme) begin
			if(h_cnt>=270 && h_cnt<= 590 && (v_cnt==80 || v_cnt==160)) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
			else if(h_cnt>=270 && h_cnt<= 590 && v_cnt>=80 && v_cnt<=160 && (h_cnt-270)%80==0)
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			else if(h_cnt>=90 && h_cnt<=179 && v_cnt>=75 && v_cnt<=164) begin
				pixel_addr_guitar = h_cnt-90 + (v_cnt-75)*90;
				if(pixel_guitar && h_cnt>92) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if(h_cnt>=270 && h_cnt<= 590 && v_cnt>=80 && v_cnt<=160) begin
				pixel_addr_80 = 0;	
				if((h_cnt-270)/80 == 0) begin
					case(ChordThemeData[0]/2)
						0: pixel_addr_80 = ((h_cnt-270)%80) + 80*2 + (v_cnt-80)*560;	
						1: pixel_addr_80 = ((h_cnt-270)%80) + 80*2 + (v_cnt-80)*560;	
						2: pixel_addr_80 = ((h_cnt-270)%80) + 80*3 + (v_cnt-80)*560;	
						3: pixel_addr_80 = ((h_cnt-270)%80) + 80*3 + (v_cnt-80)*560;	
						4: pixel_addr_80 = ((h_cnt-270)%80) + 80*4 + (v_cnt-80)*560;	
						5: pixel_addr_80 = ((h_cnt-270)%80) + 80*5 + (v_cnt-80)*560;	
						6: pixel_addr_80 = ((h_cnt-270)%80) + 80*5 + (v_cnt-80)*560;	
						7: pixel_addr_80 = ((h_cnt-270)%80) + 80*6 + (v_cnt-80)*560;	
						8: pixel_addr_80 = ((h_cnt-270)%80) + 80*6 + (v_cnt-80)*560;	
						9: pixel_addr_80 = ((h_cnt-270)%80) + 80*0 + (v_cnt-80)*560;	
						10: pixel_addr_80 = ((h_cnt-270)%80) + 80*0 + (v_cnt-80)*560;	
						11: pixel_addr_80 = ((h_cnt-270)%80) + 80*1 + (v_cnt-80)*560;		
					endcase
				end
				else if((h_cnt-270)/80 == 1) begin
					case(ChordThemeData[1]/2)
						0: pixel_addr_80 = ((h_cnt-270)%80) + 80*2 + (v_cnt-80)*560;	
						1: pixel_addr_80 = ((h_cnt-270)%80) + 80*2 + (v_cnt-80)*560;	
						2: pixel_addr_80 = ((h_cnt-270)%80) + 80*3 + (v_cnt-80)*560;	
						3: pixel_addr_80 = ((h_cnt-270)%80) + 80*3 + (v_cnt-80)*560;	
						4: pixel_addr_80 = ((h_cnt-270)%80) + 80*4 + (v_cnt-80)*560;	
						5: pixel_addr_80 = ((h_cnt-270)%80) + 80*5 + (v_cnt-80)*560;	
						6: pixel_addr_80 = ((h_cnt-270)%80) + 80*5 + (v_cnt-80)*560;	
						7: pixel_addr_80 = ((h_cnt-270)%80) + 80*6 + (v_cnt-80)*560;	
						8: pixel_addr_80 = ((h_cnt-270)%80) + 80*6 + (v_cnt-80)*560;	
						9: pixel_addr_80 = ((h_cnt-270)%80) + 80*0 + (v_cnt-80)*560;	
						10: pixel_addr_80 = ((h_cnt-270)%80) + 80*0 + (v_cnt-80)*560;	
						11: pixel_addr_80 = ((h_cnt-270)%80) + 80*1 + (v_cnt-80)*560;		
					endcase
				end
				else if((h_cnt-270)/80 == 2) begin
					case(ChordThemeData[2]/2)
						0: pixel_addr_80 = ((h_cnt-270)%80) + 80*2 + (v_cnt-80)*560;	
						1: pixel_addr_80 = ((h_cnt-270)%80) + 80*2 + (v_cnt-80)*560;	
						2: pixel_addr_80 = ((h_cnt-270)%80) + 80*3 + (v_cnt-80)*560;	
						3: pixel_addr_80 = ((h_cnt-270)%80) + 80*3 + (v_cnt-80)*560;	
						4: pixel_addr_80 = ((h_cnt-270)%80) + 80*4 + (v_cnt-80)*560;	
						5: pixel_addr_80 = ((h_cnt-270)%80) + 80*5 + (v_cnt-80)*560;	
						6: pixel_addr_80 = ((h_cnt-270)%80) + 80*5 + (v_cnt-80)*560;	
						7: pixel_addr_80 = ((h_cnt-270)%80) + 80*6 + (v_cnt-80)*560;	
						8: pixel_addr_80 = ((h_cnt-270)%80) + 80*6 + (v_cnt-80)*560;	
						9: pixel_addr_80 = ((h_cnt-270)%80) + 80*0 + (v_cnt-80)*560;	
						10: pixel_addr_80 = ((h_cnt-270)%80) + 80*0 + (v_cnt-80)*560;	
						11: pixel_addr_80 = ((h_cnt-270)%80) + 80*1 + (v_cnt-80)*560;		
					endcase
				end
				else if((h_cnt-270)/80 == 3) begin
					case(ChordThemeData[3]/2)
						0: pixel_addr_80 = ((h_cnt-270)%80) + 80*2 + (v_cnt-80)*560;	
						1: pixel_addr_80 = ((h_cnt-270)%80) + 80*2 + (v_cnt-80)*560;	
						2: pixel_addr_80 = ((h_cnt-270)%80) + 80*3 + (v_cnt-80)*560;	
						3: pixel_addr_80 = ((h_cnt-270)%80) + 80*3 + (v_cnt-80)*560;	
						4: pixel_addr_80 = ((h_cnt-270)%80) + 80*4 + (v_cnt-80)*560;	
						5: pixel_addr_80 = ((h_cnt-270)%80) + 80*5 + (v_cnt-80)*560;	
						6: pixel_addr_80 = ((h_cnt-270)%80) + 80*5 + (v_cnt-80)*560;	
						7: pixel_addr_80 = ((h_cnt-270)%80) + 80*6 + (v_cnt-80)*560;	
						8: pixel_addr_80 = ((h_cnt-270)%80) + 80*6 + (v_cnt-80)*560;	
						9: pixel_addr_80 = ((h_cnt-270)%80) + 80*0 + (v_cnt-80)*560;	
						10: pixel_addr_80 = ((h_cnt-270)%80) + 80*0 + (v_cnt-80)*560;	
						11: pixel_addr_80 = ((h_cnt-270)%80) + 80*1 + (v_cnt-80)*560;		
					endcase
				end
				
				pixel_addr_8_0 = 0;
				if((h_cnt-270)%80>=65 && (h_cnt-270)%80<=73 && (v_cnt-80)%80>=8 && (v_cnt-80)%80<=15) begin
					if((h_cnt-270)/80 == 0) begin
						case(ChordThemeData[0]/2)
							1: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							3: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							6: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							8: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							10: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
						endcase
					end
					else if((h_cnt-270)/80 == 1) begin
						case(ChordThemeData[1]/2)
							1: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							3: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							6: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							8: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							10: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
						endcase
					end
					else if((h_cnt-270)/80 == 2) begin
						case(ChordThemeData[2]/2)
							1: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							3: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							6: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							8: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							10: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
						endcase
					end
					else if((h_cnt-270)/80 == 3) begin
						case(ChordThemeData[3]/2)
							1: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							3: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							6: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							8: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
							10: pixel_addr_8_0 = ((h_cnt-270)%80)-65 + (v_cnt-80-8)*8;		
						endcase
					end
				end
				
				pixel_addr_8_1 = 0;
				if((h_cnt-270)%80>=65 && (h_cnt-270)%80<=73 && (v_cnt-80)%80>=65 && (v_cnt-80)%80<=73) begin
					if((h_cnt-270)/80==0 && ChordThemeData[0]%2==1 && ChordThemeData[0]!=31)
						pixel_addr_8_1 = ((h_cnt-270)%80)-65 + (v_cnt-80-65)*8;		
					else if((h_cnt-270)/80==1 && ChordThemeData[1]%2==1 && ChordThemeData[1]!=31)
						pixel_addr_8_1 = ((h_cnt-270)%80)-65 + (v_cnt-80-65)*8;	
					else if((h_cnt-270)/80==2 && ChordThemeData[2]%2==1 && ChordThemeData[2]!=31)
						pixel_addr_8_1 = ((h_cnt-270)%80)-65 + (v_cnt-80-65)*8;	
					else if((h_cnt-270)/80==3 && ChordThemeData[3]%2==1 && ChordThemeData[3]!=31)
						pixel_addr_8_1 = ((h_cnt-270)%80)-65 + (v_cnt-80-65)*8;	
				end
				
				if(pixel_80 && (h_cnt-270)%80>2) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
				else if(pixel_8_0) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
				else if(pixel_8_1) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if(h_cnt>=50 && h_cnt<= 590 && (v_cnt==310 || v_cnt==355 || v_cnt==400))
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			else if(h_cnt>=50 && h_cnt<= 590 && v_cnt>=310 && v_cnt<=400 && (h_cnt-50)%45==0)
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			else if(h_cnt>=50 && h_cnt<=590 && v_cnt>=310 && v_cnt<=400) begin
				pixel_addr_45 = 0;
				case((h_cnt-50)/45)
					0: pixel_addr_45 = ((h_cnt-50)%45) +45*2 + ((v_cnt-310)%45)*315;
					1: pixel_addr_45 = ((h_cnt-50)%45) +45*2 + ((v_cnt-310)%45)*315;
					2: pixel_addr_45 = ((h_cnt-50)%45) + 45*3 + ((v_cnt-310)%45)*315;
					3: pixel_addr_45 = ((h_cnt-50)%45) + 45*3 + ((v_cnt-310)%45)*315;
					4: pixel_addr_45 = ((h_cnt-50)%45) + 45*4 + ((v_cnt-310)%45)*315;
					5: pixel_addr_45 = ((h_cnt-50)%45) + 45*5 + ((v_cnt-310)%45)*315;
					6: pixel_addr_45 = ((h_cnt-50)%45) + 45*5 + ((v_cnt-310)%45)*315;
					7: pixel_addr_45 = ((h_cnt-50)%45) + 45*6 + ((v_cnt-310)%45)*315;
					8: pixel_addr_45 = ((h_cnt-50)%45) + 45*6 + ((v_cnt-310)%45)*315;
					9: pixel_addr_45 = ((h_cnt-50)%45) + 45*0 + ((v_cnt-310)%45)*315;
					10: pixel_addr_45 = ((h_cnt-50)%45) + 45*0 + ((v_cnt-310)%45)*315;
					11: pixel_addr_45 = ((h_cnt-50)%45) + 45*1 + ((v_cnt-310)%45)*315;
				endcase
				
				pixel_addr_8_0 = 0;
				if((h_cnt-50)%45>=33 && (h_cnt-50)%45<=40 && (v_cnt-310)%45>=3 && (v_cnt-310)%45<=10) begin
					case((h_cnt-50)/45)
						1: pixel_addr_8_0 = ((h_cnt-50)%45) - 33 + (((v_cnt-310)%45)-2)*8;
						3: pixel_addr_8_0 = ((h_cnt-50)%45) - 33 + (((v_cnt-310)%45)-2)*8;
						6: pixel_addr_8_0 = ((h_cnt-50)%45) - 33 + (((v_cnt-310)%45)-2)*8;
						8: pixel_addr_8_0 = ((h_cnt-50)%45) - 33 + (((v_cnt-310)%45)-2)*8;
						10: pixel_addr_8_0 = ((h_cnt-50)%45) - 33 + (((v_cnt-310)%45)-2)*8;
					endcase
				end
				
				pixel_addr_8_1 = 0;
				if((h_cnt-50)%45>=33 && (h_cnt-50)%45<=40 && (v_cnt-310)%45>=33 && (v_cnt-310)%45<=40 && v_cnt>=356) begin
					pixel_addr_8_1 = ((h_cnt-50)%45)-33 + ((v_cnt-310)%45-33)*8;
				end
				
				if(pixel_45 && (h_cnt-50)%45>2) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
				else if(pixel_8_0) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
				else if(pixel_8_1) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
				else if(v_cnt<=355 && Chord%2==0 && Chord==2*((h_cnt-50)/45)) {vgaRed, vgaGreen, vgaBlue} = 12'hfe9;
				else if(v_cnt>=356 && Chord%2==1 && Chord==2*((h_cnt-50)/45)+1) {vgaRed, vgaGreen, vgaBlue} = 12'hfe9;
				else begin
					case((h_cnt-50)/45)
						2: {vgaRed, vgaGreen, vgaBlue} = 12'heee;
						3: {vgaRed, vgaGreen, vgaBlue} = 12'heee;
						5: {vgaRed, vgaGreen, vgaBlue} = 12'heee;
						6: {vgaRed, vgaGreen, vgaBlue} = 12'heee;
						9: {vgaRed, vgaGreen, vgaBlue} = 12'heee;
						10: {vgaRed, vgaGreen, vgaBlue} = 12'heee;
					endcase
				end
			end
		end
		else if(screen_state == `BaseTheme) begin
			if(((h_cnt>=240 && h_cnt<=352)||(h_cnt>=464 && h_cnt<=576)) && v_cnt>=96 && v_cnt<=396) begin
				{vgaRed, vgaGreen, vgaBlue} = 12'heee;
			end
			
			if(h_cnt>=128 && h_cnt<=576 && v_cnt>=96 && v_cnt<=396 && ((h_cnt-128)%28==0 || v_cnt==96 || v_cnt==396)) begin
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if(h_cnt>=128 && h_cnt<=576 && v_cnt>=96 && v_cnt<=396 && ((v_cnt-96)%12==0 || ((h_cnt-142)%28==0 && h_cnt>=142))) begin
				{vgaRed, vgaGreen, vgaBlue} = 12'h666;
			end
			else if((h_cnt==110 && v_cnt>=96 && v_cnt<=396)) begin
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if((v_cnt==96 || v_cnt==108 || v_cnt==192 || v_cnt==252 || v_cnt==336 || v_cnt==396) && h_cnt>=110 && h_cnt<=128) begin
				{vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if(h_cnt>=12 && h_cnt<=101 && v_cnt>=195 && v_cnt<=284) begin
				pixel_addr_base = h_cnt-12 + (v_cnt-195)*90;
				if(pixel_base && h_cnt>14) {vgaRed, vgaGreen, vgaBlue} = 12'h000;
			end
			else if(h_cnt>=110 && h_cnt<=120 && v_cnt>=96 && v_cnt<=396) begin
				case((v_cnt-96)/12)
					2: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					4: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					6: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					9: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					11: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					14: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					16: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					18: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					21: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					23: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					default: {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
				endcase
			end
			else if(h_cnt>=120 && h_cnt<=128 && v_cnt>=96 && v_cnt<=396 && (v_cnt-126)%12==0) begin
				case((v_cnt-126)/12)
					0: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					2: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					4: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					7: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					9: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					12: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					14: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					16: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					19: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					21: {vgaRed, vgaGreen, vgaBlue} = 12'h000;
					default: {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
				endcase
			end
			else if(h_cnt>=128 && h_cnt<=576 && v_cnt>=96 && v_cnt<=396 && BaseThemeData[(h_cnt-128)/14]==(v_cnt-96)/12) begin
				if(play_state != `PlayInit && play_cnt==(h_cnt-128)/14) {vgaRed, vgaGreen, vgaBlue} = 12'he84;
				else {vgaRed, vgaGreen, vgaBlue} = 12'h941;
			end
		end
    end
end

endmodule
