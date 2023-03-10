library verilog;
use verilog.vl_types.all;
entity LCD_CTRL is
    generic(
        IDLE            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        READ            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        CAL             : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        \OUT\           : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        FINISH          : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        WRITE           : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        SHIFT_UP        : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        SHIFT_DOWN      : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        SHIFT_LEFT      : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        SHIFT_RIGHT     : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        AVERAGE         : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1);
        MIRROR_X        : vl_logic_vector(0 to 2) := (Hi1, Hi1, Hi0);
        MIRROR_Y        : vl_logic_vector(0 to 2) := (Hi1, Hi1, Hi1)
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        IROM_Q          : in     vl_logic_vector(7 downto 0);
        cmd             : in     vl_logic_vector(2 downto 0);
        cmd_valid       : in     vl_logic;
        IROM_EN         : out    vl_logic;
        IROM_A          : out    vl_logic_vector(5 downto 0);
        IRB_RW          : out    vl_logic;
        IRB_D           : out    vl_logic_vector(7 downto 0);
        IRB_A           : out    vl_logic_vector(5 downto 0);
        busy            : out    vl_logic;
        done            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of READ : constant is 1;
    attribute mti_svvh_generic_type of CAL : constant is 1;
    attribute mti_svvh_generic_type of \OUT\ : constant is 1;
    attribute mti_svvh_generic_type of FINISH : constant is 1;
    attribute mti_svvh_generic_type of WRITE : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_UP : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_DOWN : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_LEFT : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_RIGHT : constant is 1;
    attribute mti_svvh_generic_type of AVERAGE : constant is 1;
    attribute mti_svvh_generic_type of MIRROR_X : constant is 1;
    attribute mti_svvh_generic_type of MIRROR_Y : constant is 1;
end LCD_CTRL;
