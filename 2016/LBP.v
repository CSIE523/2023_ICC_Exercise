 
`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output  reg [13:0] 	gray_addr;
output         	gray_req;
input   	    gray_ready;
input   [7:0] 	gray_data;
output   [13:0] 	lbp_addr;
output 	 lbp_valid;
output   [7:0] 	lbp_data;
output  	finish;

reg state, next_state;
parameter IDLE = 3'd0,
        READ = 3'd1; 

reg [6:0] row, col;
reg [7:0] data[0:8];
reg [3:0] counter; 

assign finish = (lbp_addr == 14'd16257);
// assign finish = (row == 0);

assign lbp_data[0] = (data[0] >= data[4]);
assign lbp_data[3] = (data[3] >= data[4]);
assign lbp_data[5] = (data[6] >= data[4]);
assign lbp_data[1] = (data[1] >= data[4]);
assign lbp_data[2] = (data[2] >= data[4]);
assign lbp_data[4] = (data[5] >= data[4]);
assign lbp_data[6] = (data[7] >= data[4]);
assign lbp_data[7] = (data[8] >= data[4]);

assign lbp_valid = (counter == 10);
assign gray_req = (gray_ready == 1);
assign lbp_addr = {row, col};

integer i;

// always@(posedge clk or posedge reset)begin
//     if(reset)
//         state <= IDLE;
//     else 
//         state <= next_state;
// end

// always@(*)begin
//     if(reset)
//         next_state = IDLE;
//     else begin
//         case(state)
//             IDLE:
//                 next_state = READ;
//             READ:
//                 next_state = READ;
//             default:    next_state = IDLE;
//         endcase
//     end 
// end


//DATA INPUT
always@(posedge clk or posedge reset)begin
    if(reset)begin
        for(i=0;i<9;i=i+1)
            data[i] <= 0;
        counter <= 0;
        // gray_addr <= 14'd129;
        // lbp_addr <= 14'd129;
        row <= 1;
        col <= 1;
    end
    else begin
        // if(state == READ)begin
            case(counter)
                4'd0:begin
                    // gray_addr <= gray_addr - 14'd129;
                    gray_addr <= {row-7'd1, col-7'd1};
                    counter <= counter + 4'd1;
                end
                4'd1:begin
                    // gray_addr <= gray_addr + 14'd128;
                    gray_addr <= {row, col-7'd1};
                    data[0] <= gray_data;
                    counter <= counter + 4'd1;
                end
                4'd2:begin
                    // gray_addr <= gray_addr + 14'd128;
                    gray_addr <= {row+7'd1, col-7'd1};
                    data[3] <= gray_data;
                    counter <= counter + 4'd1;
                end
                4'd3:begin
                    // gray_addr <= gray_addr - 14'd255;
                    gray_addr <= {row-7'd1, col};
                    data[6] <= gray_data;
                    counter <= counter + 4'd1;
                end
                4'd4:begin
                    // gray_addr <= gray_addr + 14'd128;
                    gray_addr <= {row, col};
                    data[1] <= gray_data;
                    counter <= counter + 4'd1;
                end
                4'd5:begin
                    // gray_addr <= gray_addr + 14'd128;
                    gray_addr <= {row+7'd1, col};
                    data[4] <= gray_data;
                    counter <= counter + 4'd1;
                end
                4'd6:begin
                    // gray_addr <= gray_addr - 14'd255;
                    gray_addr <= {row-7'd1, col+7'd1};
                    data[7] <= gray_data;
                    counter <= counter + 4'd1;
                end
                4'd7:begin
                    // gray_addr <= gray_addr + 14'd128;
                    gray_addr <= {row, col+7'd1};
                    data[2] <= gray_data;
                    counter <= counter + 4'd1;
                end
                4'd8:begin
                    // gray_addr <= gray_addr + 14'd128;
                    gray_addr <= {row+7'd1, col+7'd1};
                    data[5] <= gray_data;
                    counter <= counter + 4'd1;
                end
                4'd9:begin
                    data[8] <= gray_data;
                    counter <= counter + 4'd1;
                end
                4'd10:begin
                    // lbp_addr <= lbp_addr;
                    //lbp_addr <= {row, col};
                    // counter <= counter + 4'd1;
                    if(col == 126)begin
                        counter <= 0;
                        row <= row + 1;
                        col <= 1;
                    end
                    else begin
                        counter <= counter + 1;
                        col <= col + 1;
                    end
                end
                // 4'd11:begin
                //     // if(lbp_addr[6:0] == 7'd126)begin
                //     //     counter <= 0;
                //     //     lbp_addr[6:0] <= 7'd1; 
                //     //     lbp_addr[13:7] <= lbp_addr[13:7] + 7'd1;
                //     //     gray_addr <= gray_addr - 14'd126;
                //     // end
                //     // else begin
                //     //     lbp_addr[6:0] <= lbp_addr[6:0] + 7'd1;
                //     //     counter <= counter + 4'd1;
                //     // end
                    
                // end
                4'd11:begin
                    data[0] <= data[1];
                    data[3] <= data[4];
                    data[6] <= data[7];
                    data[1] <= data[2];
                    data[4] <= data[5];
                    data[7] <= data[8];
                    // gray_addr <= gray_addr - 14'd255;
                    gray_addr <= {row-7'd1, col+7'd1};
                    counter <= 4'd7;
                end
                default: counter <= 0;
            endcase
        // end
    end
end

endmodule
