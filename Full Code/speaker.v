//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/03 04:24:09
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define silence   32'd100000000


module speaker(
    clk, // clock from crystal
    rst, // active high reset: BTNC
    HomeScreenVolume,
    MainThemeVolume,
    ChordThemeVolume,
    BassThemeVolume,
    BeatThemeVolume,
    MainThemeOut,
    ChordThemeOut,
    BassThemeOut,
    BeatThemeOut,
    audio_mclk, // master clock
    audio_lrck, // left-right clock
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
    
    input [2:0] HomeScreenVolume;
    input [2:0] MainThemeVolume;
    input [2:0] ChordThemeVolume;
    input [2:0] BassThemeVolume;
    input [2:0] BeatThemeVolume;
    input [4:0] MainThemeOut;
    input [4:0] ChordThemeOut;
    input [4:0] BassThemeOut;
    input [1:0] BeatThemeOut;
    
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
    
    wire [15:0] audio_in_left, audio_in_right;
    wire [15:0] audio_in_left_2, audio_in_right_2;
    wire [15:0] audio_in_left_3, audio_in_right_3;
    
    wire clkDiv22, clkDiv16, clkDiv13;
    wire [31:0] freq_main, freq_chord_1, freq_chord_2, freq_chord_3, freq_bass, freq_beat; // Raw frequency, produced by music module
    wire [21:0] freqout_main, freqout_chord_1, freqout_chord_2, freqout_chord_3, freqout_bass, freqout_beat; // Processed Frequency, adapted to the clock rate_L of Basys3
    
    reg [4:0] pMainThemeOut;
    reg [4:0] pChordThemeOut;
    reg [4:0] pBassThemeOut;
    reg [1:0] pBeatThemeOut;
    /*
    reg newpulse_main;
    reg newpulse_chord;
    reg newpulse_bass;
    reg newpulse_beat;*/
    
    wire newpulse_main = (freq_main != `silence);
    wire newpulse_chord = (freq_chord_1 != `silence);
    wire newpulse_bass = (freq_bass != `silence);
    wire newpulse_beat = (freq_beat != `silence);
    
    
    
    reg [31:0] rdm_freq;
    reg [1:0]  prev_beat;
    
    Main_decoder mn(.MainThemeOut(MainThemeOut), .MainHz(freq_main));
    Bass_decoder bs(.BassThemeOut(BassThemeOut), .BassHz(freq_bass));
    Chord1_decoder c1(.ChordThemeOut(ChordThemeOut), .Chord1Hz(freq_chord_1));
    Chord2_decoder c2(.ChordThemeOut(ChordThemeOut), .Chord2Hz(freq_chord_2));
    Chord3_decoder c3(.ChordThemeOut(ChordThemeOut), .Chord3Hz(freq_chord_3));
    assign freq_beat = (BeatThemeOut == 0)? `silence : rdm_freq;
    
    assign freqout_main = 100000000 / freq_main;
    assign freqout_chord_1 = 100000000 / freq_chord_1;
    assign freqout_chord_2 = 100000000 / freq_chord_2;
    assign freqout_chord_3 = 100000000 / freq_chord_3;
    assign freqout_bass = 100000000 / freq_bass;
    assign freqout_beat = 100000000 / freq_beat;

    always@(posedge clkDiv22, posedge rst) begin
        prev_beat = prev_beat;
        rdm_freq = rdm_freq;
        
        if (rst) 
            prev_beat = 2'b00;
        
        else if (prev_beat != BeatThemeOut) begin
            prev_beat = BeatThemeOut;
            if (prev_beat == 2'b01)          //BassDrum
                rdm_freq = 150;
            else if (prev_beat == 2'b00)     //snare
                rdm_freq = 250 /*+ ($random)%100*/;
            else
                rdm_freq = `silence;
                
        end else begin
        
            if (prev_beat == 2'b01) begin         //BassDrum
                if (rdm_freq > 20)
                    rdm_freq = rdm_freq - 32'd10;
            end else if (prev_beat == 2'b00)     //snare
                if (rdm_freq > 150)
                    rdm_freq = rdm_freq - 32'd10 /*+ ($random)%100*/;
                
        end
    end
    /*
    always@(posedge clkDiv22,posedge rst) begin
    
            newpulse_main = 0;
            newpulse_chord = 0;
            newpulse_bass = 0;
            newpulse_beat = 0;
        if(rst) begin
            pMainThemeOut = 0;
            pChordThemeOut = 0;
            pBassThemeOut = 0;
            pBeatThemeOut = 0;
            
            newpulse_main = 0;
            newpulse_chord = 0;
            newpulse_bass = 0;
            newpulse_beat = 0;
        end else begin
            if(MainThemeOut != pMainThemeOut) begin
                pMainThemeOut = MainThemeOut;
                if(freq_main!=`silence) newpulse_main = 1;
            end
            if(ChordThemeOut != pChordThemeOut) begin
                pChordThemeOut = ChordThemeOut;
                if(freq_chord_1!=`silence) newpulse_chord = 1;
            end
            if(BassThemeOut != pBassThemeOut) begin
                pBassThemeOut = BassThemeOut;
                if(freq_bass!=`silence) newpulse_bass = 1;
            end
            if(BeatThemeOut != pBeatThemeOut) begin
                pBeatThemeOut = BeatThemeOut;
                if(freq_beat!=`silence) newpulse_beat = 1;
            end
        end
    end
*/

    clock_divider #(.n(22)) clock_22(
        .clk(clk),
        .clk_div(clkDiv22)
    );
    
    clock_divider #(.n(16)) clock_16(
        .clk(clk),
        .clk_div(clkDiv16)
    );
    
    clock_divider #(.n(13)) clock_13(
        .clk(clk),
        .clk_div(clkDiv13)
    );
    
    // Note generation
    // [in]  processed frequency
    // [out] audio wave signal (using square wave here)
    note_gen noteGen_00(
        .clk(clk), // clock from crystal
        .rst(rst), // active high reset
        .freqout_main(freqout_main), 
        .freqout_chord_1(freqout_chord_1), 
        .freqout_chord_2(freqout_chord_2), 
        .freqout_chord_3(freqout_chord_3),
        .freqout_bass(freqout_bass), 
        .freqout_beat(freqout_beat),
        
        .newpulse_main(newpulse_main),
        .newpulse_chord(newpulse_chord),
        .newpulse_bass(newpulse_bass),
        .newpulse_beat(newpulse_beat),
        
        
        .HomeScreenVolume(HomeScreenVolume),
        .MainThemeVolume(MainThemeVolume),
        .ChordThemeVolume(ChordThemeVolume),
        .BassThemeVolume(BassThemeVolume),
        .BeatThemeVolume(BeatThemeVolume),
            
        .audio_left(audio_in_left), // left sound audio
        .audio_right(audio_in_right),
        .audio_left_2(audio_in_left_2), // left sound audio
        .audio_right_2(audio_in_right_2),
        .audio_left_3(audio_in_left_3), // left sound audio
        .audio_right_3(audio_in_right_3)
        
    );

    // Speaker controller
    speaker_control sc(
        .clk(clk),  // clock from the crystal
        .rst(rst),  // active high reset
        
        .audio_in_left(audio_in_left), // left channel audio data input
        .audio_in_right(audio_in_right), // right channel audio data input
        .audio_in_left_2(audio_in_left_2), // left channel audio data input
        .audio_in_right_2(audio_in_right_2), // right channel audio data input
        .audio_in_left_3(audio_in_left_3), // left channel audio data input
        .audio_in_right_3(audio_in_right_3), // right channel audio data input
        
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

endmodule
