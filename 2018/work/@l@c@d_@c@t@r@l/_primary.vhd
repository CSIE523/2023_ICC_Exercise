library verilog;
use verilog.vl_types.all;
entity LCD_CTRL is
    generic(
        IDLE            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        GIVE_POS        : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        READ_DATA       : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        CAL             : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        \OUT\           : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        FINISH          : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1);
        WRITE           : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        SHIFT_UP        : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        SHIFT_DOWN      : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi0);
        SHIFT_LEFT      : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi1);
        SHIFT_RIGHT     : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi0);
        MAX             : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi1);
        MIN             : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi0);
        AVERAGE         : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi1);
        COUNTERCLOCK_ROTATE: vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi0);
        CLOCK_ROTATE    : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi1);
        MIRROR_X        : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi1, Hi0);
        MIRROR_Y        : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi1, Hi1)
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        cmd             : in     vl_logic_vector(3 downto 0);
        cmd_valid       : in     vl_logic;
        IROM_Q          : in     vl_logic_vector(7 downto 0);
        IROM_rd         : out    vl_logic;
        IROM_A          : out    vl_logic_vector(5 downto 0);
        IRAM_valid      : out    vl_logic;
        IRAM_D          : out    vl_logic_vector(7 downto 0);
        IRAM_A          : out    vl_logic_vector(5 downto 0);
        busy            : out    vl_logic;
        done            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of GIVE_POS : constant is 1;
    attribute mti_svvh_generic_type of READ_DATA : constant is 1;
    attribute mti_svvh_generic_type of CAL : constant is 1;
    attribute mti_svvh_generic_type of \OUT\ : constant is 1;
    attribute mti_svvh_generic_type of FINISH : constant is 1;
    attribute mti_svvh_generic_type of WRITE : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_UP : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_DOWN : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_LEFT : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_RIGHT : constant is 1;
    attribute mti_svvh_generic_type of MAX : constant is 1;
    attribute mti_svvh_generic_type of MIN : constant is 1;
    attribute mti_svvh_generic_type of AVERAGE : constant is 1;
    attribute mti_svvh_generic_type of COUNTERCLOCK_ROTATE : constant is 1;
    attribute mti_svvh_generic_type of CLOCK_ROTATE : constant is 1;
    attribute mti_svvh_generic_type of MIRROR_X : constant is 1;
    attribute mti_svvh_generic_type of MIRROR_Y : constant is 1;
end LCD_CTRL;
