library verilog;
use verilog.vl_types.all;
entity flash_b is
    generic(
        MaxData         : vl_logic_vector(0 to 7) := (Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1);
        BlockNum        : integer := 127;
        BlockSize       : integer := 3;
        PageNum         : vl_logic_vector(0 to 11) := (Hi0, Hi0, Hi0, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1);
        PageSize        : integer := 511;
        IDLE            : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        RESET           : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        RD_A0           : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi0);
        RD_A1           : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi1);
        BUFF_TR         : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi0);
        RD              : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi1);
        PREL_PRG        : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi0);
        PRG_A0          : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi1);
        PRG_A1          : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi0);
        DATA_PRG        : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi1);
        PGMS            : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi1, Hi0);
        RDY_PRG         : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi1, Hi1);
        PREL_ERS        : vl_logic_vector(0 to 3) := (Hi1, Hi1, Hi0, Hi0);
        ERS_A1          : vl_logic_vector(0 to 3) := (Hi1, Hi1, Hi0, Hi1);
        ERS_A2          : vl_logic_vector(0 to 3) := (Hi1, Hi1, Hi1, Hi0);
        BERS_EXEC       : vl_logic_vector(0 to 3) := (Hi1, Hi1, Hi1, Hi1);
        READ_A          : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        READ_B          : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        NONE            : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        STAT            : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1)
    );
    port(
        IO7             : inout  vl_logic;
        IO6             : inout  vl_logic;
        IO5             : inout  vl_logic;
        IO4             : inout  vl_logic;
        IO3             : inout  vl_logic;
        IO2             : inout  vl_logic;
        IO1             : inout  vl_logic;
        IO0             : inout  vl_logic;
        CLE             : in     vl_logic;
        ALE             : in     vl_logic;
        CENeg           : in     vl_logic;
        RENeg           : in     vl_logic;
        WENeg           : in     vl_logic;
        R               : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MaxData : constant is 1;
    attribute mti_svvh_generic_type of BlockNum : constant is 1;
    attribute mti_svvh_generic_type of BlockSize : constant is 1;
    attribute mti_svvh_generic_type of PageNum : constant is 1;
    attribute mti_svvh_generic_type of PageSize : constant is 1;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of RESET : constant is 1;
    attribute mti_svvh_generic_type of RD_A0 : constant is 1;
    attribute mti_svvh_generic_type of RD_A1 : constant is 1;
    attribute mti_svvh_generic_type of BUFF_TR : constant is 1;
    attribute mti_svvh_generic_type of RD : constant is 1;
    attribute mti_svvh_generic_type of PREL_PRG : constant is 1;
    attribute mti_svvh_generic_type of PRG_A0 : constant is 1;
    attribute mti_svvh_generic_type of PRG_A1 : constant is 1;
    attribute mti_svvh_generic_type of DATA_PRG : constant is 1;
    attribute mti_svvh_generic_type of PGMS : constant is 1;
    attribute mti_svvh_generic_type of RDY_PRG : constant is 1;
    attribute mti_svvh_generic_type of PREL_ERS : constant is 1;
    attribute mti_svvh_generic_type of ERS_A1 : constant is 1;
    attribute mti_svvh_generic_type of ERS_A2 : constant is 1;
    attribute mti_svvh_generic_type of BERS_EXEC : constant is 1;
    attribute mti_svvh_generic_type of READ_A : constant is 1;
    attribute mti_svvh_generic_type of READ_B : constant is 1;
    attribute mti_svvh_generic_type of NONE : constant is 1;
    attribute mti_svvh_generic_type of STAT : constant is 1;
end flash_b;