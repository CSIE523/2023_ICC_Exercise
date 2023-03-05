module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output  Valid );

reg [2:0]state, next_state;
parameter IDLE = 3'd0,
	  FIND_BIGGER = 3'd1,
      FIND_BIGGER_SMALLEST = 3'd2,
      CHANGE = 3'd3,
	  CAL = 3'd4,
	  FINISH = 3'd5;

reg [3:0] counter;
reg [3:0] job[0:7];
reg done;
reg [9:0] min;
reg [3:0] tmp;
reg [3:0] min_idx;

assign Valid = (done == 1 && job[7] == 0 && job[0] == 7);

always@(posedge CLK or posedge RST)begin
    if(RST)
        state <= IDLE;
    else 
        state <= next_state;
end

always@(*)begin
    if(RST)
        next_state = IDLE;
    else begin
        case(state)
            IDLE:begin
                if(done == 1)next_state = FIND_BIGGER;
                else next_state = IDLE;
            end
            FIND_BIGGER:begin
                if(done == 0) next_state = FIND_BIGGER_SMALLEST;
                else next_state = FIND_BIGGER;  
            end
            FIND_BIGGER_SMALLEST:begin
                if(done == 1) next_state = CHANGE;
                else next_state = FIND_BIGGER_SMALLEST;
            end
            CHANGE:
                next_state = CAL;
            CAL:begin
                if(done == 1) next_state = FIND_BIGGER;
                else next_state = CAL;
            end 
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge CLK or posedge RST)begin
    if(RST)begin
        counter <= 1;
        MatchCount <= 0;
        MinCost <= 0;
        job[0] <= 0;
        job[1] <= 1;
        job[2] <= 2;
        job[3] <= 3;
        job[4] <= 4;
        job[5] <= 5;
        job[6] <= 6;
        job[7] <= 7;
        done <= 0;
        min <= 0;
        tmp <= 0;
        W <= 0;
        J <= 0;
    end
    else begin
        if(next_state == IDLE)begin
            W <= counter;
            J <= counter;
            MatchCount <= 1;
            MinCost <= MinCost + Cost;
            if(counter < 7)begin
                // MinCost <= Cost;
                counter <= counter + 1;
            end
            else 
                done <= 1;
        end
        else if(next_state == FIND_BIGGER)begin
            if(job[counter] > job[counter - 1])begin
                tmp <= counter;
                min_idx <= counter;
                min <= job[counter];
                counter <= counter - 1;    
                done <= 0;
            end
            else 
                counter <= counter - 1;
        end
        else if(next_state == FIND_BIGGER_SMALLEST)begin
            if(min > job[counter] && min > job[tmp] && job[tmp] > job[counter])begin
                min <= job[tmp];
                min_idx <= tmp;
                if(tmp == 7)begin
                    job[tmp] <= job[counter];
                    job[counter] <= job[tmp];
                    done <= 1;
                end
            end
            else if(tmp == 7)begin
                job[min_idx] <= job[counter];
                job[counter] <= job[min_idx];
                done <= 1;
            end
            else 
                tmp <= tmp + 1;
        end
        else if(next_state == CHANGE)begin
            min <= 0;
            done <= 0;
            case(counter)
                0:begin
                    job[1] <= job[7];
                    job[7] <= job[1];
                    job[2] <= job[6];
                    job[6] <= job[2];
                    job[3] <= job[5];
                    job[5] <= job[3];
                end
                1:begin
                    job[2] <= job[7];
                    job[7] <= job[2];
                    job[3] <= job[6];
                    job[6] <= job[3];
                    job[4] <= job[5];
                    job[5] <= job[4];
                end
                2:begin
                    job[3] <= job[7];
                    job[7] <= job[3];
                    job[4] <= job[6];
                    job[6] <= job[4];
                end
                3:begin
                    job[4] <= job[7];
                    job[7] <= job[4];
                    job[5] <= job[6];
                    job[6] <= job[5];
                end
                4:begin
                    job[5] <= job[7];
                    job[7] <= job[5];
                end
                5:begin
                    job[6] <= job[7];
                    job[7] <= job[6];
                end
            endcase
            counter <= 0;
        end
        else if(next_state == CAL)begin
            case(counter)
                0:begin
                    W <= 0;
                    J <= job[0];
                end
                1:begin
                    W <= 1;
                    J <= job[1];
                    min <= min + Cost;
                end
                2:begin
                    W <= 2;
                    J <= job[2];
                    min <= min + Cost;
                end
                3:begin
                    W <= 3;
                    J <= job[3];
                    min <= min + Cost;
                end
                4:begin
                    W <= 4;
                    J <= job[4];
                    min <= min + Cost;
                end
                5:begin
                    W <= 5;
                    J <= job[5];
                    min <= min + Cost;
                end
                6:begin
                    W <= 6;
                    J <= job[6];
                    min <= min + Cost;
                end
                7:begin
                    W <= 7;
                    J <= job[7];
                    min <= min + Cost;
                end
                8:begin
                    min <= min + Cost;
                end
                9:begin
                    if(min < MinCost)begin
                        MinCost <= min;
                        MatchCount <= 1;
                    end
                    else if(min == MinCost)begin
                        MatchCount <= MatchCount + 1;
                        min <= 0;
                    end

                end
            endcase

            if(counter < 9)
                counter <= counter + 1;
            else begin
                counter <= 7;
                done <= 1;
            end
        end
    end
end

endmodule


