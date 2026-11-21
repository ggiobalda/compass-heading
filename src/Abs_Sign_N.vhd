-- Abs_Sign_N
-- Extracts the sign bit and unsigned absolute value of an N-bit C2 input
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Abs_Sign_N is
    generic (
        N : positive := 9
    );
    port (
        c2  : in  std_logic_vector(N-1 downto 0); -- C2 number
        mag : out std_logic_vector(N-2 downto 0); -- magnitude
        sgn : out std_logic -- sign
    );
end entity;

architecture beh of Abs_Sign_N is
    -- absolute value as an unsigned number
    signal abs_val : unsigned(N-1 downto 0);

begin

    abs_val  <= unsigned(c2) when c2(N-1) = '0' else unsigned(-signed(c2));
    sgn      <= c2(N-1);
    mag      <= std_logic_vector(abs_val);

end architecture;