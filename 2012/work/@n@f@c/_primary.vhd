library verilog;
use verilog.vl_types.all;
entity NFC is
    generic(
        IDLE            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        READ_A          : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        WRITE_B         : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        FINISH          : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        done            : out    vl_logic;
        F_IO_A          : inout  vl_logic_vector(7 downto 0);
        F_CLE_A         : out    vl_logic;
        F_ALE_A         : out    vl_logic;
        F_REN_A         : out    vl_logic;
        F_WEN_A         : out    vl_logic;
        F_RB_A          : in     vl_logic;
        F_IO_B          : inout  vl_logic_vector(7 downto 0);
        F_CLE_B         : out    vl_logic;
        F_ALE_B         : out    vl_logic;
        F_REN_B         : out    vl_logic;
        F_WEN_B         : out    vl_logic;
        F_RB_B          : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of READ_A : constant is 1;
    attribute mti_svvh_generic_type of WRITE_B : constant is 1;
    attribute mti_svvh_generic_type of FINISH : constant is 1;
end NFC;
