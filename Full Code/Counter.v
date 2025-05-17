module counter(clk, start, fin);
	parameter n = 3;
	input clk, start;
	output reg fin;
	
	reg [n-1:0] num, next_num;
	always@(posedge clk) begin
		if(start == 1) num <= 0;
		else num <= next_num;
	end
	
	always@(*) begin
		next_num = num + 1;
		
		if(num == 2**n - 1) fin = 1;
		else fin = 0;
	end
	
endmodule