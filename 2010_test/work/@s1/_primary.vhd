library verilog;
use verilog.vl_types.all;
entity S1 is
    generic(
        IDLE            : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        READ            : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        \OUT\           : vl_logic_vector(0 to 1) := (Hi1, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        RB1_RW          : out    vl_logic;
        RB1_A           : out    vl_logic_vector(4 downto 0);
        RB1_D           : out    vl_logic_vector(7 downto 0);
        RB1_Q           : in     vl_logic_vector(7 downto 0);
        sen             : out    vl_logic;
        sd              : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of READ : constant is 1;
    attribute mti_svvh_generic_type of \OUT\ : constant is 1;
end S1;
