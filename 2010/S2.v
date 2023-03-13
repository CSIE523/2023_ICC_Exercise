module S2(clk,
	  rst,
	  S2_done,
	  RB2_RW,
	  RB2_A,
	  RB2_D,
	  RB2_Q,
	  sen,
	  sd);

input clk, rst;
output S2_done;
output reg RB2_RW;
output reg [2:0] RB2_A;
output reg [17:0] RB2_D;
input [17:0] RB2_Q;
input sen, sd;

reg [2:0]state, next_state;
parameter IDLE = 3'd0,
	  DELAY = 3'd1,
	  READ = 3'd2,
	  OUT = 3'd3,
	  FINISH = 3'd4;

reg [4:0] counter_RB2;

assign S2_done = (state == FINISH);

always@(posedge clk or posedge rst)begin
    if(rst)
        state <= IDLE;
    else 
        state <= next_state;
end

always@(*)begin
    if(rst)
        next_state = IDLE;
    else begin
        case(state)
            IDLE:
                if(sen == 0) next_state = READ;
				else next_state = IDLE;
            READ:begin
                if(counter_RB2 == 21) next_state = OUT;
                else next_state = READ;  
            end
            OUT:begin
				if(RB2_A == 7) next_state = FINISH;
                else next_state = IDLE; 
			end
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk or posedge rst)begin
    if(rst)begin
		RB2_RW <= 1;
		RB2_A <= 0;
		RB2_D <= 0;
		counter_RB2 <= 0;
	end
    else begin
 		if(next_state == READ)begin
			RB2_RW <= 1;
			if(counter_RB2 <= 2)
				RB2_A[2-counter_RB2] <= sd; 
			else 
				RB2_D[20-counter_RB2] <= sd;
			counter_RB2 <= counter_RB2 + 1;
		end
		else if(next_state == OUT)begin
			RB2_RW <= 0;
			counter_RB2 <= 0;
		end

    end
end

endmodule
