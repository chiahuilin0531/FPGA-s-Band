module clock_divisor(clk21, clk17, clk1, clk);
input clk;
output clk1;
output clk17;
output clk21;

reg [21:0] num;
wire [21:0] next_num;

always @(posedge clk) begin
  num <= next_num;
end

assign next_num = num + 1'b1;
assign clk1 = num[1];
assign clk17 = num[17];
assign clk21 = num[21];

endmodule
