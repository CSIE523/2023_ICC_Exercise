library verilog;
use verilog.vl_types.all;
entity DT is
    generic(
        IDLE            : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        FOR_READ_ROM    : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        FOR_READ_RAM    : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi0);
        FOR_WRITE_RAM   : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi1);
        CHANGE_DIR      : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi0);
        BAC_FIND        : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi1);
        BAC_READ_RAM    : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi0);
        BAC_WRITE_RAM   : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi1);
        ZERO_CASE       : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi0);
        FINISH          : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi1)
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        done            : out    vl_logic;
        sti_rd          : out    vl_logic;
        sti_addr        : out    vl_logic_vector(9 downto 0);
        sti_di          : in     vl_logic_vector(15 downto 0);
        res_wr          : out    vl_logic;
        res_rd          : out    vl_logic;
        res_addr        : out    vl_logic_vector(13 downto 0);
        res_do          : out    vl_logic_vector(7 downto 0);
        res_di          : in     vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of FOR_READ_ROM : constant is 1;
    attribute mti_svvh_generic_type of FOR_READ_RAM : constant is 1;
    attribute mti_svvh_generic_type of FOR_WRITE_RAM : constant is 1;
    attribute mti_svvh_generic_type of CHANGE_DIR : constant is 1;
    attribute mti_svvh_generic_type of BAC_FIND : constant is 1;
    attribute mti_svvh_generic_type of BAC_READ_RAM : constant is 1;
    attribute mti_svvh_generic_type of BAC_WRITE_RAM : constant is 1;
    attribute mti_svvh_generic_type of ZERO_CASE : constant is 1;
    attribute mti_svvh_generic_type of FINISH : constant is 1;
end DT;
