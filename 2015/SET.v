module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output reg busy;
output reg valid;
output reg [7:0] candidate;

reg [2:0]state, next_state;
parameter IDLE = 3'd0,
          READ = 3'd1,
          CAL_1 = 3'd2,
          CAL_2 = 3'd3,
          CAL_3 = 3'd4,
          OUT = 3'd5;

reg [23:0] cen;
reg [11:0] rad;
reg [1:0] mod;
reg [3:0] x, y;
reg [6:0] counter_A, counter_B, counter_INTER;
reg read;

wire [7:0] x_dis_A, y_dis_A;
wire [3:0] x_dis_A_tmp, y_dis_A_tmp;
wire [7:0] x_dis_B, y_dis_B;
wire [3:0] x_dis_B_tmp, y_dis_B_tmp;
wire [8:0] dis_sum_A, dis_sum_B;   
wire [7:0] r1, r2;
wire [7:0] ans; 
wire [8:0] tmp_1;
wire [8:0] tmp_2;

assign x_dis_A_tmp = (cen[23:20] > x) ? cen[23:20] - x : x - cen[23:20];
assign y_dis_A_tmp = (cen[19:16] > y) ? cen[19:16] - y : y - cen[19:16];
assign x_dis_B_tmp = (cen[15:12] > x) ? cen[15:12] - x : x - cen[15:12];
assign y_dis_B_tmp = (cen[11:8] > y) ? cen[11:8] - y : y - cen[11:8];

assign x_dis_A = x_dis_A_tmp * x_dis_A_tmp;
assign y_dis_A = y_dis_A_tmp * y_dis_A_tmp;

assign x_dis_B = x_dis_B_tmp * x_dis_B_tmp;
assign y_dis_B = y_dis_B_tmp * y_dis_B_tmp;

assign dis_sum_A = x_dis_A + y_dis_A;
assign dis_sum_B = x_dis_B + y_dis_B;

assign r1 = rad[11:8] * rad[11:8];
assign r2 = rad[7:4] * rad[7:4];

assign tmp_1 = counter_A + counter_B;
assign tmp_2 = counter_INTER + counter_INTER;
assign ans = tmp_1 - tmp_2;

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
                if(en == 0) next_state = CAL_1;
                else next_state = READ;  
                // next_state = CAL_1;
            end
            CAL_1:begin
                if(x == 8 && y == 8) next_state = CAL_2;
                else next_state = CAL_1;
            end
            CAL_2:begin
                if(x == 8 && y == 8) next_state = CAL_3;
                else next_state = CAL_2;
            end
            CAL_3:begin
                if(x == 8 && y == 8) next_state = OUT;
                else next_state = CAL_3;
            end
            OUT:
                next_state = READ; 
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk or posedge rst)begin
    if(rst)begin
        cen <= 0;
        rad <= 0;
        mod <= 0;
        counter_A <= 0;
        counter_B <= 0;
        counter_INTER <= 0;
        valid <= 0;
        busy <= 0;
        read <= 0;
    end
    else begin
        if(next_state == READ)begin
            cen <= central;
            rad <= radius;
            mod <= mode;
            valid <= 0;
            counter_A <= 0;
            counter_B <= 0;
            counter_INTER <= 0;
            busy <= 0;
            read <= 1;
        end
        else if(next_state == CAL_1)begin
            if(r1 >= dis_sum_A)
                counter_A <= counter_A + 1;
            else 
                counter_A <= counter_A;
            valid <= 0;
            busy <= 1;
        end
        else if(next_state == CAL_2)begin
            if(r2 >= dis_sum_B)
                counter_B <= counter_B + 1;
            else
                counter_B <= counter_B;
            valid <= 0;
            busy <= 1;
        end
        else if(next_state == CAL_3)begin
            if(r1 >= dis_sum_A && r2 >= dis_sum_B)
                counter_INTER <= counter_INTER + 1;
            else 
                counter_INTER <= counter_INTER;
            valid <= 0;
            busy <= 1;
        end 
        else if(next_state == OUT)begin
            valid <= 1;
            busy <= 1;
            case(mod)
                0: candidate <= counter_A;
                1: candidate <= counter_INTER;
                2: candidate <= ans;
            endcase
        end
        else begin
            counter_A <= 0;
            counter_B <= 0;
            counter_INTER <= 0;
            busy <= 0;
        end
    end
end

always@(posedge clk or posedge rst)begin
    if(rst)begin
        x <= 1;
        y <= 1;
    end
    else begin
        if(next_state == CAL_1 || next_state == CAL_2 || next_state == CAL_3)begin
            if(x == 8 && y == 8)begin
                x <= 1;
                y <= 1;
            end
            else if(x == 8)begin
                x <= 1;
                y <= y + 1;
            end
            else 
                x <= x + 1;
        end
        else begin
            x <= 1;
            y <= 1;
        end
    end
end

endmodule
