library verilog;
use verilog.vl_types.all;
entity huffman is
    generic(
        IDLE            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        INIT            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        CNT_OUT         : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        READ            : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        COMB            : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        SPLIT           : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1);
        \OUT\           : vl_logic_vector(0 to 2) := (Hi1, Hi1, Hi0)
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        gray_data       : in     vl_logic_vector(7 downto 0);
        gray_valid      : in     vl_logic;
        CNT_valid       : out    vl_logic;
        CNT1            : out    vl_logic_vector(7 downto 0);
        CNT2            : out    vl_logic_vector(7 downto 0);
        CNT3            : out    vl_logic_vector(7 downto 0);
        CNT4            : out    vl_logic_vector(7 downto 0);
        CNT5            : out    vl_logic_vector(7 downto 0);
        CNT6            : out    vl_logic_vector(7 downto 0);
        code_valid      : out    vl_logic;
        HC1             : out    vl_logic_vector(7 downto 0);
        HC2             : out    vl_logic_vector(7 downto 0);
        HC3             : out    vl_logic_vector(7 downto 0);
        HC4             : out    vl_logic_vector(7 downto 0);
        HC5             : out    vl_logic_vector(7 downto 0);
        HC6             : out    vl_logic_vector(7 downto 0);
        M1              : out    vl_logic_vector(7 downto 0);
        M2              : out    vl_logic_vector(7 downto 0);
        M3              : out    vl_logic_vector(7 downto 0);
        M4              : out    vl_logic_vector(7 downto 0);
        M5              : out    vl_logic_vector(7 downto 0);
        M6              : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of INIT : constant is 1;
    attribute mti_svvh_generic_type of CNT_OUT : constant is 1;
    attribute mti_svvh_generic_type of READ : constant is 1;
    attribute mti_svvh_generic_type of COMB : constant is 1;
    attribute mti_svvh_generic_type of SPLIT : constant is 1;
    attribute mti_svvh_generic_type of \OUT\ : constant is 1;
end huffman;
