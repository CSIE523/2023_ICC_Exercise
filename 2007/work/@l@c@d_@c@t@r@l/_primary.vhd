library verilog;
use verilog.vl_types.all;
entity LCD_CTRL is
    generic(
        READ_OP         : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        READ            : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        CAL             : vl_logic_vector(0 to 1) := (Hi1, Hi0);
        \OUT\           : vl_logic_vector(0 to 1) := (Hi1, Hi1);
        REFLASH         : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        LOADDATA        : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        ZOOMIN          : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        ZOOMOUT         : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        SHIFT_RIGHT     : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        SHIFT_LEFT      : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1);
        SHIFT_UP        : vl_logic_vector(0 to 2) := (Hi1, Hi1, Hi0);
        SHIFT_DOWN      : vl_logic_vector(0 to 2) := (Hi1, Hi1, Hi1)
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        datain          : in     vl_logic_vector(7 downto 0);
        cmd             : in     vl_logic_vector(2 downto 0);
        cmd_valid       : in     vl_logic;
        dataout         : out    vl_logic_vector(7 downto 0);
        output_valid    : out    vl_logic;
        busy            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of READ_OP : constant is 1;
    attribute mti_svvh_generic_type of READ : constant is 1;
    attribute mti_svvh_generic_type of CAL : constant is 1;
    attribute mti_svvh_generic_type of \OUT\ : constant is 1;
    attribute mti_svvh_generic_type of REFLASH : constant is 1;
    attribute mti_svvh_generic_type of LOADDATA : constant is 1;
    attribute mti_svvh_generic_type of ZOOMIN : constant is 1;
    attribute mti_svvh_generic_type of ZOOMOUT : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_RIGHT : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_LEFT : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_UP : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_DOWN : constant is 1;
end LCD_CTRL;
