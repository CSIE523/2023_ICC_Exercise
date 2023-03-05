library verilog;
use verilog.vl_types.all;
entity JAM is
    generic(
        IDLE            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        FIND_BIGGER     : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        FIND_BIGGER_SMALLEST: vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        CHANGE          : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        CAL             : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        FINISH          : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1)
    );
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        W               : out    vl_logic_vector(2 downto 0);
        J               : out    vl_logic_vector(2 downto 0);
        Cost            : in     vl_logic_vector(6 downto 0);
        MatchCount      : out    vl_logic_vector(3 downto 0);
        MinCost         : out    vl_logic_vector(9 downto 0);
        Valid           : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of FIND_BIGGER : constant is 1;
    attribute mti_svvh_generic_type of FIND_BIGGER_SMALLEST : constant is 1;
    attribute mti_svvh_generic_type of CHANGE : constant is 1;
    attribute mti_svvh_generic_type of CAL : constant is 1;
    attribute mti_svvh_generic_type of FINISH : constant is 1;
end JAM;
