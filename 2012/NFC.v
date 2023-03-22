`timescale 1ns/100ps
module NFC(clk, rst, done, F_IO_A, F_CLE_A, F_ALE_A, F_REN_A, F_WEN_A, F_RB_A, F_IO_B, F_CLE_B, F_ALE_B, F_REN_B, F_WEN_B, F_RB_B);

input        clk;
input        rst;
output       done;
inout  [7:0] F_IO_A;
output reg      F_CLE_A;
output reg      F_ALE_A;
output reg      F_REN_A;
output reg      F_WEN_A;
input        F_RB_A;
inout  [7:0] F_IO_B;
output reg      F_CLE_B;
output reg      F_ALE_B;
output reg      F_REN_B;
output reg      F_WEN_B;
input        F_RB_B;

reg [2:0]state, next_state;
parameter IDLE = 3'd0,
	  READ_A = 3'd1,
	  WRITE_B = 3'd2,
      FINISH = 3'd3;

reg enable_a , enable_b;

reg [7:0]F_IO_REG_A;
reg [7:0]F_IO_REG_B;

reg [7:0]arr[0:15];

reg [14:0]write_cnt;
reg [4:0]read_cnt;
reg [5:0]cnt;
reg [5:0]wcnt;

reg [17:0]addr;

assign done = (state == FINISH);

assign F_IO_A = (enable_a == 1) ? F_IO_REG_A : 8'bz;
assign F_IO_B = (enable_b == 1) ? F_IO_REG_B : 8'bz;


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
                next_state = READ_A;
            READ_A:begin
                if(write_cnt == 16384) next_state = FINISH;
                else if(read_cnt == 16) next_state = WRITE_B;
                else next_state = READ_A;  
            end 
            WRITE_B:begin
                if(cnt == 14) next_state = IDLE;
                else next_state = WRITE_B;
            end
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk or posedge rst)begin
    if(rst)begin
        enable_a <= 1;
        enable_b <= 1;
        F_IO_REG_A <= 8'hff;
        F_IO_REG_B <= 8'hff;
        write_cnt <= 0;
        read_cnt <= 0;
        cnt <= 0;
        F_CLE_A <= 1;
        F_ALE_A <= 0;
        F_REN_A <= 1;
        F_WEN_A <= 0;
        F_CLE_B <= 1;
        F_ALE_B <= 0;
        F_REN_B <= 1;
        F_WEN_B <= 1;
        addr <= 0;
        wcnt <= 0;
    end
    else begin
        if(next_state == IDLE)
            cnt <= 0;
        else if(next_state == READ_A)begin
            case (cnt)
                0:begin
                    if(write_cnt < 8191)
                        F_IO_REG_A <= 0;
                    else 
                        F_IO_REG_A <= 1;
                    F_CLE_A <= 1;
                    F_ALE_A <= 0;
                    F_WEN_A <= 0;
                    F_REN_A <= 1;
                    enable_a <= 1;
                    cnt <= cnt + 1;
                    read_cnt <= 0;
                end 
                1:begin
                    F_WEN_A <= 1;
                    cnt <= cnt + 1;
                end
                // cmd finish

                2:begin //addr1
                    F_CLE_A <= 0;
                    F_ALE_A <= 1;
                    F_WEN_A <= 0;
                    F_IO_REG_A <= addr[7:0];
                    cnt <= cnt + 1;
                end
                3:begin
                    F_WEN_A <= 1;
                    cnt <= cnt + 1;
                end
                4:begin //addr2
                    F_WEN_A <= 0;
                    F_IO_REG_A <= addr[16:9];
                    cnt <= cnt + 1;
                end
                5:begin
                    F_WEN_A <= 1;
                    cnt <= cnt + 1;
                end
                6:begin //addr3
                    F_WEN_A <= 0;
                    F_IO_REG_A <= {7'd0, addr[17]};
                    cnt <= cnt + 1;
                end
                7:begin
                    F_WEN_A <= 1;
                    cnt <= cnt + 1;
                end
                8:begin
                    F_WEN_A <= 0;
                    F_ALE_A <= 0;
                    if(F_RB_A == 1)begin
                        cnt <= cnt + 1;
                        enable_a <= 0;
                    end
                end
                9:begin
                    F_REN_A <= ~F_REN_A;
                    F_WEN_A <= 1;
                    if(F_REN_A == 0)begin
                        arr[read_cnt] <= F_IO_A;
                        if(read_cnt == 15)
                            cnt <= 0;
                        read_cnt <= read_cnt + 1;
                    end
                end
            endcase
        end
        else if(next_state == WRITE_B)begin
            case(cnt)
                0:begin
                    if(write_cnt < 8191)begin
                        F_IO_REG_B <= 8'h80;
                        cnt <= 3;
                    end
                    else begin 
                        F_IO_REG_B <= 8'h01;
                        cnt <=  1;
                    end
                    enable_b <= 1;
                    F_CLE_B <= 1;
                    F_ALE_B <= 0;
                    F_WEN_B <= 0;
                end
                1:begin
                    F_WEN_B <= 1;
                    cnt <= cnt + 1;
                end
                2:begin
                    F_WEN_B <= 0;
                    F_IO_REG_B <= 8'h80; 
                    cnt <= cnt + 1;
                end
                3:begin
                    F_WEN_B <= 1;
                    cnt <= cnt + 1;   
                end
                //cmd finish

                4:begin //addr1
                    F_WEN_B <= 0;
                    F_CLE_B <= 0;
                    F_ALE_B <= 1;
                    F_IO_REG_B <= addr[7:0];
                    cnt <= cnt + 1; 
                end
                5:begin
                    F_WEN_B <= 1;
                    cnt <= cnt + 1; 
                end
                6:begin //addr2
                    F_WEN_B <= 0;
                    F_IO_REG_B <= addr[16:9];
                    cnt <= cnt + 1;
                end
                7:begin
                    F_WEN_B <= 1;
                    cnt <= cnt + 1;
                end
                8:begin //addr3
                    F_WEN_B <= 0;
                    F_IO_REG_B <= {7'd0, addr[17]};
                    cnt <= cnt + 1;
                end
                9:begin
                    F_WEN_B <= 1;    
                    cnt <= cnt + 1;
                end

                //write data
                10:begin
                    F_WEN_B <= ~F_WEN_B;
                    F_CLE_B <= 0;
                    F_ALE_B <= 0;
                    if(F_WEN_B == 1)begin
                        F_IO_REG_B <= addr[wcnt];
                        if(wcnt == 15)begin
                            wcnt <= 0;
                            cnt <= cnt + 1;
                        end
                        else
                            wcnt <= wcnt + 1;
                    end
                end
                11:begin
                    F_WEN_B <= 0;
                    F_ALE_B <= 0;
                    F_CLE_B <= 1;
                    F_IO_REG_B <= 8'h10;
                    cnt <= cnt + 1;
                end
                12:begin
                    F_WEN_B <= 1;
                    cnt <= cnt + 1;
                end
                13:begin //check F_RB_B
                    if(F_RB_B == 1)begin
                        write_cnt <= write_cnt + 1;
                        cnt <= cnt + 1;
                        addr <= addr + 16;
                    end
                end
            endcase
        end
    end
end
  
endmodule