module LCD_CTRL(clk, reset, IROM_Q, cmd, cmd_valid, IROM_EN, IROM_A, IRB_RW, IRB_D, IRB_A, busy, done);
input clk;
input reset;
input [7:0] IROM_Q;
input [2:0] cmd;
input cmd_valid;
output reg IROM_EN;
output reg [5:0] IROM_A;
output reg IRB_RW;
output reg [7:0] IRB_D;
output reg [5:0] IRB_A;
output reg busy;
output done;


reg [2:0]state, next_state;
parameter IDLE = 3'd0,
	  READ = 3'd1,
	  CAL = 3'd2,
	  OUT = 3'd3,
      FINISH = 3'd4;

parameter WRITE = 3'd0,
          SHIFT_UP = 3'd1,
          SHIFT_DOWN = 3'd2,
          SHIFT_LEFT = 3'd3,
          SHIFT_RIGHT = 3'd4,
          AVERAGE = 3'd5,
          MIRROR_X = 3'd6,
          MIRROR_Y = 3'd7;

reg [7:0]data_in[0:63];
reg [2:0]pos_x, pos_y;
reg [2:0]count;
reg [9:0]tmp;
reg delay;

wire [7:0] avg;
wire [5:0] pos;

assign pos = {pos_y, pos_x};
assign avg = tmp >> 2;
assign done = (state == FINISH);
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
                if(delay == 1) next_state = CAL;
                else next_state = IDLE;  
            end
            CAL:begin
                if(cmd == WRITE) next_state = OUT;
                else next_state = CAL;
            end 
            OUT:
                if(IRB_A == 63) next_state = FINISH;
                else next_state = OUT;
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk or posedge reset)begin
    if(reset)begin
        for(i=0;i<64;i=i+1)
            data_in[i] <= 5;
        IRB_A <= 0;
        IROM_EN <= 0;
        pos_x <= 3;
        pos_y <= 3;
        busy <= 1;
        count <= 0;
        IRB_RW <= 1;
        tmp <= 0;
        IROM_A <= 0;
        delay <= 0;
    end
    else begin
        if(next_state == READ)begin
            data_in[IROM_A] <= IROM_Q;
            if(IROM_A == 63)begin
                delay <= 1;
                busy <= 0;
            end
            IROM_A <= IROM_A + 1;
        end
        else if(next_state == CAL)begin
            IROM_EN <= 1;
            case(cmd)
                SHIFT_UP:begin
                    if(pos_y > 0)
                        pos_y <= pos_y - 1;
                    else
                        pos_y <= pos_y;
                    busy <= 0;
                end
                SHIFT_DOWN:begin
                    if(pos_y < 6)
                        pos_y <= pos_y + 1;
                    else
                        pos_y <= pos_y;
                    busy <= 0;
                end
                SHIFT_LEFT:begin
                    if(pos_x > 0)
                        pos_x <= pos_x - 1;
                    else
                        pos_x <= pos_x;
                    busy <= 0;
                end
                SHIFT_RIGHT:begin
                    if(pos_x < 6)
                        pos_x <= pos_x + 1;
                    else
                        pos_x <= pos_x;
                    busy <= 0;
                end
                AVERAGE:begin
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
                MIRROR_X:begin
                    data_in[pos] <= data_in[pos+8];
                    data_in[pos+1] <= data_in[pos+9];
                    data_in[pos+8] <= data_in[pos];
                    data_in[pos+9] <= data_in[pos+1];
                    busy <= 0;
                end
                MIRROR_Y:begin
                    data_in[pos] <= data_in[pos+1];
                    data_in[pos+1] <= data_in[pos];
                    data_in[pos+8] <= data_in[pos+9];
                    data_in[pos+9] <= data_in[pos+8];
                    busy <= 0;
                end
            endcase
        end
        else if(next_state == OUT)begin
            IRB_RW <= 0;
            if(delay == 1)begin
                IRB_D <= data_in[IRB_A];
                delay <= 0;
            end
            else begin
                IRB_D <= data_in[IRB_A+1];
                IRB_A <= IRB_A + 1;
            end
            busy <= 1;
        end
    end
end



endmodule

