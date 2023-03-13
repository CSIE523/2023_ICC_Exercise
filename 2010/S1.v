module S1(clk,
	  rst,
	  RB1_RW,
	  RB1_A,
	  RB1_D,
	  RB1_Q,
	  sen,
	  sd);

input clk, rst;
output reg RB1_RW;      // control signal for RB1: Read/Write
output  [4:0] RB1_A; // control signal for RB1: address
output [7:0] RB1_D; // data path for RB1: input port
input [7:0] RB1_Q;  // data path for RB1: output port
output reg sen, sd;


reg [1:0]state, next_state;
parameter IDLE = 2'd0,
	  READ = 2'd1,
	  OUT = 2'd2;

reg [2:0]addr;
reg [17:0]data;
reg [4:0]counter;

assign RB1_A = counter;

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
                next_state = READ;
            READ:begin
                if(counter == 19) next_state = OUT;
                else next_state = READ;  
            end
            OUT:begin
				if(counter == 18) next_state = IDLE;
                else next_state = OUT; 
			end
			default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk or posedge rst)begin
    if(rst)begin
		RB1_RW <= 1;
		sen <= 1;
		RB1_D <= 0;
		sd <= 0;
		addr <= 0;
		counter <= 0;
    end
    else begin
		if(next_state == IDLE)begin
			counter <= 0;
			sen <= 1;
			addr <= addr + 1;
			RB1_RW <= 1;
		end
		else if(next_state == READ)begin
			data[counter-1] <= RB1_Q[7-addr];
			counter <= counter + 1;
		end
		else if(next_state == OUT)begin
			case(counter)
				19:begin
					sen <= 0;
					sd <= addr[2];
					counter <= 30;
				end
				30:begin
					sd <= addr[1];
					counter <= counter + 1;
				end
				31:begin
					sd <= addr[0];
					counter <= counter + 1;
				end
				default:begin
					sd <= data[17-counter];
					counter <= counter + 1;
				end
			endcase
		end
    end
end

endmodule
