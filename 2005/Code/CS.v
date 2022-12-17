`timescale 1ns/10ps
/*
 * IC Contest Computational System (CS)
*/
module CS(Y, X, reset, clk);

input clk, reset; 
input [7:0] X;
output reg [9:0] Y;

reg [3:0] counter;
reg [7:0] X_in[0:8];
reg flag;

wire [11:0] X_SUM;
wire [11:0] X_AVG;
wire [11:0] X_APPR;
wire [7:0]x_0, x_1, x_2, x_3, x_4, x_5, x_6, x_7, x_8; 
wire [7:0]cmp_0, cmp_1, cmp_2, cmp_3, cmp_4, cmp_5, cmp_6, cmp_7; 
integer i;

assign X_SUM = X_in[0] + X_in[1] + X_in[2] + X_in[3] + X_in[4] + X_in[5] + X_in[6] + X_in[7] + X_in[8];
assign X_AVG = X_SUM / 9;
assign X_APPR = (cmp_7 << 3) + cmp_7;

assign x_0 = (X_in[0] <= X_AVG) ? X_in[0] : 0;
assign x_1 = (X_in[1] <= X_AVG) ? X_in[1] : 0;
assign x_2 = (X_in[2] <= X_AVG) ? X_in[2] : 0;
assign x_3 = (X_in[3] <= X_AVG) ? X_in[3] : 0;
assign x_4 = (X_in[4] <= X_AVG) ? X_in[4] : 0;
assign x_5 = (X_in[5] <= X_AVG) ? X_in[5] : 0;
assign x_6 = (X_in[6] <= X_AVG) ? X_in[6] : 0;
assign x_7 = (X_in[7] <= X_AVG) ? X_in[7] : 0;
assign x_8 = (X_in[8] <= X_AVG) ? X_in[8] : 0;

assign cmp_0 = (x_0 >= x_1) ? x_0 : x_1;
assign cmp_1 = (x_2 >= x_3) ? x_2 : x_3;
assign cmp_2 = (x_4 >= x_5) ? x_4 : x_5;
assign cmp_3 = (x_6 >= x_7) ? x_6 : x_7;

assign cmp_4 = (cmp_0 >= cmp_1) ? cmp_0 : cmp_1;
assign cmp_5 = (cmp_2 >= cmp_3) ? cmp_2 : cmp_3;

assign cmp_6 = (cmp_4 >= cmp_5) ? cmp_4 : cmp_5;
assign cmp_7 = (cmp_6 >= x_8) ? cmp_6 : x_8;


always@(posedge clk or posedge reset)begin
	if(reset)begin
		counter <= 0;
		for(i=0;i<9;i=i+1)
			X_in[i] <= 0;
		flag <= 0;
	end
	else begin
		X_in[counter] <= X;
		counter <= counter + 1;
		if(counter == 8)
			flag <= 1;
		if(counter == 9)begin
			X_in[0] <= X;
			counter <= 1;
		end
	end
end

always@(negedge clk)begin
	if(flag == 1)
		Y <= (X_SUM + X_APPR) >> 3;
	
end
endmodule