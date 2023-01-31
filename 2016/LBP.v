 
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

reg state, next_state;
parameter IDLE = 3'd0,
        READ = 3'd1; 

reg [7:0] data[0:8];
reg [3:0] counter; 

assign finish = (lbp_addr == 14'd16257);

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
            READ:
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
        lbp_valid <= 0;
        gray_req <= 0;
        gray_addr <= 0;
        lbp_addr <= 129;
    end
    else begin
        if(state == READ)begin
            case(counter)
                0:begin
                    gray_addr <= lbp_addr - 129;
                    gray_req <= 1;
                    counter <= counter + 1;
                end
                1:begin
                    gray_addr <= lbp_addr - 1;
                    data[0] <= gray_data;
                    counter <= counter + 1;
                end
                2:begin
                    gray_addr <= lbp_addr + 127;
                    data[3] <= gray_data;
                    counter <= counter + 1;
                end
                3:begin
                    gray_addr <= lbp_addr - 128;
                    data[6] <= gray_data;
                    counter <= counter + 1;
                end
                4:begin
                    gray_addr <= lbp_addr;
                    data[1] <= gray_data;
                    counter <= counter + 1;
                end
                5:begin
                    gray_addr <= lbp_addr + 128;
                    data[4] <= gray_data;
                    counter <= counter + 1;
                end
                6:begin
                    gray_addr <= lbp_addr - 127;
                    data[7] <= gray_data;
                    counter <= counter + 1;
                end
                7:begin
                    gray_addr <= lbp_addr + 1;
                    data[2] <= gray_data;
                    counter <= counter + 1;
                end
                8:begin
                    gray_addr <= lbp_addr + 129;
                    data[5] <= gray_data;
                    counter <= counter + 1;
                end
                9:begin
                    lbp_data[0] <= (data[0] >= data[4]);
                    lbp_data[1] <= (data[1] >= data[4]);
                    lbp_data[2] <= (data[2] >= data[4]);
                    lbp_data[3] <= (data[3] >= data[4]);
                    lbp_data[4] <= (data[5] >= data[4]);
                    lbp_data[5] <= (data[6] >= data[4]);
                    lbp_data[6] <= (data[7] >= data[4]);
                    lbp_data[7] <= (gray_data >= data[4]);
                    data[8] <= gray_data;
                    gray_req <= 0;
                    lbp_valid <= 0;
                    counter <= counter + 1;
                end
                10:begin
                    lbp_valid <= 1;
                    lbp_addr <= lbp_addr;
                    counter <= counter + 1;
                end
                11:begin
                    lbp_valid <= 0;
                    if(lbp_addr[6:0] == 126)begin
                        lbp_addr[6:0] <= 1;
                        counter <= 0;
                        lbp_addr[13:7] <= lbp_addr[13:7] + 1; 
                    end
                    else begin
                        lbp_addr[6:0] <= lbp_addr[6:0] + 1;
                        counter <= counter + 1;
                    end
                end
                12:begin
                    data[0] <= data[1];
                    data[3] <= data[4];
                    data[6] <= data[7];
                    data[1] <= data[2];
                    data[4] <= data[5];
                    data[7] <= data[8];
                    gray_req <= 1;
                    gray_addr <= lbp_addr - 127;
                    counter <= 7;
                end
                default: counter <= 0;
            endcase
        end
    end
end

endmodule
