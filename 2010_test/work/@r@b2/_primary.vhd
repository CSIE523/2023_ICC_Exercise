library verilog;
use verilog.vl_types.all;
entity RB2 is
    generic(
        BITS            : integer := 18;
        word_depth      : integer := 8;
        addr_width      : integer := 3;
        wordx           : vl_notype;
        addrx           : vl_notype
    );
    port(
        Q               : out    vl_logic_vector(17 downto 0);
        CLK             : in     vl_logic;
        CEN             : in     vl_logic;
        WEN             : in     vl_logic;
        A               : in     vl_logic_vector(2 downto 0);
        D               : in     vl_logic_vector(17 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of BITS : constant is 1;
    attribute mti_svvh_generic_type of word_depth : constant is 1;
    attribute mti_svvh_generic_type of addr_width : constant is 1;
    attribute mti_svvh_generic_type of wordx : constant is 3;
    attribute mti_svvh_generic_type of addrx : constant is 3;
end RB2;
