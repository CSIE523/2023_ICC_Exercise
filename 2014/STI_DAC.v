module STI_DAC(clk ,reset, load, pi_data, pi_length, pi_fill, pi_msb, pi_low, pi_end,
	       so_data, so_valid,
	       pixel_finish, pixel_dataout, pixel_addr,
	       pixel_wr);

input		clk, reset;
input		load, pi_msb, pi_low, pi_end; 
input	[15:0]	pi_data;
input	[1:0]	pi_length;
input		pi_fill;
output reg	so_data, so_valid;

output  pixel_finish;
output reg pixel_wr;
output reg [7:0] pixel_addr;
output reg [7:0] pixel_dataout;

//==============================================================================

reg [2:0]state, next_state;
parameter IDLE = 3'd0,
	  READ = 3'd1,
	  CAL = 3'd2,
	  STI_OUT = 3'd3,
	  FINISH_0 = 3'd4,
	  TEST = 3'd5,
	  FINISH = 3'd6;

// reg pi_fill, pi_msb, pi_low;
// reg [1:0] pi_length;

reg [7:0] _8bits_data;
// reg [15:0] pi_data;
reg [23:0] _24bits_data;
reg [31:0] _32bits_data;
reg [4:0] counter;
reg done;

// assign pixel_wr  = (counter == 7 || counter == 15 || counter == 23 || counter == 31 || state == FINISH_0);
assign pixel_finish = (state == FINISH);


always@(posedge clk or posedge reset)begin
    if(reset)
        state <= IDLE;
    else 
        state <= next_state;
end

always@(*)begin
    if(reset)
        next_state = IDLE;
    else begin
        case(state)
            IDLE:
                next_state = READ;
            READ:begin
               if(load == 1) next_state = CAL;
			   else next_state = READ;  
            end
            CAL:begin
				next_state = STI_OUT;
            end 
            STI_OUT:begin
                if(pi_end == 1 && done == 1) next_state = TEST;
				else if(done == 1) next_state = IDLE;
				else next_state = STI_OUT;
			end
			FINISH_0:begin
				if(pixel_addr == 255) next_state = FINISH;
				else next_state = TEST;
			end
			TEST:	next_state = FINISH_0;
            default:    next_state = IDLE;
        endcase	
    end 
end


//pi_data INPUT
always@(posedge clk)begin
	if(next_state == IDLE)begin
		so_valid <= 0;
		counter <= 0;
		done <= 0;
		pixel_wr <= 0;
	end
	// else if(next_state == READ)begin
	// 	// pi_data <= pi_data;
	// 	// pi_length <= pi_length;
	// 	// pi_fill <= pi_fill;	//CAL && (24bits or 32 bits)
	// 	// pi_msb <= pi_msb;		//OUT
	// 	// pi_low <= pi_low;		//CAL && 8bits
	// 	done <= 0;
	// end
	else if(next_state == CAL)begin
		case(pi_length)
			0:begin	//8
				if(pi_low == 1)begin
					_8bits_data[0] <= pi_data[8];
					_8bits_data[1] <= pi_data[9];
					_8bits_data[2] <= pi_data[10];
					_8bits_data[3] <= pi_data[11];
					_8bits_data[4] <= pi_data[12];
					_8bits_data[5] <= pi_data[13];
					_8bits_data[6] <= pi_data[14];
					_8bits_data[7] <= pi_data[15];
				end
				else begin
					_8bits_data[0] <= pi_data[0];
					_8bits_data[1] <= pi_data[1];
					_8bits_data[2] <= pi_data[2];
					_8bits_data[3] <= pi_data[3];
					_8bits_data[4] <= pi_data[4];
					_8bits_data[5] <= pi_data[5];
					_8bits_data[6] <= pi_data[6];
					_8bits_data[7] <= pi_data[7];
				end
			end
			1:begin	//16
				//pi_data <= pi_data;
			end
			2:begin	//24
				if(pi_fill == 1)
					_24bits_data <= {pi_data, 8'd0};
				else 
					_24bits_data <= {8'd0, pi_data};
			end
			3:begin	//32
				if(pi_fill == 1)
					_32bits_data <= {pi_data, 16'd0};
				else 
					_32bits_data <= {16'd0, pi_data};
			end
		endcase
	end
	else if(next_state == STI_OUT)begin
		so_valid <= 1;
		case(pi_length)
			0:begin
				if(pi_msb == 1)
					so_data <= _8bits_data[5'd7-counter];
				else 
					so_data <= _8bits_data[counter];

				if(counter == 7)begin
					done <= 1;
					pixel_wr <= 1;
					// pixel_addr <= pixel_addr + 8'd1;
					counter <= 0;
				end
				else begin
					pixel_wr <= 0;
					counter <= counter + 1;
				end
			end
			1:begin
				if(pi_msb == 1)
					so_data <= pi_data[5'd15-counter];
				else 
					so_data <= pi_data[counter];

				if(counter == 15)begin
					done <= 1;
					pixel_wr <= 1;
					// pixel_addr <= pixel_addr + 8'd1;
					counter <= 17;
				end
				else if(counter == 7)begin
					pixel_wr <= 1;
					// pixel_addr <= pixel_addr + 8'd1;
					counter <= counter + 1;
				end
				else begin
					pixel_wr <= 0;
					counter <= counter + 1;
				end
			end
			2:begin
				if(pi_msb == 1)
					so_data <= _24bits_data[5'd23-counter];
				else 
					so_data <= _24bits_data[counter];

				if(counter == 23)begin
					done <= 1;
					pixel_wr <= 1;
					// pixel_addr <= pixel_addr + 8'd1;
					counter <= 0;
				end
				else if(counter == 15)begin
					pixel_wr <= 1;
					// pixel_addr <= pixel_addr + 8'd1;
					counter <= counter + 1;
				end
				else if(counter == 7)begin
					pixel_wr <= 1;
					// pixel_addr <= pixel_addr + 8'd1;
					counter <= counter + 1;
				end
				else begin
					pixel_wr <= 0;
					counter <= counter + 1;
				end
			end
			3:begin
				if(pi_msb == 1)
					so_data <= _32bits_data[5'd31-counter];
				else 
					so_data <= _32bits_data[counter];

				if(counter == 31)begin
					done <= 1;
					pixel_wr <= 1;
					// pixel_addr <= pixel_addr + 8'd1;
					counter <= 0;
				end
				else if(counter == 23)begin
					pixel_wr <= 1;
					// pixel_addr <= pixel_addr + 8'd1;
					counter <= counter + 1;
				end
				else if(counter == 15)begin
					pixel_wr <= 1;
					// pixel_addr <= pixel_addr + 8'd1;
					counter <= counter + 1;
				end
				else if(counter == 7)begin
					pixel_wr <= 1;
					// pixel_addr <= pixel_addr + 8'd1;
					counter <= counter + 1;
				end
				else begin 
					pixel_wr <= 0;
					counter <= counter + 1;
				end
			end
		endcase
	end
	else if(next_state == FINISH_0)begin
		
		pixel_wr <= 1;
		// pixel_addr <= pixel_addr + 8'd1;
	end
	else if(next_state == TEST)begin
		pixel_wr <= 0;
		so_valid <= 0;
	end
end

always@(posedge clk or posedge reset)begin
	if(reset)
		pixel_addr <= 8'd255;
	else begin
		if(next_state == STI_OUT)begin
			case(pi_length)
				0:begin
					if(pi_msb == 1)begin
						pixel_dataout[0] <= _8bits_data[0];
						pixel_dataout[1] <= _8bits_data[1];
						pixel_dataout[2] <= _8bits_data[2];
						pixel_dataout[3] <= _8bits_data[3];
						pixel_dataout[4] <= _8bits_data[4];
						pixel_dataout[5] <= _8bits_data[5];
						pixel_dataout[6] <= _8bits_data[6];
						pixel_dataout[7] <= _8bits_data[7];
					end
					else begin
						pixel_dataout[0] <= _8bits_data[7];
						pixel_dataout[1] <= _8bits_data[6];
						pixel_dataout[2] <= _8bits_data[5];
						pixel_dataout[3] <= _8bits_data[4];
						pixel_dataout[4] <= _8bits_data[3];
						pixel_dataout[5] <= _8bits_data[2];
						pixel_dataout[6] <= _8bits_data[1];
						pixel_dataout[7] <= _8bits_data[0];
					end
					if(counter == 6)
						pixel_addr <= pixel_addr + 8'd1;
				end
				1:begin
					if(counter == 6)begin
						if(pi_msb == 1)begin
							pixel_dataout[0] <= pi_data[8];
							pixel_dataout[1] <= pi_data[9];
							pixel_dataout[2] <= pi_data[10];
							pixel_dataout[3] <= pi_data[11];
							pixel_dataout[4] <= pi_data[12];
							pixel_dataout[5] <= pi_data[13];
							pixel_dataout[6] <= pi_data[14];
							pixel_dataout[7] <= pi_data[15];
						end
						else begin
							pixel_dataout[0] <= pi_data[7];
							pixel_dataout[1] <= pi_data[6];
							pixel_dataout[2] <= pi_data[5];
							pixel_dataout[3] <= pi_data[4];
							pixel_dataout[4] <= pi_data[3];
							pixel_dataout[5] <= pi_data[2];
							pixel_dataout[6] <= pi_data[1];
							pixel_dataout[7] <= pi_data[0];
						end
						pixel_addr <= pixel_addr + 8'd1;
					end
					else if(counter == 14)begin
						if(pi_msb == 1)begin
							pixel_dataout[0] <= pi_data[0];
							pixel_dataout[1] <= pi_data[1];
							pixel_dataout[2] <= pi_data[2];
							pixel_dataout[3] <= pi_data[3];
							pixel_dataout[4] <= pi_data[4];
							pixel_dataout[5] <= pi_data[5];
							pixel_dataout[6] <= pi_data[6];
							pixel_dataout[7] <= pi_data[7];
						end
						else begin
							pixel_dataout[0] <= pi_data[15];
							pixel_dataout[1] <= pi_data[14];
							pixel_dataout[2] <= pi_data[13];
							pixel_dataout[3] <= pi_data[12];
							pixel_dataout[4] <= pi_data[11];
							pixel_dataout[5] <= pi_data[10];
							pixel_dataout[6] <= pi_data[9];
							pixel_dataout[7] <= pi_data[8];
						end
						pixel_addr <= pixel_addr + 8'd1;
					end
				end
				2:begin
					if(counter == 6)begin
						if(pi_msb == 1)begin
							pixel_dataout[0] <= _24bits_data[16];
							pixel_dataout[1] <= _24bits_data[17];
							pixel_dataout[2] <= _24bits_data[18];
							pixel_dataout[3] <= _24bits_data[19];
							pixel_dataout[4] <= _24bits_data[20];
							pixel_dataout[5] <= _24bits_data[21];
							pixel_dataout[6] <= _24bits_data[22];
							pixel_dataout[7] <= _24bits_data[23];
						end
						else begin
							pixel_dataout[0] <= _24bits_data[7];
							pixel_dataout[1] <= _24bits_data[6];
							pixel_dataout[2] <= _24bits_data[5];
							pixel_dataout[3] <= _24bits_data[4];
							pixel_dataout[4] <= _24bits_data[3];
							pixel_dataout[5] <= _24bits_data[2];
							pixel_dataout[6] <= _24bits_data[1];
							pixel_dataout[7] <= _24bits_data[0];
						end
						pixel_addr <= pixel_addr + 8'd1;
					end
					else if(counter == 14)begin
						if(pi_msb == 1)begin
							pixel_dataout[0] <= _24bits_data[8];
							pixel_dataout[1] <= _24bits_data[9];
							pixel_dataout[2] <= _24bits_data[10];
							pixel_dataout[3] <= _24bits_data[11];
							pixel_dataout[4] <= _24bits_data[12];
							pixel_dataout[5] <= _24bits_data[13];
							pixel_dataout[6] <= _24bits_data[14];
							pixel_dataout[7] <= _24bits_data[15];
						end
						else begin
							pixel_dataout[0] <= _24bits_data[15];
							pixel_dataout[1] <= _24bits_data[14];
							pixel_dataout[2] <= _24bits_data[13];
							pixel_dataout[3] <= _24bits_data[12];
							pixel_dataout[4] <= _24bits_data[11];
							pixel_dataout[5] <= _24bits_data[10];
							pixel_dataout[6] <= _24bits_data[9];
							pixel_dataout[7] <= _24bits_data[8];
						end
						pixel_addr <= pixel_addr + 8'd1;
					end
					else if(counter == 22)begin
						if(pi_msb == 1)begin
							pixel_dataout[0] <= _24bits_data[0];
							pixel_dataout[1] <= _24bits_data[1];
							pixel_dataout[2] <= _24bits_data[2];
							pixel_dataout[3] <= _24bits_data[3];
							pixel_dataout[4] <= _24bits_data[4];
							pixel_dataout[5] <= _24bits_data[5];
							pixel_dataout[6] <= _24bits_data[6];
							pixel_dataout[7] <= _24bits_data[7];
						end
						else begin
							pixel_dataout[0] <= _24bits_data[23];
							pixel_dataout[1] <= _24bits_data[22];
							pixel_dataout[2] <= _24bits_data[21];
							pixel_dataout[3] <= _24bits_data[20];
							pixel_dataout[4] <= _24bits_data[19];
							pixel_dataout[5] <= _24bits_data[18];
							pixel_dataout[6] <= _24bits_data[17];
							pixel_dataout[7] <= _24bits_data[16];
						end
						pixel_addr <= pixel_addr + 8'd1;
					end
				end
				3:begin
					if(counter == 6)begin
						if(pi_msb == 1)begin
							pixel_dataout[0] <= _32bits_data[24];
							pixel_dataout[1] <= _32bits_data[25];
							pixel_dataout[2] <= _32bits_data[26];
							pixel_dataout[3] <= _32bits_data[27];
							pixel_dataout[4] <= _32bits_data[28];
							pixel_dataout[5] <= _32bits_data[29];
							pixel_dataout[6] <= _32bits_data[30];
							pixel_dataout[7] <= _32bits_data[31];
						end
						else begin
							pixel_dataout[0] <= _32bits_data[7];
							pixel_dataout[1] <= _32bits_data[6];
							pixel_dataout[2] <= _32bits_data[5];
							pixel_dataout[3] <= _32bits_data[4];
							pixel_dataout[4] <= _32bits_data[3];
							pixel_dataout[5] <= _32bits_data[2];
							pixel_dataout[6] <= _32bits_data[1];
							pixel_dataout[7] <= _32bits_data[0];
						end
						pixel_addr <= pixel_addr + 8'd1;
					end
					else if(counter == 14)begin
						if(pi_msb == 1)begin
							pixel_dataout[0] <= _32bits_data[16];
							pixel_dataout[1] <= _32bits_data[17];
							pixel_dataout[2] <= _32bits_data[18];
							pixel_dataout[3] <= _32bits_data[19];
							pixel_dataout[4] <= _32bits_data[20];
							pixel_dataout[5] <= _32bits_data[21];
							pixel_dataout[6] <= _32bits_data[22];
							pixel_dataout[7] <= _32bits_data[23];
						end
						else begin
							pixel_dataout[0] <= _32bits_data[15];
							pixel_dataout[1] <= _32bits_data[14];
							pixel_dataout[2] <= _32bits_data[13];
							pixel_dataout[3] <= _32bits_data[12];
							pixel_dataout[4] <= _32bits_data[11];
							pixel_dataout[5] <= _32bits_data[10];
							pixel_dataout[6] <= _32bits_data[9];
							pixel_dataout[7] <= _32bits_data[8];
						end
						pixel_addr <= pixel_addr + 8'd1;
					end
					else if(counter == 22)begin
						if(pi_msb == 1)begin
							pixel_dataout[0] <= _32bits_data[8];
							pixel_dataout[1] <= _32bits_data[9];
							pixel_dataout[2] <= _32bits_data[10];
							pixel_dataout[3] <= _32bits_data[11];
							pixel_dataout[4] <= _32bits_data[12];
							pixel_dataout[5] <= _32bits_data[13];
							pixel_dataout[6] <= _32bits_data[14];
							pixel_dataout[7] <= _32bits_data[15];
						end
						else begin
							pixel_dataout[0] <= _32bits_data[23];
							pixel_dataout[1] <= _32bits_data[22];
							pixel_dataout[2] <= _32bits_data[21];
							pixel_dataout[3] <= _32bits_data[20];
							pixel_dataout[4] <= _32bits_data[19];
							pixel_dataout[5] <= _32bits_data[18];
							pixel_dataout[6] <= _32bits_data[17];
							pixel_dataout[7] <= _32bits_data[16];
						end
						pixel_addr <= pixel_addr + 8'd1;
					end
					else if(counter==30)begin
						if(pi_msb == 1)begin
							pixel_dataout[0] <= _32bits_data[0];
							pixel_dataout[1] <= _32bits_data[1];
							pixel_dataout[2] <= _32bits_data[2];
							pixel_dataout[3] <= _32bits_data[3];
							pixel_dataout[4] <= _32bits_data[4];
							pixel_dataout[5] <= _32bits_data[5];
							pixel_dataout[6] <= _32bits_data[6];
							pixel_dataout[7] <= _32bits_data[7];
						end
						else begin
							pixel_dataout[0] <= _32bits_data[31];
							pixel_dataout[1] <= _32bits_data[30];
							pixel_dataout[2] <= _32bits_data[29];
							pixel_dataout[3] <= _32bits_data[28];
							pixel_dataout[4] <= _32bits_data[27];
							pixel_dataout[5] <= _32bits_data[26];
							pixel_dataout[6] <= _32bits_data[25];
							pixel_dataout[7] <= _32bits_data[24];
						end
						pixel_addr <= pixel_addr + 8'd1;
					end
				end
			endcase
		end
		else if(next_state == TEST)begin
			pixel_dataout <= 8'h00;
			pixel_addr <= pixel_addr + 8'd1;
		end
	end
end

endmodule
