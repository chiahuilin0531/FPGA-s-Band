module segment_display(
  input clk,
  input [2:0] screen_state,
  input [4:0] MusicOut,
  output reg [3:0] AN,
  output [6:0] SEG
);
`define HomeScreen 3'b000
`define MainTheme  3'b001
`define ChordTheme 3'b010
`define BaseTheme  3'b011
`define BeatTheme  3'b100

reg [3:0] AN_next;
reg [6:0] DIGIT0, DIGIT1, DIGIT2;


always@(posedge clk)begin
  AN <= AN_next;
end

always@(*)begin
  AN_next = 4'b1110;
  if(AN==4'b1110) begin
    AN_next = 4'b1101;
  end else if(AN==4'b1101) begin
    AN_next = 4'b1011;
  end else if(AN==4'b1011) begin
    AN_next = 4'b1110;
  end
end

assign SEG = (AN==4'b1110) ? DIGIT0:
               (AN==4'b1101) ? DIGIT1:
               (AN==4'b1011) ? DIGIT2:
                              7'b1111111;

always@(*)begin
	case(MusicOut)
		1: DIGIT0 = 7'b0011100;
		3: DIGIT0 = 7'b0011100;
		6: DIGIT0 = 7'b0011100;
		8: DIGIT0 = 7'b0011100;
		10: DIGIT0 = 7'b0011100;
		13: DIGIT0 = 7'b0011100;
		15: DIGIT0 = 7'b0011100;
		18: DIGIT0 = 7'b0011100;
		20: DIGIT0 = 7'b0011100;
		22: DIGIT0 = 7'b0011100;
		default: DIGIT0 = 7'b1111111;
	endcase
	
	if(screen_state==`HomeScreen || screen_state==`MainTheme) begin
		if(MusicOut <= 11) DIGIT1 = 7'b0011001;   //4
		else if(MusicOut <= 23) DIGIT1 = 7'b0010010;   //5
		else if(MusicOut == 24) DIGIT1 = 7'b0000010;   //6
		else DIGIT1 = 7'b1111111;
	end
	else if(screen_state==`BaseTheme) begin
		if(MusicOut <= 11) DIGIT1 = 7'b0100100;   //2
		else if(MusicOut <= 23) DIGIT1 = 7'b0110000;   //3
		else if(MusicOut == 24) DIGIT1 = 7'b0011001;   //4
		else DIGIT1 = 7'b1111111;
	end
  
	case(MusicOut)
		0: DIGIT2 = 7'b1000110;   //C
		1: DIGIT2 = 7'b1000110;   //C
		2: DIGIT2 = 7'b0100001;   //d    
		3: DIGIT2 = 7'b0100001;   //d 
		4: DIGIT2 = 7'b0000110;   //E                                                
		5: DIGIT2 = 7'b0001110;   //F
		6: DIGIT2 = 7'b0001110;   //F 	
		7: DIGIT2 = 7'b1000010;   //G   
		8: DIGIT2 = 7'b1000010;   //G 
		9: DIGIT2 = 7'b0001000;   //A 
		10: DIGIT2 = 7'b0001000;   //A
		11: DIGIT2 = 7'b0000011;   //b
		12: DIGIT2 = 7'b1000110;   //C
		13: DIGIT2 = 7'b1000110;   //C
		14: DIGIT2 = 7'b0100001;   //d    
		15: DIGIT2 = 7'b0100001;   //d 
		16: DIGIT2 = 7'b0000110;   //E                                                
		17: DIGIT2 = 7'b0001110;   //F
		18: DIGIT2 = 7'b0001110;   //F 	
		19: DIGIT2 = 7'b1000010;   //G   
		20: DIGIT2 = 7'b1000010;   //G 
		21: DIGIT2 = 7'b0001000;   //A 
		22: DIGIT2 = 7'b0001000;   //A
		23: DIGIT2 = 7'b0000011;   //b
		24: DIGIT2 = 7'b1000110;   //C
		default: DIGIT2 = 7'b1111111;
	endcase
	
end


endmodule