library verilog;
use verilog.vl_types.all;
entity S2 is
    generic(
        IDLE            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        DELAY           : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        READ            : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        \OUT\           : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        FINISH          : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        S2_done         : out    vl_logic;
        RB2_RW          : out    vl_logic;
        RB2_A           : out    vl_logic_vector(2 downto 0);
        RB2_D           : out    vl_logic_vector(17 downto 0);
        RB2_Q           : in     vl_logic_vector(17 downto 0);
        sen             : in     vl_logic;
        sd              : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of DELAY : constant is 1;
    attribute mti_svvh_generic_type of READ : constant is 1;
    attribute mti_svvh_generic_type of \OUT\ : constant is 1;
    attribute mti_svvh_generic_type of FINISH : constant is 1;
end S2;
