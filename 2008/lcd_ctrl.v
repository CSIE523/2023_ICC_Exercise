module LCD_CTRL(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output  reg[7:0]   dataout;
output  reg       output_valid;
output  reg        busy;

reg [1:0]state, next_state;

parameter READ_OP = 2'd0,
		  READ = 2'd1,
		  CAL = 2'd2,
		  OUT = 2'd3;

parameter LOADDATA = 3'd0,
		  ZOOMIN = 3'd1,
		  ZOOMFIT = 3'd2,
		  SHIFT_RIGHT = 3'd3,
		  SHIFT_LEFT = 3'd4,
		  SHIFT_UP = 3'd5,
		  SHIFT_DOWN = 3'd6;
		  

reg [7:0] data_in[0:107];
reg [6:0] counter;
reg [3:0] pos_x, pos_y;
reg magnifi;
wire [6:0]pos;

assign pos = (pos_y << 3) + (pos_y << 2) + pos_x;
integer i;

always@(posedge clk or posedge reset)begin
    if(reset)
        state <= READ_OP;
    else 
        state <= next_state;
end

always@(*)begin
    if(reset)
        next_state = READ_OP;
    else begin
        case(state)
			READ_OP: begin
				if(cmd == LOADDATA) next_state = READ;
				else next_state = CAL;
			end
			READ: begin
				if(counter == 107) next_state = OUT;
				else next_state = READ;
			end
			CAL: next_state = OUT;
			OUT: begin
				if(counter == 16) next_state = READ_OP;
				else next_state = OUT;
			end
            default: next_state = READ_OP;
        endcase
    end 
end


always@(posedge clk or posedge reset)begin
    if(reset)begin
		for(i=0;i<108;i=i+1)
			data_in[i] <= 5;
		pos_x <= 4;
		pos_y <= 3;
		counter <= 0;
		magnifi <= 0;
    end
    else begin
		if(state == READ) begin
			data_in[counter] <= datain;
			if(counter == 107)
				counter <= 0;
			else
				counter <= counter + 1;
			magnifi <= 0;
		end
		else if(next_state == CAL) begin
			case(cmd)
				ZOOMIN:begin
					if(magnifi == 0)begin
						pos_x <= 4;
						pos_y <= 3;
						magnifi <= 1;
					end
					else begin
						pos_x <= pos_x;
						pos_y <= pos_y;
					end
				end
				ZOOMFIT:begin
					magnifi <= 0;
				end
				SHIFT_RIGHT:begin
					if(pos_x < 8)
						pos_x <= pos_x + 1;
					else 
						pos_x <= pos_x;
				end
				SHIFT_LEFT:begin
					if(pos_x > 0)
						pos_x <= pos_x - 1;
					else 
						pos_x <= pos_x;
				end

				SHIFT_UP:begin
					if(pos_y > 0)
						pos_y <= pos_y - 1;
					else 
						pos_y <= pos_y;
				end
				SHIFT_DOWN:begin
					if(pos_y < 5)
						pos_y <= pos_y + 1;
					else 
						pos_y <= pos_y;
				end
				default:begin
					pos_x <= pos_x;
					pos_y <= pos_y;
				end
			endcase
		end
		else if(state == OUT)begin
			if(magnifi == 0)begin
				case(counter)
					0:	dataout <= data_in[13];
					1:	dataout <= data_in[16];
					2:  dataout <= data_in[19];
					3:  dataout <= data_in[22];
					4:  dataout <= data_in[37];
					5:  dataout <= data_in[40];
					6:  dataout <= data_in[43];
					7:  dataout <= data_in[46];
					8:  dataout <= data_in[61];
					9:  dataout <= data_in[64];
					10: dataout <= data_in[67];
					11: dataout <= data_in[70];
					12: dataout <= data_in[85];
					13: dataout <= data_in[88];
					14: dataout <= data_in[91];
					15: dataout <= data_in[94];	
				endcase
			end
			else begin
				case(counter)
					0:	dataout <= data_in[pos];
					1:	dataout <= data_in[pos+1];
					2:  dataout <= data_in[pos+2];
					3:  dataout <= data_in[pos+3];
					4:  dataout <= data_in[pos+12];
					5:  dataout <= data_in[pos+13];
					6:  dataout <= data_in[pos+14];
					7:  dataout <= data_in[pos+15];
					8:  dataout <= data_in[pos+24];
					9:  dataout <= data_in[pos+25];
					10: dataout <= data_in[pos+26];
					11: dataout <= data_in[pos+27];
					12: dataout <= data_in[pos+36];
					13: dataout <= data_in[pos+37];
					14: dataout <= data_in[pos+38];
					15: dataout <= data_in[pos+39];
				endcase
			end
			if(counter == 16)begin
				output_valid <= 0;
				counter <= 0;
			end
			else begin
				output_valid <= 1;
				counter <= counter + 1;
			end
			
		end
		else counter <= 0;
    end
end

always @(posedge clk or posedge reset) begin
	if(reset)
		busy <= 0;
	else begin
		if(counter == 16 && state == OUT)
			busy <= 0;
		else 
			busy <= 1;
	end
end

endmodule
