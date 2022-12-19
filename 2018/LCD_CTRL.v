module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input [3:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output IROM_rd;
output reg [5:0] IROM_A;
output IRAM_valid;
output reg [7:0] IRAM_D;
output reg [5:0] IRAM_A;
output reg busy;
output done;

reg [2:0]state, next_state;
parameter IDLE = 3'd0;
parameter READ_A = 3'd1;
parameter READ_D = 3'd2;
parameter READ_OP = 3'd3;
parameter DO = 3'd4;
parameter OUT = 3'd5;
parameter FINISH = 3'd6;

parameter WRITE = 4'd0;
parameter SHIFT_UP = 4'd1;
parameter SHIFT_DOWN = 4'd2;
parameter SHIFT_LEFT = 4'd3;
parameter SHIFT_RIGHT = 4'd4;
parameter MAX = 4'd5;
parameter MIN = 4'd6;
parameter AVERAGE = 4'd7;
parameter COUNTERCLOCK_ROTATE = 4'd8;
parameter CLOCK_ROTATE = 4'd9;
parameter MIRROR_X = 4'd10;
parameter MIRROR_Y = 4'd11;

reg [6:0]counter;
reg [7:0]data_in[0:63];
reg [2:0]tmp_x, tmp_y;

wire [5:0]pos_1; 
wire [5:0]pos_2;
wire [7:0]a, b, c, d;
wire [7:0]max;
wire [7:0]min;
wire [9:0]avg; 

assign pos_1 = (tmp_y << 3) + tmp_x;
assign pos_2 = ((tmp_y + 1) << 3) + tmp_x;

assign a = (data_in[pos_1] > data_in[pos_1+1]) ? data_in[pos_1] : data_in[pos_1+1];
assign b = (data_in[pos_2] > data_in[pos_2+1]) ? data_in[pos_2] : data_in[pos_2+1];
assign max = (a > b) ? a : b;

assign c = (data_in[pos_1] < data_in[pos_1+1]) ? data_in[pos_1] : data_in[pos_1+1];
assign d = (data_in[pos_2] < data_in[pos_2+1]) ? data_in[pos_2] : data_in[pos_2+1];
assign min = (c < d) ? c : d;

assign avg = (data_in[pos_1] + data_in[pos_1+1] + data_in[pos_2] + data_in[pos_2+1]) >> 2;


integer i;

assign IROM_rd = (state == READ_A || state == READ_D) ? 1 : 0;
assign IRAM_valid = (state == OUT) ? 1 : 0;
assign done = (state == FINISH) ? 1 : 0;

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
                next_state = READ_A;
            READ_A:begin
                next_state = READ_D;  
            end
            READ_D:begin
                if(counter == 64) next_state = READ_OP;
                else next_state = READ_A;
            end
            READ_OP:begin
                if(cmd_valid == 1 && cmd == WRITE) next_state = OUT;
                else next_state = DO;
            end
            DO:begin
                if(cmd_valid == 1 && cmd == WRITE) next_state = OUT;
                else next_state = READ_OP;
            end 
            OUT:
                if(counter == 64) next_state = FINISH;
                else next_state = OUT;
            FINISH:
                next_state = FINISH;
            default:    next_state = IDLE;
        endcase
    end 
end

//DATA INPUT or OUTPUT
always@(posedge clk or posedge reset)begin
    if(reset)begin
        tmp_y <= 3;
        tmp_x <= 3;
        counter <= 0;
        for(i=0;i<64;i=i+1)
            data_in[i] <= 0;
    end
    else begin
        if(next_state == READ_A)begin
            IROM_A <= counter;
        end
        else if(next_state == READ_D)begin
            data_in[counter] <= IROM_Q;
            counter <= counter + 1;
        end
        else if(state == OUT)begin
            IRAM_A <= counter;
            IRAM_D <= data_in[counter];
            counter <= counter + 1; 
        end
        else if(state == DO)begin
            case(cmd)
                SHIFT_UP: begin
                    if(tmp_y == 0)
                        tmp_y <= tmp_y;
                    else
                        tmp_y <= tmp_y - 1;
                end
                SHIFT_DOWN: begin
                    if(tmp_y == 6)
                        tmp_y <= tmp_y;
                    else
                        tmp_y <= tmp_y + 1;
                end
                SHIFT_LEFT: begin
                    if(tmp_x == 0)
                        tmp_x <= tmp_x;
                    else
                        tmp_x <= tmp_x - 1;
                end
                SHIFT_RIGHT: begin
                    if(tmp_x == 6)
                        tmp_x <= tmp_x;
                    else
                        tmp_x <= tmp_x + 1;
                end
                MAX: begin
                    data_in[pos_1] <= max;
                    data_in[pos_2] <= max;
                    data_in[pos_1+1] <= max;
                    data_in[pos_2+1] <= max;
                end
                MIN: begin
                    data_in[pos_1] <= min;
                    data_in[pos_2] <= min;
                    data_in[pos_1+1] <= min;
                    data_in[pos_2+1] <= min;
                end
                AVERAGE: begin
                    data_in[pos_1] <= avg;
                    data_in[pos_2] <= avg;
                    data_in[pos_1+1] <= avg;
                    data_in[pos_2+1] <= avg;
                end
                COUNTERCLOCK_ROTATE: begin
                    data_in[pos_1] <= data_in[pos_1+1];
                    data_in[pos_2] <= data_in[pos_1];
                    data_in[pos_1+1] <= data_in[pos_2+1];
                    data_in[pos_2+1] <= data_in[pos_2];
                end
                CLOCK_ROTATE: begin
                    data_in[pos_1] <= data_in[pos_2];
                    data_in[pos_2] <= data_in[pos_2+1];
                    data_in[pos_1+1] <= data_in[pos_1];
                    data_in[pos_2+1] <= data_in[pos_1+1];
                end
                MIRROR_X: begin
                    data_in[pos_1] <= data_in[pos_2];
                    data_in[pos_1+1] <= data_in[pos_2+1];
                    data_in[pos_2] <= data_in[pos_1];
                    data_in[pos_2+1] <= data_in[pos_1+1];
                end
                MIRROR_Y: begin
                    data_in[pos_1] <= data_in[pos_1+1];
                    data_in[pos_1+1] <= data_in[pos_1];
                    data_in[pos_2] <= data_in[pos_2+1];
                    data_in[pos_2+1] <= data_in[pos_2];
                end
                default: begin
                    tmp_x <= tmp_x;
                    tmp_y <= tmp_y; 
                end
            endcase
        end
        else 
            counter <= 0;
    end 
end

always@(posedge clk or posedge reset)begin
    if(reset)
        busy <= 1;
    else begin
        if(next_state == READ_OP)
            busy <= 0;
        else 
            busy <= 1;
    end

end

endmodule