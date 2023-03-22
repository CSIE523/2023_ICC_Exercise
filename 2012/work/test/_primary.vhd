library verilog;
use verilog.vl_types.all;
entity test is
    generic(
        duty            : integer := 10
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of duty : constant is 1;
end test;
