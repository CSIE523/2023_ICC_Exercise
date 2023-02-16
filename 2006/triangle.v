module triangle (clk, reset, nt, xi, yi, busy, po, xo, yo);
    input clk, reset, nt;
    input [2:0] xi, yi;
    output reg busy, po;
    output reg [2:0] xo, yo;

reg [2:0]state, next_state;
parameter IDLE = 3'd0,
	  READ = 3'd1,
	  CAL_OUT = 3'd2;

reg [2:0] x1, y1, x2, y2, x3, y3;
reg [1:0] counter;
reg [2:0] x, y;
reg [1:0] mode;

wire [5:0] to12, to23, to31;

assign to12 = (x2 - x1) * (y - y1) - (x - x1) * (y2 - y1);
assign to23 = (x3 - x2) * (y - y2) - (x - x2) * (y3 - y2);
assign to31 = (x1 - x3) * (y - y3) - (x - x3) * (y1 - y3);


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
                if(nt == 1)next_state = READ;
                else next_state = IDLE;
            READ:begin
                if(counter == 3) next_state = CAL_OUT;
                else next_state = READ;  
            end
            CAL_OUT:begin
                if(x == 7 && y == 7) next_state = IDLE;
                else next_state = CAL_OUT;
            end 
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk)begin
  if(next_state == IDLE)begin
    busy <= 0;
    counter <= 0;
    po <= 0;
    mode <= 0;
  end
  else if(next_state == READ)begin
    case(counter)
      0:begin
        x1 <= xi;
        y1 <= yi;
        counter <= counter + 1;
      end
      1:begin
        x2 <= xi;
        y2 <= yi;
        counter <= counter + 1;
        busy <= 1;
      end
      2:begin
        x3 <= xi;
        y3 <= yi;
        counter <= counter + 1;
      end
    endcase
  end
  else if(next_state == CAL_OUT)begin
    counter <= 0;
    if(y == y1 && x >= x1 && x <= x2)begin
      po <= 1;
      xo <= x;
      yo <= y;
      mode <= 1;
    end
    else if(x == x1 && y >= y1 && y <= y3)begin
      po <= 1;
      xo <= x;
      yo <= y;
      mode <= 2;
    end
    else if((to12 < 6'd32 && to23 < 6'd32 && to31 < 6'd32) || (to12 > 6'd31 && to23 > 6'd31 && to31 > 6'd31))begin
      po <= 1;
      xo <= x;
      yo <= y;
      mode <= 3;
    end
    else po <= 0;
  end
end


//INDEX
always@(posedge clk or posedge reset)begin
  if(reset)begin
    x <= 1;
    y <= 1;
  end
  else if(next_state == CAL_OUT)begin
    if(x == 7)begin
      y <= y + 1;
      x <= 1;
    end
    else
      x <= x + 1;
  end
end    

endmodule
