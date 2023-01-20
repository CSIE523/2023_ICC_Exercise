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

parameter REFLASH = 3'd0,
		  LOADDATA = 3'd1,
		  ZOOMIN = 3'd2,
		  ZOOMOUT = 3'd3,
		  SHIFT_RIGHT = 3'd4,
		  SHIFT_LEFT = 3'd5,
		  SHIFT_UP = 3'd6,
		  SHIFT_DOWN = 3'd7;
		  

reg [7:0] data_in[0:63];
reg [5:0] counter;
reg [2:0] pos_x, pos_y;
reg magnifi;
wire [5:0]pos;

assign pos = {pos_y, pos_x};
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
				else if(cmd == REFLASH) next_state = OUT;
				else next_state = CAL;
			end
			READ: begin
				if(counter == 63) next_state = OUT;
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


//DATA INPUT
always@(posedge clk or posedge reset)begin
    if(reset)begin
		for(i=0;i<64;i=i+1)
			data_in[i] <= 5;
		// busy <= 0;
		pos_x <= 2;
		pos_y <= 2;
		counter <= 0;
		magnifi <= 0;
    end
    else begin
		if(state == READ) begin
			data_in[counter] <= datain;
			counter <= counter + 1;
			magnifi <= 0;
			// busy <= 1;
		end
		else if(next_state == CAL) begin
			case(cmd)
				ZOOMIN:begin
					magnifi <= 1;
					pos_x <= 2;
					pos_y <= 2;
				end
				ZOOMOUT:begin
					magnifi <= 0;
				end
				SHIFT_RIGHT:begin
					if(pos_x < 4)
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
					if(pos_y < 4)
						pos_y <= pos_y + 1;
					else 
						pos_y <= pos_y;
				end
				default:begin
					pos_x <= pos_x;
					pos_y <= pos_y;
				end
			endcase
			// busy <= 1;
		end
		else if(state == OUT)begin
			if(magnifi == 0)begin
				case(counter)
					0:	dataout <= data_in[0];
					1:	dataout <= data_in[2];
					2:  dataout <= data_in[4];
					3:  dataout <= data_in[6];
					4:  dataout <= data_in[16];
					5:  dataout <= data_in[18];
					6:  dataout <= data_in[20];
					7:  dataout <= data_in[22];
					8:  dataout <= data_in[32];
					9:  dataout <= data_in[34];
					10: dataout <= data_in[36];
					11: dataout <= data_in[38];
					12: dataout <= data_in[48];
					13: dataout <= data_in[50];
					14: dataout <= data_in[52];
					15: dataout <= data_in[54];
					
				endcase
			end
			else begin
				case(counter)
					0:	dataout <= data_in[pos];
					1:	dataout <= data_in[pos+1];
					2:  dataout <= data_in[pos+2];
					3:  dataout <= data_in[pos+3];
					4:  dataout <= data_in[pos+8];
					5:  dataout <= data_in[pos+9];
					6:  dataout <= data_in[pos+10];
					7:  dataout <= data_in[pos+11];
					8:  dataout <= data_in[pos+16];
					9:  dataout <= data_in[pos+17];
					10: dataout <= data_in[pos+18];
					11: dataout <= data_in[pos+19];
					12: dataout <= data_in[pos+24];
					13: dataout <= data_in[pos+25];
					14: dataout <= data_in[pos+26];
					15: dataout <= data_in[pos+27];
				endcase
			end
			if(counter == 16)begin
			 	// busy <= 0;
				output_valid <= 0;
				counter <= 0;
			end
			else begin
				// busy <= 1;
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
