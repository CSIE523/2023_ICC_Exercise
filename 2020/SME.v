module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg [4:0] match_index;
output  valid;


reg [2:0]state, next_state;
parameter IDLE = 3'd0,
	      READ_STRING = 3'd1,
          READ_PATTERN = 3'd2,
	      CAL = 3'd3,
	      OUT = 3'd4;

reg [7:0]str[0:31];
reg [7:0]pat[0:7];

reg [4:0]str_len;
reg [2:0]pat_len;

assign valid = (state == OUT);

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
                if(isstring == 1) next_state = READ_STRING;
                else if(ispattern == 1) next_state = READ_PATTERN;
                else next_state = IDLE;
            end
            READ_STRING:begin
                if(ispattern == 1) next_state = READ_PATTERN;
                else next_state = READ_STRING;  
            end
            READ_PATTERN:begin
                if(ispattern == 0) next_state = CAL;
                else next_state = READ_PATTERN;
            end
            CAL:begin
                // if() next_state = OUT;
                // else next_state = CAL;
                next_state = OUT;
            end 
            OUT:
                if(ispattern == 1) next_state = READ_PATTERN;
                else if(isstring == 1) next_state = READ_STRING; 
                else next_state = OUT;
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk or posedge reset)begin
    if(reset)begin
        str_len <= 0;
        pat_len <= 0;
    end
    else begin
        if(next_state == READ_STRING)begin
            str[str_len] <= chardata;
            str_len <= str_len + 1;
        end 
        else if(next_state == READ_PATTERN)begin
            pat[pat_len] <= chardata;
            pat_len <= pat_len + 1;
        end
        else if(next_state == OUT)begin
            match <= 1;
            match_index <= 1;
        end
    end
end

endmodule
