module DT(
	input 			clk, 
	input			reset,
	output			done ,
	output	reg		sti_rd ,
	output	reg 	[9:0]	sti_addr ,
	input		[15:0]	sti_di,
	output	reg		res_wr ,
	output	reg		res_rd ,
	output	reg	[13:0]	res_addr ,
	output	reg 	[7:0]	res_do,
	input		[7:0]	res_di
	);

reg [3:0]state, next_state;
parameter IDLE  = 4'd0,
	  FOR_READ_ROM  = 4'd1,
	  FOR_READ_RAM  = 4'd2,
	  FOR_WRITE_RAM = 4'd3,
	  CHANGE_DIR = 4'd4,
	  BAC_FIND = 4'd5,
	  BAC_READ_RAM  = 4'd6,
	  BAC_WRITE_RAM = 4'd7,
	  ZERO_CASE = 4'd8,
	  FINISH = 4'd9;
reg [2:0]cnt;
reg [7:0] min;

//louis
reg [6:0] row, col;
reg dir; //0 forward 1 backward

assign done = (state == FINISH);
always@(posedge clk)begin
    state <= next_state;
end

always@(*)begin
    if(!reset)
        next_state = FOR_READ_ROM;
    else begin
        case(state)
            IDLE:
                next_state = FOR_READ_ROM;
            FOR_READ_ROM:
			begin
                if(sti_di[15-col[3:0]] == 1) next_state = FOR_READ_RAM;
				else if(row == 126 && col == 126) next_state = CHANGE_DIR;
                else next_state = FOR_READ_ROM;  
            end
            FOR_READ_RAM:
			begin
                if(cnt == 5) next_state = FOR_WRITE_RAM;
                else next_state = FOR_READ_RAM;
            end 
            FOR_WRITE_RAM:
			begin
				if(row == 126 && col == 126)
					next_state = CHANGE_DIR;
				else
                	next_state = FOR_READ_ROM; 
			end
			CHANGE_DIR:
			begin
				next_state <= BAC_FIND;
			end
			BAC_FIND:begin
                if(res_di != 0) next_state = ZERO_CASE;
				else if(row == 1 && col == 1) next_state = FINISH;
                else next_state = BAC_FIND;  
            end
			ZERO_CASE:
				next_state = BAC_READ_RAM;
			BAC_READ_RAM:begin
				if(cnt == 6) next_state = BAC_WRITE_RAM;
                else next_state = BAC_READ_RAM;
			end
			BAC_WRITE_RAM:begin

				if(row == 1 && col == 1)
					next_state = FINISH;
				else if(res_di != 0) 
					next_state = BAC_READ_RAM;
				else
                	next_state = BAC_FIND; 
			end
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
//sti_addr sti_rd
//sti_di
always@(posedge clk or negedge reset)begin
    if(!reset)begin
		sti_addr <= 8;
		sti_rd <= 0;

		res_rd <= 0;


		row <= 1;
		col <= 1;
		
		cnt <= 0;

		//louis
		dir <= 0;

    end
    else begin
		if(next_state == FOR_READ_ROM)begin
			// if(sti_di[col[3:0]] == 0) //go to next pix
			// begin
			sti_rd <= 1;
			
			if(col < 126)
				col <= col + 1;
			else
			begin
				col <= 1;
				row <= row + 1;	
				sti_addr <= sti_addr + 1;				
			end 

			if(col[3:0] == 15)
				sti_addr <= sti_addr + 1;

			// end
		end
		else if(next_state == FOR_READ_RAM)begin
			case(cnt)
				0:begin
					res_rd <= 1;
					res_addr <= {row-7'd1,col-7'd1};
				end
				1:begin	
					min <= res_di;
					res_addr <= {row-7'd1,col};
				end
				2:begin
					if(min > res_di)
						min <= res_di;
					res_addr <= {row-7'd1,col+7'd1};
				end
				3:begin
					if(min > res_di)
						min <= res_di;
					res_addr <= {row,col-7'd1};
					
				end
				4:begin
					if(min > res_di)
						min <= res_di;
					res_addr <= {row,col};
				end
				
			endcase
			if(cnt < 5)
				cnt <= cnt + 1;
			else
				cnt <= 0;
		end
		else if(next_state == FOR_WRITE_RAM)
		begin
			// res_addr <= {row,col};
			
		end
		else if(next_state == CHANGE_DIR)
		begin
			dir <= 1;
			res_rd <= 1;
		end
		else if(next_state == BAC_FIND)begin
			res_addr <= {row, col};
			// if(res_di == 0)begin
				if(col > 1)
					col <= col - 1;
				else
				begin
					col <= 126;
					row <= row - 1;				
				end 
			// end
		end
		else if(next_state == ZERO_CASE)begin
			col <= col + 1;
			cnt <= 0;
		end
		else if(next_state == BAC_READ_RAM)begin
			case(cnt)
				0:begin
					res_rd <= 1;
					res_addr <= {row+7'd1,col+7'd1};
				end
				1:begin	
					min <= res_di + 1;
					res_addr <= {row+7'd1,col};
				end
				2:begin
					if(min > (res_di + 1))
						min <= res_di + 1;
					res_addr <= {row+7'd1,col-7'd1};
				end
				3:begin
					if(min > (res_di + 1))
						min <= res_di + 1;
					res_addr <= {row,col+7'd1};
					
				end
				4:begin
					if(min > (res_di + 1))
						min <= res_di + 1;
					res_addr <= {row,col};
				end
				5:begin
					if(min > res_di)
						min <= res_di;
					if(col > 1)
					col <= col - 1;
					else
					begin
						col <= 126;
						row <= row - 1;				
					end 
				end
				
			endcase
			if(cnt < 6)
				cnt <= cnt + 1;
			else begin
				cnt <= 0;
				res_addr <= {row, col};
			end
		end
		else if(next_state == BAC_WRITE_RAM)
			cnt <= 0;
    end
end

always @(negedge clk or negedge reset) begin
	if(!reset)
	begin
		res_wr <= 0;
		res_do <= 0;
	end
	else if(next_state == FOR_WRITE_RAM || next_state == BAC_WRITE_RAM)
	begin
		res_wr <= 1;
		if(dir == 0)
			res_do <= min + 1;
		else
			res_do <= min;
	end
	else 
	begin
		res_wr <= 0;
	end
end




endmodule