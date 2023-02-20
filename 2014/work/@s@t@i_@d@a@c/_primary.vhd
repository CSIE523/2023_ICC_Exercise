library verilog;
use verilog.vl_types.all;
entity STI_DAC is
    generic(
        IDLE            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        READ            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        CAL             : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        STI_OUT         : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        FINISH_0        : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        FINISH          : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1)
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        load            : in     vl_logic;
        pi_data         : in     vl_logic_vector(15 downto 0);
        pi_length       : in     vl_logic_vector(1 downto 0);
        pi_fill         : in     vl_logic;
        pi_msb          : in     vl_logic;
        pi_low          : in     vl_logic;
        pi_end          : in     vl_logic;
        so_data         : out    vl_logic;
        so_valid        : out    vl_logic;
        pixel_finish    : out    vl_logic;
        pixel_dataout   : out    vl_logic_vector(7 downto 0);
        pixel_addr      : out    vl_logic_vector(7 downto 0);
        pixel_wr        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of READ : constant is 1;
    attribute mti_svvh_generic_type of CAL : constant is 1;
    attribute mti_svvh_generic_type of STI_OUT : constant is 1;
    attribute mti_svvh_generic_type of FINISH_0 : constant is 1;
    attribute mti_svvh_generic_type of FINISH : constant is 1;
end STI_DAC;
