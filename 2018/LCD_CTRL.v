module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input [3:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output IROM_rd;
output [5:0] IROM_A;
output IRAM_valid;
output reg [7:0] IRAM_D;
output reg [5:0] IRAM_A;
output reg busy;
output done;


reg [2:0]state, next_state;
parameter IDLE = 3'd0,
          GIVE_POS = 3'd1,
          READ_DATA = 3'd2,
          CAL = 3'd3,
          OUT = 3'd4,
          FINISH = 3'd5;

parameter WRITE = 4'd0,
          SHIFT_UP = 4'd1,
          SHIFT_DOWN = 4'd2,
          SHIFT_LEFT = 4'd3,
          SHIFT_RIGHT = 4'd4,
          MAX = 4'd5,
          MIN = 4'd6,
          AVERAGE = 4'd7,
          COUNTERCLOCK_ROTATE = 4'd8,
          CLOCK_ROTATE = 4'd9,
          MIRROR_X = 4'd10,
          MIRROR_Y = 4'd11;

reg [7:0]data_in[0:63];
reg [2:0]tmp_x, tmp_y;
reg [9:0]tmp;
reg delay;
reg [2:0]count;

wire [5:0]pos;
wire [7:0]avg;

assign IROM_A = IRAM_A;
assign pos = (tmp_y << 3) + tmp_x;
assign IROM_rd = (state == READ_DATA || state == GIVE_POS) ? 1 : 0;
assign IRAM_valid = (state == OUT) ? 1 : 0;
assign done = (state == FINISH) ? 1 : 0;
assign avg = (tmp >> 2);

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
                next_state = READ_DATA;
            GIVE_POS:
                next_state = READ_DATA;
            READ_DATA:begin
                if(IRAM_A == 63) next_state = CAL;
                else next_state = GIVE_POS;  
            end
            CAL:begin
                if(delay == 1) next_state = OUT;
                else next_state = CAL;
            end 
            OUT:
                if(IRAM_A == 63) next_state = FINISH;
                else next_state = OUT;
            FINISH:
                next_state = FINISH; 
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk or posedge reset)begin
    if(reset)begin
        for(i=0;i<64;i=i+1)
            data_in[i] <= 5;
        IRAM_A <= 0;
        delay <= 0;
        tmp_x <= 3;
        tmp_y <= 3;
        count <= 0;
    end
    else begin
        if(state == GIVE_POS)
            IRAM_A <= IRAM_A + 1;
        else if(state == READ_DATA)begin
            data_in[IRAM_A] <= IROM_Q;
            if(IRAM_A == 63)
                busy <= 0;  
        end
        else if(state == OUT)begin
            if(delay == 1)begin
                delay <= 0;
                IRAM_D <= data_in[IRAM_A];
            end
            else begin
                IRAM_D <= data_in[IRAM_A+1];
                IRAM_A <= IRAM_A + 1;
            end
        end
        else if(state == CAL)begin
            case(cmd)
                WRITE:begin
                    IRAM_A <= 0;
                    delay <= 1;
                    busy <= 1;
                end       
                SHIFT_UP: begin
                    if(tmp_y == 0)
                        tmp_y <= tmp_y;
                    else
                        tmp_y <= tmp_y - 1;
                    busy <= 0;
                end
                SHIFT_DOWN: begin
                    if(tmp_y == 6)
                        tmp_y <= tmp_y;
                    else
                        tmp_y <= tmp_y + 1;
                    busy <= 0;
                end
                SHIFT_LEFT: begin
                    if(tmp_x == 0)
                        tmp_x <= tmp_x;
                    else
                        tmp_x <= tmp_x - 1;
                    busy <= 0;
                end
                SHIFT_RIGHT: begin
                    if(tmp_x == 6)
                        tmp_x <= tmp_x;
                    else
                        tmp_x <= tmp_x + 1;
                    busy <= 0;
                end
                MAX: begin
                    case(count)
                    0: begin
                        tmp <= data_in[pos];
                        count <= count + 1;
                        busy <= 1;
                    end
                    1: begin
                        tmp <= (data_in[pos+1] > tmp) ? data_in[pos+1] : tmp;
                        count <= count + 1;
                    end
                    2: begin
                        tmp <= (data_in[pos+8] > tmp) ? data_in[pos+8] : tmp;
                        count <= count + 1;
                    end
                    3: begin
                        tmp <= (data_in[pos+9] > tmp) ? data_in[pos+9] : tmp;
                        count <= count + 1;
                    end
                    4: begin
                        data_in[pos] <= tmp;
                        data_in[pos+1] <= tmp;
                        data_in[pos+8] <= tmp;
                        data_in[pos+9] <= tmp;
                        count <= 0;
                        busy <= 0;
                    end
                    default: count <= 0;
                    endcase
                end
                MIN: begin
                    case(count)
                    0: begin
                        tmp <= data_in[pos];
                        count <= count + 1;
                        busy <= 1;
                    end
                    1: begin
                        tmp <= (data_in[pos+1] < tmp) ? data_in[pos+1] : tmp;
                        count <= count + 1;
                    end
                    2: begin
                        tmp <= (data_in[pos+8] < tmp) ? data_in[pos+8] : tmp;
                        count <= count + 1;
                    end
                    3: begin
                        tmp <= (data_in[pos+9] < tmp) ? data_in[pos+9] : tmp;
                        count <= count + 1;
                    end
                    4: begin
                        data_in[pos] <= tmp;
                        data_in[pos+1] <= tmp;
                        data_in[pos+8] <= tmp;
                        data_in[pos+9] <= tmp;
                        count <= 0;
                        busy <= 0;
                    end
                    default: count <= 0;
                    endcase
                end
                AVERAGE: begin
                    case(count)
                    0: begin
                        tmp <= data_in[pos];
                        count <= count + 1;
                        busy <= 1;
                    end
                    1: begin
                        tmp <= tmp + data_in[pos+1];
                        count <= count + 1;
                    end
                    2: begin
                        tmp <= tmp + data_in[pos+8];
                        count <= count + 1;
                    end
                    3: begin
                        tmp <= tmp + data_in[pos+9];
                        count <= count + 1;
                    end
                    4: begin
                        data_in[pos] <= avg;
                        data_in[pos+1] <= avg;
                        data_in[pos+8] <= avg;
                        data_in[pos+9] <= avg;
                        count <= 0;
                        busy <= 0;
                    end
                    default: count <= 0;
                    endcase
                end
                COUNTERCLOCK_ROTATE: begin
                    data_in[pos] <= data_in[pos+1];
                    data_in[pos+8] <= data_in[pos];
                    data_in[pos+1] <= data_in[pos+9];
                    data_in[pos+9] <= data_in[pos+8];
                    busy <= 0;
                end
                CLOCK_ROTATE: begin
                    data_in[pos] <= data_in[pos+8];
                    data_in[pos+8] <= data_in[pos+9];
                    data_in[pos+1] <= data_in[pos];
                    data_in[pos+9] <= data_in[pos+1];
                    busy <= 0;
                end
                MIRROR_X: begin
                    data_in[pos] <= data_in[pos+8];
                    data_in[pos+1] <= data_in[pos+9];
                    data_in[pos+8] <= data_in[pos];
                    data_in[pos+9] <= data_in[pos+1];
                    busy <= 0;
                end
                MIRROR_Y: begin
                    data_in[pos] <= data_in[pos+1];
                    data_in[pos+1] <= data_in[pos];
                    data_in[pos+8] <= data_in[pos+9];
                    data_in[pos+9] <= data_in[pos+8];
                    busy <= 0;
                end
                default: begin
                    tmp_x <= tmp_x;
                    tmp_y <= tmp_y; 
                end
            endcase 
        end
    end
end

endmodule
