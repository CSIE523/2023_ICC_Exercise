 
`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output  reg[13:0] 	gray_addr;
output  reg       	gray_req;
input   	gray_ready;
input   [7:0] 	gray_data;
output  [13:0] 	lbp_addr;
output 	lbp_valid;
output  reg[7:0] 	lbp_data;
output  	finish;


//====================================================================
reg [2:0]state, next_state;
parameter IDLE = 3'd0;
parameter READ = 3'd1;
parameter WRITE = 3'd2;
parameter WRITE_0 = 3'd3;
parameter FINISH = 3'd4;

reg [6:0]col, row;
reg [3:0]cnt_out;
reg read_done;
reg [3:0]cnt_read;
reg [7:0]pix [0:8];
reg buffer [0:8];
wire is_edge;
reg  tmp;


assign lbp_addr = {row, col};
assign lbp_valid = (state == WRITE_0) ? 1 : (cnt_out == 9) ? 1 : 0;
assign finish = (state == FINISH) ? 1 : 0;
assign is_edge = (col == 0 || col == 127 || row == 0 || row == 127) ? 1 : 0;


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
            IDLE:begin
                if(gray_ready == 1) next_state = READ;
                else next_state = IDLE;
            end
            READ:begin
                if(read_done == 1)begin
                    if(is_edge == 1)
                        next_state = WRITE_0;
                    else
                        next_state = WRITE;
                end
                else next_state = READ;  
            end
            WRITE:begin
                if(cnt_out == 9) next_state = READ;
                else next_state = WRITE;
            end
            WRITE_0:begin
                if(row == 127 && col == 127) next_state = FINISH;
                else next_state = READ;
            end
            FINISH:
                next_state = FINISH;
            default:    next_state = IDLE;
        endcase
    end 
end


//COL or ROW Controller
always@(posedge clk or posedge reset)begin
    if(reset)begin
        col <= 0;
        row <= 0;
    end
    else begin
        if(state == WRITE_0 || cnt_out == 9)begin
            if(col == 127)begin
                row <= row + 1;
            end
            col <= col + 1;
        end

    end
end

always @(posedge clk or posedge reset) begin
    if(reset)
    begin
        gray_addr <= 0;
        cnt_read <= 0;
        read_done <= 0;
        gray_req <= 0;
    end
    
    else if(state == READ) //read full 
    begin
        gray_req <= 1;
        if(is_edge == 1) 
        begin
            read_done <= 1;
        end
        else if(col == 1)
        begin
            case (cnt_read)
                1: gray_addr <= {row,col}; 
                2: gray_addr <= {row-7'd1,col-7'd1}; 
                3: gray_addr <= {row-7'd1,col}; 
                4: gray_addr <= {row-7'd1,col+7'd1}; 
                5: gray_addr <= {row,col-7'd1}; 
                6: gray_addr <= {row,col+7'd1};
                7: gray_addr <= {row+7'd1,col-7'd1}; 
                8: gray_addr <= {row+7'd1,col}; 
                9: gray_addr <= {row+7'd1,col+7'd1}; 
                default: gray_addr <= 0;
            endcase
            if(cnt_read < 10)
                cnt_read <= cnt_read +1; 
            else
                cnt_read <= 0;
            if(cnt_read == 10)
                read_done <= 1;
        end
        else
        begin
            case (cnt_read)
                2: gray_addr <= {row-7'd1,col+7'd1}; 
                3: gray_addr <= {row,col+7'd1}; 
                4: gray_addr <= {row+7'd1,col+7'd1}; 
                default: gray_addr <= 0;
            endcase
            if(cnt_read < 5)
                cnt_read <= cnt_read +1; 
            else
                cnt_read <= 0;

            if(cnt_read == 5)
                read_done <= 1;
        end
    end
    else
    begin
        read_done <= 0;
        gray_req <= 0;
    end
end

//pix buff

always @(posedge clk) begin
    if(state == READ)
    begin
        
        if(col == 1) //full read
        begin
            case (cnt_read)
                2 :pix[4] <= gray_data;  
                3 :pix[0] <= gray_data; 
                4 :pix[1] <= gray_data;  
                5 :pix[2] <= gray_data;  
                6 :pix[3] <= gray_data;  
                7 :pix[5] <= gray_data;  
                8 :pix[6] <= gray_data;  
                9 :pix[7] <= gray_data;  
                10:pix[8] <= gray_data;  
            endcase
            
            case (cnt_read)
                3 :buffer[0] <= (gray_data >= pix[4]) ? 1:0;  
                4 :buffer[1] <= (gray_data >= pix[4]) ? 1:0;  
                5 :buffer[2] <= (gray_data >= pix[4]) ? 1:0;  
                6 :buffer[3] <= (gray_data >= pix[4]) ? 1:0;  
                7 :buffer[5] <= (gray_data >= pix[4]) ? 1:0;  
                8 :buffer[6] <= (gray_data >= pix[4]) ? 1:0;  
                9 :buffer[7] <= (gray_data >= pix[4]) ? 1:0;  
                10 :buffer[8] <= (gray_data >= pix[4]) ? 1:0;   
            endcase

        end

        else //read three
        begin
            if(cnt_read == 1)
            begin
                pix[0] <= pix[1];
                pix[1] <= pix[2];
                pix[3] <= pix[4];
                pix[4] <= pix[5];
                pix[6] <= pix[7];
                pix[7] <= pix[8];
                pix[0] <= pix[1];
            end
            else if(cnt_read == 2)
            begin
                buffer[0] <= (pix[0] >= pix[4]) ? 1:0;
                buffer[1] <= (pix[1] >= pix[4]) ? 1:0;
                buffer[3] <= (pix[3] >= pix[4]) ? 1:0;
                buffer[6] <= (pix[6] >= pix[4]) ? 1:0;
                buffer[7] <= (pix[7] >= pix[4]) ? 1:0;
            end
            else 
            begin
                case (cnt_read)
                    3 :pix[2] <= gray_data;  
                    4 :pix[5] <= gray_data;  
                    5 :pix[8] <= gray_data;   
                endcase
                
                case (cnt_read)
                    3 :buffer[2] <= (gray_data >= pix[4]) ? 1:0;    
                    4 :buffer[5] <= (gray_data >= pix[4]) ? 1:0;    
                    5 :buffer[8] <= (gray_data >= pix[4]) ? 1:0;     
                endcase
            end
        end
    end
end


//DATA OUTPUT
always@(posedge clk or posedge reset)begin
    if(reset)begin
        lbp_data <= 0;
        cnt_out <= 0;
    end
    else begin
        if(next_state == WRITE)begin
            // if(cnt_out < 4)
            //     lbp_data <= lbp_data + (buffer[cnt_out] << cnt_out); // 0 1 2 3 
            // else 
            //     lbp_data <= lbp_data + (buffer[cnt_out + 1] << cnt_out); // 4 5 6 7

            case (cnt_out)
                0: tmp <= buffer[0];
                1: tmp <= buffer[1];
                2: tmp <= buffer[2];
                3: tmp <= buffer[3];
                4: tmp <= buffer[5];
                5: tmp <= buffer[6];
                6: tmp <= buffer[7];
                7: tmp <= buffer[8];
            endcase
            lbp_data <= lbp_data + (tmp << (cnt_out-1));
            cnt_out <= cnt_out + 1;
        end
        else begin 
            cnt_out <= 0;
            lbp_data <= 0;
        end
    end
end


//====================================================================
endmodule
