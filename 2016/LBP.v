 
`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output  reg [13:0] 	gray_addr;
output  reg       	gray_req;
input   	    gray_ready;
input   [7:0] 	gray_data;
output  reg [13:0] 	lbp_addr;
output 	reg lbp_valid;
output  reg [7:0] 	lbp_data;
output  	finish;

reg [2:0]state, next_state;
parameter IDLE = 3'd0,
        READ = 3'd1,
        CAL = 3'd2,
        WRITE = 3'd3,
        WRITE_0 = 3'd4,
        SHIFT = 3'd5,
        FINISH = 3'd6;

reg [6:0] row, col;
reg [7:0] data[0:8];
reg [3:0] counter; 
reg read_done;

assign finish = (state == FINISH);

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
                next_state = WRITE_0;
            READ:begin
                if(row == 0 || col == 0 || row == 127 || col ==127)next_state = WRITE_0;
                else if(counter == 9) next_state = CAL;
                else next_state = READ; 
            end
            CAL:begin
                next_state = WRITE;
            end 
            WRITE:begin
                next_state = SHIFT;
            end
            WRITE_0:begin
                if(row == 127 && col == 127) next_state = FINISH;
                else if(row == 0 || col == 0 || row == 127 || col ==127) next_state = WRITE_0;
                else next_state = READ;
            end
            SHIFT:
                next_state = READ;
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk or posedge reset)begin
    if(reset)begin
        for(i=0;i<9;i=i+1)
            data[i] <= 0;
        counter <= 0;
        row <= 0;
        col <= 0;
        lbp_valid <= 0;
        gray_req <= 0;
        gray_addr <= 0;
    end
    else begin
        if(state == READ)begin
            lbp_valid <= 0;
            gray_req <= 1;
            case(counter)
                0:begin
                    gray_addr <= {row-7'd1, col-7'd1};
                    counter <= counter + 1;
                end
                1:begin
                    gray_addr <= {row, col-7'd1};
                    data[0] <= gray_data;
                    counter <= counter + 1;
                end
                2:begin
                    gray_addr <= {row+7'd1, col-7'd1};
                    data[3] <= gray_data;
                    counter <= counter + 1;
                end
                3:begin
                    gray_addr <= {row-7'd1, col};
                    data[6] <= gray_data;
                    counter <= counter + 1;
                end
                4:begin
                    gray_addr <= {row, col};
                    data[1] <= gray_data;
                    counter <= counter + 1;
                end
                5:begin
                    gray_addr <= {row+7'd1, col};
                    data[4] <= gray_data;
                    counter <= counter + 1;
                end
                6:begin
                    gray_addr <= {row-7'd1, col+7'd1};
                    data[7] <= gray_data;
                    counter <= counter + 1;
                end
                7:begin
                    gray_addr <= {row, col+7'd1};
                    data[2] <= gray_data;
                    counter <= counter + 1;
                end
                8:begin
                    gray_addr <= {row+7'd1, col+7'd1};
                    data[5] <= gray_data;
                    counter <= counter + 1;
                end
                9:begin
                    data[8] <= gray_data;
                    counter <= 7;
                end
                default: counter <= 0;
            endcase
        end
        else if(state==CAL)begin
            gray_req <= 0;
            lbp_data[0] <= (data[0] >= data[4]);
            lbp_data[1] <= (data[1] >= data[4]);
            lbp_data[2] <= (data[2] >= data[4]);
            lbp_data[3] <= (data[3] >= data[4]);
            lbp_data[4] <= (data[5] >= data[4]);
            lbp_data[5] <= (data[6] >= data[4]);
            lbp_data[6] <= (data[7] >= data[4]);
            lbp_data[7] <= (data[8] >= data[4]);
        end
        else if(state == WRITE)begin
            lbp_valid <= 1;
            lbp_addr <= {row, col};
            lbp_data <= lbp_data;
            col <= col + 1;
        end
        else if(next_state == WRITE_0)begin
            lbp_addr <= {row, col};
            lbp_data <= 0;
            lbp_valid <= 1;
            if(col == 127)begin
                row <= row + 1;
                col <= 0;
            end
            else 
                col <= col + 1;
            counter <= 0;
        end
        else if(state == SHIFT)begin
            data[0] <= data[1];
            data[3] <= data[4];
            data[6] <= data[7];
            data[1] <= data[2];
            data[4] <= data[5];
            data[7] <= data[8];
            gray_req <= 1;
            gray_addr <= {row-7'd1, col+7'd1};
        end
    end
end

endmodule
