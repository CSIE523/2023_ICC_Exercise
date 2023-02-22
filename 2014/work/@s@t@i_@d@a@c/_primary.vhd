library verilog;
use verilog.vl_types.all;
entity STI_DAC is
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
end STI_DAC;
