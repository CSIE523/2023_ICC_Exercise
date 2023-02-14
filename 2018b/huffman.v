module huffman(clk, reset, gray_data, gray_valid, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
    code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);

input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output reg CNT_valid;
output reg [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output code_valid;
output [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output [7:0] M1, M2, M3, M4, M5, M6;
  
reg [2:0]state, next_state;
parameter IDLE = 3'd0,
    INIT = 3'd1,
    CNT_OUT = 3'd2,
    READ = 3'd3,
    COMB = 3'd4,
    SPLIT = 3'd5,
    OUT = 3'd6;

reg [2:0] counter1;
reg [2:0] counter2;
reg [2:0] max_idx;
reg [7:0] max_val;
reg [7:0] arr_val[0:5];
reg [2:0] arr_idx[0:5];
reg [7:0] sorted_val[0:5];
reg [2:0] sorted_idx[0:5];
reg [5:0] record;

assign code_valid = (state == COMB);

integer i;

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
                if(gray_valid == 1) next_state = READ;
                else next_state = CNT_OUT;  
            end
            CNT_OUT: next_state = INIT;
            INIT:begin
                if(counter1 == 6) next_state = COMB;
                else next_state = INIT;
            end
            COMB:begin
                next_state = COMB;
                // if() next_state = OUT;
                // else next_state = CAL;
            end 
            // SPLIT:
            // OUT:
            //     next_state = READ; 
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk or posedge reset)begin
    if(reset)begin
        CNT1 <= 0;
        CNT2 <= 0;
        CNT3 <= 0;
        CNT4 <= 0;
        CNT5 <= 0;
        CNT6 <= 0;
        CNT_valid <= 0;
    end
    else begin
        if(next_state == READ)begin
            case(gray_data)
                1: CNT1 <= CNT1 + 1;
                2: CNT2 <= CNT2 + 1;
                3: CNT3 <= CNT3 + 1;
                4: CNT4 <= CNT4 + 1;
                5: CNT5 <= CNT5 + 1;
                6: CNT6 <= CNT6 + 1;
            endcase
        end
        else if(next_state == CNT_OUT)
            CNT_valid <= 1;
        else if(next_state == INIT)begin 
            CNT_valid <= 0;                  
        end
    end
end


//DATA SORTING
always@(posedge clk or posedge reset)begin
    if(reset)begin
        for(i=0;i<6;i=i+1)
            arr_val[i] <= 0;
        max_idx <= 7;
        max_val <= 0;
        counter1 <= 0;
        for(i=0;i<6;i=i+1)
            record[i] <= 1;
        counter2 <= 0;
    end
    else begin
        if(next_state == CNT_OUT)begin
            arr_val[0] <= CNT1;
            arr_val[1] <= CNT2;
            arr_val[2] <= CNT3;
            arr_val[3] <= CNT4;
            arr_val[4] <= CNT5;
            arr_val[5] <= CNT6;
            for(i=0;i<6;i=i+1)
                arr_idx[i] <= i+1;
        end
        else if(next_state == INIT)begin
            if(counter2 == 6)begin
                counter2 = 0;
                record[max_idx] <= 0;
                sorted_val[counter1] <= max_val;
                sorted_idx[counter1] <= max_idx;
                max_idx <= 7;
                max_val <= 0;
                counter1 <= counter1 + 1;
            end 
            else if(record[counter2] == 0)   
                counter2 <= counter2 + 1;
            else if(max_val < arr_val[counter2] && max_idx > counter2)begin
                max_idx <= counter2;
                max_val <= arr_val[counter2];
                counter2 <= counter2 + 1;
            end
        end
    end
end


endmodule
