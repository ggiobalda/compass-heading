-- Subtractor_N
-- N bit C2 subtractor (diff = op1 - op2)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Subtractor_N is
    generic (
        N : positive := 9
    );
    port (
        op1  : in  std_logic_vector(N-1 downto 0); -- first operand of the subtraction
        op2  : in  std_logic_vector(N-1 downto 0); -- second operand of the subtraction
        diff : out std_logic_vector(N-1 downto 0)  -- result of the operation
    );
end entity;

architecture beh of Subtractor_N is
begin

    diff <= std_logic_vector(signed(op1) - signed(op2));

end architecture;
