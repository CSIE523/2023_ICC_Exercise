module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output  busy;
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

wire [7:0] x_dis_A, y_dis_A;
wire [7:0] x_dis_B, y_dis_B;
wire [8:0] dis_sum_A, dis_sum_B;   
wire [7:0] r1, r2;
wire [7:0] ans; 

assign x_dis_A = (cen[23:20] - x) * (cen[23:20] - x);
assign y_dis_A = (cen[19:16] - y) * (cen[19:16] - y);

assign x_dis_B = (cen[15:12] - x) * (cen[15:12] - x);
assign y_dis_B = (cen[11:8] - y) * (cen[11:8] - y);

assign dis_sum_A = x_dis_A + y_dis_A;
assign dis_sum_B = x_dis_B + y_dis_B;

assign r1 = rad[11:8] * rad[11:8];
assign r2 = rad[7:4] * rad[7:4];

assign ans = counter_A + counter_B - counter_INTER - counter_INTER;
assign busy = (state == READ) ? 0 : 1;

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
                if(en == 1) next_state = CAL_1;
                else next_state = READ;  
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
        x <= 1;
        y <= 1;
        counter_A <= 0;
        counter_B <= 0;
        counter_INTER <= 0;
        valid <= 0;
    end
    else begin
        if(state == READ)begin
            cen <= central;
            rad <= radius;
            mod <= mode;
            valid <= 0;
            counter_A <= 0;
            counter_B <= 0;
            counter_INTER <= 0;
        end
        else if(state == CAL_1)begin
            if(r1 >= dis_sum_A)
                counter_A <= counter_A + 1;
            valid <= 0;
        end
        else if(state == CAL_2)begin
            if(r2 >= dis_sum_B)
                counter_B <= counter_B + 1;
            valid <= 0;
        end
        else if(state == CAL_3)begin
            if(r1 >= dis_sum_A && r2 >= dis_sum_B)
                counter_INTER <= counter_INTER + 1;
            valid <= 0;
        end 
        else if(state == OUT)begin
            valid <= 1;
            case(mod)
                0: candidate <= counter_A;
                1: candidate <= counter_INTER;
                2: candidate <= ans;
            endcase

        end
    end
end

always@(posedge clk or posedge rst)begin
    if(rst)begin
        x <= 1;
        y <= 1;
    end
    else begin
        if(state == CAL_1 || state == CAL_2 || state == CAL_3)begin
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
    end
end


// always@(posedge clk or posedge rst)begin
//     if(rst)
//         busy <= 0;
//     else begin
//         if(next_state == READ)
//             busy <= 0;
//         else 
//             busy <= 1;
//     end
// end


endmodule
