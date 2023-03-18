module S1(clk,
	  rst,
	  RB1_RW,
	  RB1_A,
	  RB1_D,
	  RB1_Q,
	  sen,
	  sd);

  input clk, rst;

  output reg RB1_RW;
  
  output [4:0] RB1_A;
  
  output [7:0] RB1_D;
  
  input [7:0] RB1_Q;
  
  output reg sen, sd;
  
reg [1:0]state, next_state;
parameter IDLE = 2'd0,
	  READ = 2'd1,
	  OUT = 2'd2;

reg [4:0]counter;
reg [2:0]addr;
reg [17:0]data;

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
            OUT:
                if(counter == 18) next_state = IDLE;
                else next_state = OUT; 
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk or posedge rst)begin
    if(rst)begin
        RB1_RW <= 1;
        counter <= 0;
        sen <= 1;
        addr <= 0;
    end
    else begin
        if(next_state == IDLE)begin
            RB1_RW <= 1;
            sen <= 1;   //important
            counter <= 0;
            addr <= addr + 1;
        end
        else if(next_state == READ)begin
            counter <= counter + 1;
            data[counter-1] <= RB1_Q[7-addr];
        end
        else if(next_state == OUT)begin
            sen <= 0;
            case(counter)
            19:begin
                sd <= addr[2];
                counter <= 30;
            end
            30:begin
                sd <= addr[1];
                counter <= 31;
            end
            31:begin
                sd <= addr[0];
                counter <= 0;
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
