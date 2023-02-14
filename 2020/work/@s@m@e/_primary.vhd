library verilog;
use verilog.vl_types.all;
entity SME is
    generic(
        IDLE            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        READ_STRING     : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        READ_PATTERN    : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        CAL             : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        \OUT\           : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0)
    );
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
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of READ_STRING : constant is 1;
    attribute mti_svvh_generic_type of READ_PATTERN : constant is 1;
    attribute mti_svvh_generic_type of CAL : constant is 1;
    attribute mti_svvh_generic_type of \OUT\ : constant is 1;
end SME;
