library verilog;
use verilog.vl_types.all;
entity LBP is
    generic(
        IDLE            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        READ            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        WRITE_0         : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        SHIFT           : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1)
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        gray_addr       : out    vl_logic_vector(13 downto 0);
        gray_req        : out    vl_logic;
        gray_ready      : in     vl_logic;
        gray_data       : in     vl_logic_vector(7 downto 0);
        lbp_addr        : out    vl_logic_vector(13 downto 0);
        lbp_valid       : out    vl_logic;
        lbp_data        : out    vl_logic_vector(7 downto 0);
        finish          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of READ : constant is 1;
    attribute mti_svvh_generic_type of WRITE_0 : constant is 1;
    attribute mti_svvh_generic_type of SHIFT : constant is 1;
end LBP;
