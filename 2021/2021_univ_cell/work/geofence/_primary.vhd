library verilog;
use verilog.vl_types.all;
entity geofence is
    generic(
        IDLE            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        READ            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        SORTING         : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        CAL             : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        \OUT\           : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        BUFFF           : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1)
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        X               : in     vl_logic_vector(9 downto 0);
        Y               : in     vl_logic_vector(9 downto 0);
        valid           : out    vl_logic;
        is_inside       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of READ : constant is 1;
    attribute mti_svvh_generic_type of SORTING : constant is 1;
    attribute mti_svvh_generic_type of CAL : constant is 1;
    attribute mti_svvh_generic_type of \OUT\ : constant is 1;
    attribute mti_svvh_generic_type of BUFFF : constant is 1;
end geofence;
