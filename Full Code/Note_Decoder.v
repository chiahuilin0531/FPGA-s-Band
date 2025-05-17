`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/05 20:19:51
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




`define llc   32'd65   // C1
`define llcs  32'd69   // C#1
`define lld   32'd73   // D1
`define llds  32'd78   // Eb1
`define lle   32'd82   // E1
`define llf   32'd87   // F1
`define llfs  32'd92  // F#1
`define llg   32'd98   // G1
`define llgs  32'd104   // G#1
`define lla   32'd110   // A1
`define llas  32'd117   // Bb1
`define llb   32'd123   // B1

`define lc   32'd131   // C2
`define lcs  32'd139   // C#2
`define ld   32'd147   // D2
`define lds  32'd156   // Eb2
`define le   32'd165   // E2
`define lf   32'd175   // F2
`define lfs  32'd185   // F#2
`define lg   32'd196   // G2
`define lgs  32'd207   // G#2
`define la   32'd220   // A2
`define las  32'd233   // Bb2
`define lb   32'd247   // B2

`define c   32'd262   // C3
`define cs  32'd277   // C#3
`define d   32'd294   // D3
`define ds  32'd311   // Eb3
`define e   32'd330   // E3
`define f   32'd349   // F3
`define fs  32'd370   //F#3
`define g   32'd392   // G3
`define gs  32'd415   // G#3
`define a   32'd440   // A3
`define as  32'd466   // Bb3
`define b   32'd494   // B3

`define hc  32'd524   // C4
`define hcs 32'd554   // Cs4
`define hd  32'd588   // D4
`define hds 32'd622   // Eb4
`define he  32'd660   // E4
`define hf  32'd698   // F4
`define hfs 32'd740   // F4
`define hg  32'd784   // G4
`define hgs 32'd831   // G4
`define ha  32'd880   // A4
`define has 32'd933   // Bb4
`define hb  32'd988   // B4

`define hhc 32'd1047  //C5

`define sil   32'd100000000 // slience

module Bass_decoder(
	input [4:0] BassThemeOut,
	output reg [31:0] BassHz
);
    
    always@(*) begin
        case(BassThemeOut)
            0: BassHz = `llc;
            1: BassHz = `llcs;
            2: BassHz = `lld;
            3: BassHz = `llds;
            4: BassHz = `lle;
            5: BassHz = `llf;
            6: BassHz = `llfs;
            7: BassHz = `llg;
            8: BassHz = `llgs;
            9: BassHz = `lla;
            10: BassHz = `llas;
            11: BassHz = `llb;
            12: BassHz = `lc;
            13: BassHz = `lcs;
            14: BassHz = `ld;
            15: BassHz = `lds;
            16: BassHz = `le;
            17: BassHz = `lf;
            18: BassHz = `lfs;
            19: BassHz = `lg;
            20: BassHz = `lgs;
            21: BassHz = `la;
            22: BassHz = `las;
            23: BassHz = `lb;
            24: BassHz = `c;
            
            default: BassHz = `sil;
        endcase
    end

endmodule


module Main_decoder(
	input [4:0] MainThemeOut,
	output reg [31:0] MainHz
);
    
    always@(*) begin
        case(MainThemeOut)
            0: MainHz = `c;
            1: MainHz = `cs;
            2: MainHz = `d;
            3: MainHz = `ds;
            4: MainHz = `e;
            5: MainHz = `f;
            6: MainHz = `fs;
            7: MainHz = `g;
            8: MainHz = `gs;
            9: MainHz = `a;
            10: MainHz = `as;
            11: MainHz = `b;
            12: MainHz = `hc;
            13: MainHz = `hcs;
            14: MainHz = `hd;
            15: MainHz = `hds;
            16: MainHz = `he;
            17: MainHz = `hf;
            18: MainHz = `hfs;
            19: MainHz = `hg;
            20: MainHz = `hgs;
            21: MainHz = `ha;
            22: MainHz = `has;
            23: MainHz = `hb;
            24: MainHz = `hhc;
            
            default: MainHz = `sil;
        endcase
    end

endmodule


module Chord1_decoder(
	input [4:0] ChordThemeOut,
	output reg [31:0] Chord1Hz
);
    
    always@(*) begin
        case(ChordThemeOut)
            0: Chord1Hz = `lc;
            1: Chord1Hz = `lc;
            2: Chord1Hz = `lcs;
            3: Chord1Hz = `lcs;
            4: Chord1Hz = `ld;
            5: Chord1Hz = `ld;
            6: Chord1Hz = `lds;
            7: Chord1Hz = `lds;
            8: Chord1Hz = `le;
            9: Chord1Hz = `le;
            10: Chord1Hz = `lf;
            11: Chord1Hz = `lf;
            12: Chord1Hz = `lfs;
            13: Chord1Hz = `lfs;
            14: Chord1Hz = `lg;
            15: Chord1Hz = `lg;
            16: Chord1Hz = `lgs;
            17: Chord1Hz = `lgs;
            18: Chord1Hz = `la;
            19: Chord1Hz = `la;
            20: Chord1Hz = `las;
            21: Chord1Hz = `las;
            22: Chord1Hz = `lb;
            23: Chord1Hz = `lb;
            
            default: Chord1Hz = `sil;
        endcase
    end

endmodule


module Chord2_decoder(
	input [4:0] ChordThemeOut,
	output reg [31:0] Chord2Hz
);
    
    always@(*) begin
        case(ChordThemeOut)
			0: Chord2Hz = `le;   1: Chord2Hz = `lds;
            2: Chord2Hz = `lf;   3: Chord2Hz = `le;
            4: Chord2Hz = `lfs;  5: Chord2Hz = `lf;
            6: Chord2Hz = `lg;   7: Chord2Hz = `lfs;
            8: Chord2Hz = `lgs;  9: Chord2Hz = `lg;
            10: Chord2Hz = `la;  11: Chord2Hz = `lgs;
            12: Chord2Hz = `las; 13: Chord2Hz = `la;
            14: Chord2Hz = `lb;  15: Chord2Hz = `las;
            16: Chord2Hz = `c;   17: Chord2Hz = `lb;
            18: Chord2Hz = `cs;  19: Chord2Hz =  `c; 
            20: Chord2Hz = `d;   21: Chord2Hz =  `cs;
            22: Chord2Hz = `ds;  23: Chord2Hz = `d;
            
            default: Chord2Hz = `sil;
        endcase
    end

endmodule


module Chord3_decoder(
	input [4:0] ChordThemeOut,
	output reg [31:0] Chord3Hz
);
    
    always@(*) begin
        case(ChordThemeOut)
            0: Chord3Hz = `lg;
            1: Chord3Hz = `lg;
            2: Chord3Hz = `lgs;
            3: Chord3Hz = `lgs;
            4: Chord3Hz = `la;
            5: Chord3Hz = `la;
            6: Chord3Hz = `las;
            7: Chord3Hz = `las;
            8: Chord3Hz = `lb;
            9: Chord3Hz = `lb;
            10: Chord3Hz = `c;
            11: Chord3Hz = `c;
            12: Chord3Hz = `cs;
            13: Chord3Hz = `cs;
            14: Chord3Hz = `d;
            15: Chord3Hz = `d;
            16: Chord3Hz = `ds;
            17: Chord3Hz = `ds;
            18: Chord3Hz = `e;
            19: Chord3Hz = `e;
            20: Chord3Hz = `f;
            21: Chord3Hz = `f;
            22: Chord3Hz = `fs;
            23: Chord3Hz = `fs;
            
            default: Chord3Hz = `sil;
        endcase
    end

endmodule