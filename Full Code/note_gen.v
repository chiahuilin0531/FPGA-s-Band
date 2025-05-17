module note_gen(
    clk, // clock from crystal
    rst, // active high reset
    
    freqout_main, 
    freqout_chord_1, 
    freqout_chord_2, 
    freqout_chord_3,
    freqout_bass, 
    freqout_beat,
    
    newpulse_main,
    newpulse_chord,
    newpulse_bass,
    newpulse_beat,
    
    HomeScreenVolume,
    MainThemeVolume,
    ChordThemeVolume,
    BassThemeVolume,
    BeatThemeVolume,
    
    audio_left,
    audio_right,
    audio_left_2,
    audio_right_2,
    audio_left_3,
    audio_right_3
);

    // I/O declaration
    input clk; // clock from crystal
    input rst; // active low reset
    input [21:0] freqout_main, freqout_chord_1, freqout_chord_2, freqout_chord_3, freqout_bass, freqout_beat;
    input [2:0] HomeScreenVolume, MainThemeVolume, ChordThemeVolume, BassThemeVolume, BeatThemeVolume;
    input newpulse_main, newpulse_chord, newpulse_bass, newpulse_beat;
    
    output reg [15:0] audio_left, audio_right;
    output reg [15:0] audio_left_2, audio_right_2;
    output reg [15:0] audio_left_3, audio_right_3;
    
    
    // Declare internal signals
    
    wire clkDiv16, clkDiv22;
    
    clock_divider #(.n(16)) clock_16(
        .clk(clk),
        .clk_div(clkDiv16)
    );
    
    clock_divider #(.n(22)) clock_22(
        .clk(clk),
        .clk_div(clkDiv22)
    );
    
    
    parameter [15:0] sine [0:23] = {
        16'h0000, 16'h02D5, 16'h0578, 16'h07BC, 16'h0979, 16'h0A91, 
        16'h0AF0, 16'h0A91, 16'h0979, 16'h07BC, 16'h0578, 16'h02D5, 
        16'h0000, 16'hFD2B, 16'hFA88, 16'hF844, 16'hF687, 16'hF56F, 
        16'hF510, 16'hF56F, 16'hF687, 16'hF844, 16'hFA88, 16'hFD2B
        
    };
    
	parameter [15:0] keyboard [0:41] = {
		16'h0AAE, 16'h0A60, 16'h0A12, 16'h0976, 16'h088C, 
		16'h0753, 16'h05CC, 16'h0446, 16'h02BF, 16'h0187,

		16'h004E, 16'hFF64, 16'hFEC8, 16'hFE2B, 16'hFD8F,
		16'hFCF3, 16'hFCA5, 16'hFC08, 16'hFB1E, 16'hF9E6,
		
		16'hF8FB, 16'hF85F, 16'hF7C3, 16'hF7C3, 16'hF774,
		16'hF726, 16'hF7C3, 16'hF85F, 16'hF8FB, 16'hF997,

		16'hFA82, 16'hFBBA, 16'hFD41, 16'hFF16, 16'h00EA,
		16'h0271, 16'h0446, 16'h061A, 16'h07A1, 16'h0928,

		16'h0A60, 16'h0AEE
	};
	
	parameter [15:0] guitar [0:54] = {
		16'h0019, 16'h05FE, 16'h0611, 16'h05B4, 16'h04CD, 
		16'h038D, 16'h02EE, 16'h0219, 16'h0177, 16'h01C2,

		16'h00B4, 16'h043A, 16'h07CF, 16'h0890, 16'h094B,
		16'h0AED, 16'h0D56, 16'h0CFA, 16'h0945, 16'h08AE,
		
		16'h0936, 16'h0AC8, 16'h0D6E, 16'h0E21, 16'h0D98,
		16'h0B5F, 16'h0AA0, 16'h097C, 16'h02E9, 16'h00BC,

		16'hFE1B, 16'hFE64, 16'hFBB6, 16'hFA2A, 16'hF87C, 
		16'hF9E2, 16'hF8F2, 16'hF7A6, 16'hF2BB, 16'hF378, 
		
		16'hF2FA, 16'hF1AB, 16'hF2AC, 16'hF6C4, 16'hF921, 
		16'hFA22, 16'hFCCD, 16'hFC8D, 16'hFB6D, 16'hFD59, 
		
		16'hFF0C, 16'hFEA4, 16'hFA53, 16'hFB40, 16'h006F 
	};

//-----------------------------------------------------------------------------------------------


    reg [21:0] main, next_main;
    reg [21:0] bass, next_bass;
    reg [21:0] beat, next_beat;
    reg [21:0] chord_1, next_chord_1;
    reg [21:0] chord_2, next_chord_2;
    reg [21:0] chord_3, next_chord_3;

    reg [9:0] cnt_ADSR, next_cnt_ADSR;
    reg [9:0] cnt_ADSR_chord, next_cnt_ADSR_chord;
    reg [9:0] cnt_ADSR_bass, next_cnt_ADSR_bass;
    reg [9:0] cnt_ADSR_beat, next_cnt_ADSR_beat;
    
    reg /*signed*/ [5:0] rate_main, next_rate_main;
    reg [5:0] rate_chord, next_rate_chord;
    reg [5:0] rate_bass, next_rate_bass;
    reg [5:0] rate_beat, next_rate_beat;
    
    reg [1:0] ADSR_main, next_ADSR_main;
    reg [1:0] ADSR_chord, next_ADSR_chord;
    reg [1:0] ADSR_bass, next_ADSR_bass;
    reg [1:0] ADSR_beat, next_ADSR_beat;
    
    parameter [1:0] A = 2'b0, D = 2'd1, S = 2'd2, R = 2'd3;

    always@(posedge clkDiv22, posedge rst) begin
        if(rst) begin
            ADSR_main = A;
            rate_main = 9;
            cnt_ADSR = 0;
            
            ADSR_bass = S;
            rate_bass = 7;
            cnt_ADSR_bass = 0;
            
            ADSR_chord = S;
            rate_chord = 7;
            cnt_ADSR_chord = 0;
            
            ADSR_beat = S;
            rate_beat = 9;
            cnt_ADSR_beat = 0;

            main = 1;
            bass = 1;
            beat = 1;
            chord_1 = 1;
            chord_2 = 1;
            chord_3 = 1;

        end else begin

            main = next_main;
            bass = next_bass;
            beat = next_beat;
            chord_1 = next_chord_1;
            chord_2 = next_chord_2;
            chord_3 = next_chord_3;

            rate_main = next_rate_main;
            ADSR_main = next_ADSR_main;
            cnt_ADSR = next_cnt_ADSR;
            
            rate_chord = next_rate_chord;
            ADSR_chord = next_ADSR_chord;
            cnt_ADSR_chord = next_cnt_ADSR_chord;
            
            
            rate_bass = next_rate_bass;
            ADSR_bass = next_ADSR_bass;
            cnt_ADSR_bass = next_cnt_ADSR_bass;
        end
    end
    
    //main
    always@* begin
        next_rate_main = rate_main;
        next_ADSR_main = ADSR_main;
        next_main = main;
        next_cnt_ADSR = cnt_ADSR;
        if (newpulse_main/* || main != freqout_main) && freqout_main != 1*/) begin
            next_ADSR_main = A;
            next_rate_main = 9;
            next_main = freqout_main;
            next_cnt_ADSR = 0;
        end else
            case(ADSR_main)
                A: begin
                    if(rate_main >= 10) begin
                        next_ADSR_main = D;
                    end else begin
                        next_rate_main = rate_main + 1;
                    end
                end
                D: begin
                    if(rate_main <= 7) begin
                        next_ADSR_main = S;
                    end else begin
                        next_rate_main = rate_main - 6'd1;
                    end
                end
                S: begin
                    if (cnt_ADSR > 20) next_ADSR_main = R;
                    else next_cnt_ADSR = cnt_ADSR + 1;
                end
                R: begin
                    if(rate_main > 1) begin
                        next_rate_main = rate_main - 6'd1;
                    end else
                        next_rate_main = 6'd0;
                end
            endcase
    end
    
    //chord
    
    
    always@* begin
        next_rate_chord = rate_chord;
        next_ADSR_chord = ADSR_chord;
        next_chord_1 = chord_1;
        next_chord_2 = chord_2;
        next_chord_3 = chord_3;
        next_cnt_ADSR_chord = cnt_ADSR_chord;
        if (newpulse_chord/* || chord_1 != freqout_chord_1) && freqout_chord_1 != 1*/) begin
            next_ADSR_chord = S;
            next_rate_chord = 7;
            next_chord_1 = freqout_chord_1;
            next_chord_2 = freqout_chord_2;
            next_chord_3 = freqout_chord_3;
            next_cnt_ADSR_chord = 0;
        end else
            case(ADSR_chord)
//                A: begin
//                    if(rate_chord >= 10) begin
//                        next_ADSR_chord = D;
//                    end else begin
//                        next_rate_chord = rate_chord + 1;
//                    end
//                end
//                D: begin
//                    if(rate_chord <= 7) begin
//                        next_ADSR_chord = S;
//                    end else begin
//                        next_rate_chord = rate_chord - 6'd1;
//                    end
//                end
                S: begin
                    if (cnt_ADSR_chord > 20) next_ADSR_chord = R;
                    else next_cnt_ADSR_chord = cnt_ADSR_chord + 1;
                end
                R: begin
                    if(rate_chord > 1) begin
                        next_rate_chord = rate_chord - 6'd1;
                    end else
                        next_rate_chord = 6'd0;
                end
            endcase
    end
    
    /*
    always@* begin
        next_chord_1 = chord_1;
        next_chord_2 = chord_2;
        next_chord_3 = chord_3;
        if (freqout_chord_1 != 1) begin
            if (newpulse_chord) begin
    
                next_chord_1 = freqout_chord_1;
                next_chord_2 = freqout_chord_2;
                next_chord_3 = freqout_chord_3;
            end
        end 
    end*/

    //bass
    
    
    always@* begin
        next_rate_bass = rate_bass;
        next_ADSR_bass = ADSR_bass;
        next_bass = bass;
        next_cnt_ADSR_bass = cnt_ADSR_bass;
        if (newpulse_bass /*|| bass != freqout_bass) && freqout_bass != 1*/) begin
            next_ADSR_bass = A;
            next_rate_bass = 9;
            next_bass = freqout_bass;
            next_cnt_ADSR_bass = 0;
        end else
            case(ADSR_bass)
                A: begin
                    if(rate_bass >= 10) begin
                        next_ADSR_bass = D;
                    end else begin
                        next_rate_bass = rate_bass + 1;
                    end
                end
                D: begin
                    if(rate_bass <= 7) begin
                        next_ADSR_bass = S;
                    end else begin
                        next_rate_bass = rate_bass - 6'd1;
                    end
                end
                S: begin
                    if (cnt_ADSR_bass > 20) next_ADSR_bass = R;
                    else next_cnt_ADSR_bass = cnt_ADSR_bass + 1;
                end
                R: begin
                    if(rate_bass > 1) begin
                        next_rate_bass = rate_bass - 6'd1;
                    end else next_rate_bass = 0;
                end
            endcase
    end
//    always@* begin
//        next_bass = bass;
//        if (freqout_bass != 1)
//            if (bass!= freqout_bass) begin
//                next_bass = freqout_bass;
//            end
//    end
    
    
    //beat
    
    /*
    always@* begin
        next_rate_beat = rate_beat;
        next_ADSR_beat = ADSR_beat;
        next_beat = beat;
        next_cnt_ADSR_beat = cnt_ADSR_beat;
        if ((newpulse_beat ||beat != freqout_beat)&& freqout_beat != 1) begin
            next_ADSR_beat = S;
            next_rate_beat = 10;
            next_beat = freqout_beat;
            next_cnt_ADSR_beat = 0;
        end else
            case(ADSR_beat)
                A: begin
                    if(rate_beat >= 10) begin
                        next_ADSR_beat = D;
                    end else begin
                        next_rate_beat = rate_beat + 1;
                    end
                end
                D: begin
                    if(rate_beat <= 7) begin
                        next_ADSR_beat = S;
                    end else begin
                        next_rate_beat = rate_beat - 6'd1;
                    end
                end
                S: begin
                    if (cnt_ADSR_beat > 20) next_ADSR_beat = R;
                    else next_cnt_ADSR_beat = cnt_ADSR_beat + 1;
                end
                R: begin
                    if(rate_beat > 0) begin
                        next_rate_beat = rate_beat - 6'd1;
                    end
                end
            endcase
    end
    */
    
    always@* begin
        next_beat = beat;
        if (freqout_beat != 1) begin
            if (beat!= freqout_beat) begin
                next_beat = freqout_beat;
            end
        end
    end
    
//-----------------------------------------------------------------------------------------------

    // Note frequency generation

    reg [21:0] clk_cnt_main_next, clk_cnt_main;
    reg [21:0] clk_cnt_chord1_next, clk_cnt_chord1;
    reg [21:0] clk_cnt_chord2_next, clk_cnt_chord2;
    reg [21:0] clk_cnt_chord3_next, clk_cnt_chord3;
    reg [21:0] clk_cnt_bass_next, clk_cnt_bass;
    reg [21:0] clk_cnt_beat_next, clk_cnt_beat;

    reg [21:0] clk_cnt_next_2, clk_cnt_2;
    reg [21:0] clk_cnt_next_BD, clk_cnt_BD;

    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            begin
                clk_cnt_main <= 22'd0;
                clk_cnt_chord1 <= 22'd0;
                clk_cnt_chord2 <= 22'd0;
                clk_cnt_chord3 <= 22'd0;
                clk_cnt_bass <= 22'd0;
                clk_cnt_beat <= 22'd0;
            end
        else
            begin
                clk_cnt_main <= clk_cnt_main_next;
                clk_cnt_chord1 <= clk_cnt_chord1_next;
                clk_cnt_chord2 <= clk_cnt_chord2_next;
                clk_cnt_chord3 <= clk_cnt_chord3_next;
                clk_cnt_bass <= clk_cnt_bass_next;
                clk_cnt_beat <= clk_cnt_beat_next;
            end
        
    always @*
        if (clk_cnt_chord1 == chord_1)
            clk_cnt_chord1_next = 22'd0;
        else
            clk_cnt_chord1_next = clk_cnt_chord1 + 1'b1;

    always @*
        if (clk_cnt_chord2 == chord_2)
            clk_cnt_chord2_next = 22'd0;
        else
            clk_cnt_chord2_next = clk_cnt_chord2 + 1'b1;

    always @*
        if (clk_cnt_chord3 == chord_3)
            clk_cnt_chord3_next = 22'd0;
        else
            clk_cnt_chord3_next = clk_cnt_chord3 + 1'b1;

    always @*
        if (clk_cnt_main == main)
            clk_cnt_main_next = 22'd0;
        else
            clk_cnt_main_next = clk_cnt_main + 1'b1;
            
    always @*
        if (clk_cnt_bass == bass)
            clk_cnt_bass_next = 22'd0;
        else
            clk_cnt_bass_next = clk_cnt_bass + 1'b1;
    always @*
        if (clk_cnt_beat == beat)
            clk_cnt_beat_next = 22'd0;
        else
            clk_cnt_beat_next = clk_cnt_beat + 1'b1;
            
//-------------------------------------------------------------------------------------------

    // Assign the amplitude of the note
    // Volume is controlled here
     
    wire [21:0] main_index, bass_index, beat_index;
    wire [21:0] chord_index_1, chord_index_2, chord_index_3;
    
    assign main_index = clk_cnt_main /(main/42);
    assign chord_index_1 = clk_cnt_chord1 /(chord_1/42);
    assign chord_index_2 = clk_cnt_chord2 /(chord_2/42);
    assign chord_index_3 = clk_cnt_chord3 /(chord_3/42);
    assign bass_index = clk_cnt_bass /(bass/55);
    assign beat_index = clk_cnt_beat /(freqout_beat/24);
     
     
     
     // main
    always@* begin
        if (main == 22'd1) begin
            audio_right = 16'h0000;
        end else begin
            case (MainThemeVolume)
                5: audio_right = ($signed(keyboard[main_index]) >>>1)*$signed(rate_main);
                4: audio_right = ($signed(keyboard[main_index]) >>>1)*$signed(rate_main);
                3: audio_right = ($signed(keyboard[main_index]) >>>2)*$signed(rate_main);
                2: audio_right = ($signed(keyboard[main_index]) >>>3)*$signed(rate_main);
                1: audio_right = ($signed(keyboard[main_index]) >>>3)*$signed(rate_main);
                0: audio_right = 16'h0000;
                default: audio_right = ($signed(keyboard[main_index]) >>>3) *$signed(rate_main);
            endcase
        end
    end
    
    //chord 3
    always@* begin
        if (chord_3 == 22'd1) begin
            audio_left = 16'h0000;
        end else begin
            case (ChordThemeVolume)
                5: audio_left = ($signed(keyboard[chord_index_3]) >>>1)*$signed(rate_chord);
                4: audio_left = ($signed(keyboard[chord_index_3]) >>>1)*$signed(rate_chord);
                3: audio_left = ($signed(keyboard[chord_index_3]) >>>2)*$signed(rate_chord);
                2: audio_left = ($signed(keyboard[chord_index_3]) >>>3)*$signed(rate_chord);
                1: audio_left = ($signed(keyboard[chord_index_3]) >>>3)*$signed(rate_chord);
                0: audio_left = 16'h0000;
                default: audio_left = ($signed(keyboard[chord_index_3]) >>>3) *$signed(rate_chord);
            endcase
        end
    end
    
    // chord2
    always@* begin
        if (chord_2 == 22'd1) begin
            audio_left_3 = 16'h0000;
        end else begin
            case (ChordThemeVolume)
                5: audio_left_3 = ($signed(keyboard[chord_index_2]) >>>1)*$signed(rate_chord);
                4: audio_left_3 = ($signed(keyboard[chord_index_2]) >>>1)*$signed(rate_chord);
                3: audio_left_3 = ($signed(keyboard[chord_index_2]) >>>2)*$signed(rate_chord);
                2: audio_left_3 = ($signed(keyboard[chord_index_2]) >>>3)*$signed(rate_chord);
                1: audio_left_3 = ($signed(keyboard[chord_index_2]) >>>3)*$signed(rate_chord);
                0: audio_left_3 = 16'h0000;
                default: audio_left_3 = ($signed(keyboard[chord_index_2]) >>>3) *$signed(rate_chord);
            endcase
        end
    end
    
    // chord1
    always@* begin
        if (chord_1 == 22'd1) begin
            audio_right_3 = 16'h0000;
        end else begin
            case (ChordThemeVolume)
                5: audio_right_3 = ($signed(keyboard[chord_index_1]) >>>1)*$signed(rate_chord);
                4: audio_right_3 = ($signed(keyboard[chord_index_1]) >>>1)*$signed(rate_chord);
                3: audio_right_3 = ($signed(keyboard[chord_index_1]) >>>2)*$signed(rate_chord);
                2: audio_right_3 = ($signed(keyboard[chord_index_1]) >>>3)*$signed(rate_chord);
                1: audio_right_3 = ($signed(keyboard[chord_index_1]) >>>3)*$signed(rate_chord);
                0: audio_right_3 = 16'h0000;
                default: audio_right_3 = ($signed(keyboard[chord_index_1]) >>>3) *$signed(rate_chord);
            endcase
        end
    end
    
    // beat
    always@* begin
        if (beat == 22'd1) begin
            audio_left_2 = 16'h0000;
        end else begin
            case (BeatThemeVolume)
                5: audio_left_2 = ($signed(sine[beat_index]) <<<3);
                4: audio_left_2 = ($signed(sine[beat_index]) <<<2);
                3: audio_left_2 = ($signed(sine[beat_index]) <<<1);
                2: audio_left_2 = ($signed(sine[beat_index]) );
                1: audio_left_2 = ($signed(sine[beat_index]) >>>1);
                0: audio_left_2 = 16'h0000;
                default: audio_left_2 = ($signed(sine[beat_index]) >>>1)*5'b01000;
            endcase
        end
    end
    
    //bass
    always@* begin
        if (bass == 22'd1) begin
            audio_right_2 = 16'h0000;
        end else begin
            case (BassThemeVolume)
                5: audio_right_2 = ($signed(guitar[bass_index]) >>>1)*$signed(rate_bass);
                4: audio_right_2 = ($signed(guitar[bass_index]) >>>1)*$signed(rate_bass);
                3: audio_right_2 = ($signed(guitar[bass_index]) >>>2)*$signed(rate_bass);
                2: audio_right_2 = ($signed(guitar[bass_index]) >>>3)*$signed(rate_bass);
                1: audio_right_2 = ($signed(guitar[bass_index]) >>>3)*$signed(rate_bass);
                0: audio_right_2 = 16'h0000;
                default: audio_right_2 = ($signed(guitar[bass_index]) >>>3)*$signed(rate_bass);
            endcase
        end
    end
    
endmodule