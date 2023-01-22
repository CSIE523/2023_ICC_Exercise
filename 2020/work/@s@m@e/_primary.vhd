library verilog;
use verilog.vl_types.all;
entity SME is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        chardata        : in     vl_logic_vector(7 downto 0);
        isstring        : in     vl_logic;
        ispattern       : in     vl_logic;
        valid           : out    vl_logic;
        match           : out    vl_logic;
        match_index     : out    vl_logic_vector(4 downto 0)
    );
end SME;
