library verilog;
use verilog.vl_types.all;
entity RB1 is
    generic(
        BITS            : integer := 8;
        word_depth      : integer := 18;
        addr_width      : integer := 5;
        wordx           : vl_notype;
        addrx           : vl_notype
    );
    port(
        Q               : out    vl_logic_vector(7 downto 0);
        CLK             : in     vl_logic;
        CEN             : in     vl_logic;
        WEN             : in     vl_logic;
        A               : in     vl_logic_vector(4 downto 0);
        D               : in     vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of BITS : constant is 1;
    attribute mti_svvh_generic_type of word_depth : constant is 1;
    attribute mti_svvh_generic_type of addr_width : constant is 1;
    attribute mti_svvh_generic_type of wordx : constant is 3;
    attribute mti_svvh_generic_type of addrx : constant is 3;
end RB1;
