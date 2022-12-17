module lcd_ctrl(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output  [7:0]   dataout;
output          output_valid;
output          busy;

reg [2:0]state, next_state;
parameter IDLE = 3'b000;
parameter LOAD = 3'b001;
parameter SEL = 3'b010
parameter SHIFT_R = 3'b011;
parameter SHIFT_L = 3'b100;
parameter SHIFT_U = 3'b101;
parameter SHIFT_D = 3'b110;
parameter OUT = 3'b111;

wire [2:0]pos_x;
wire [2:0]pos_y;

assign pos_y = (state == SEL) ? 

assign output_valid = (state == OUT) ? 1 : 0;

reg [7:0] data_tmp[0:35];
reg [5:0] counter;
reg [3:0] pos_tmp;
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
            IDLE:   next_state = LOAD;
            LOAD:begin
                if(counter == 35) next_state = OUT;
                else next_state = LOAD;   
            end
            SEL:begin
                case(cmd)
                    0: next_state = OUT;
                    1: next_state = LOAD;
                    2: next_state = SHIFT_R;
                    3: next_state = SHIFT_L;
                    4: next_state = SHIFT_U;
                    5: next_state = SHIFT_D;
                    default: next_state = SEL;
                endcase
            end           
            OUT:begin
                if(counter == 8) next_state = SEL;
                else next_state = OUT;
            end
            default:    next_state = OUT;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk or posedge reset)begin
    if(reset)begin
        counter <= 0;
        for(i=0;i<36;i=i+1)
            data_tmp[i] <= 0;
    end
    else begin
        if(state == LOAD)begin
            data_tmp[counter] <= datain;
            counter <= counter + 1;
        end
        else if(state == OUT)
            counter <= counter + 1;
        else
            counter <= 0;
    end
end


endmodule
