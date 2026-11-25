-- Divider
-- Computes the 9bit fractional quotient of num/den by multiplying
-- 8bit num with the 17bit reciprocal LUT output of 8bit den
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Divider is
    port (
        num  : in  std_logic_vector(7 downto 0); -- 8bit unsigned numerator
        den  : in  std_logic_vector(7 downto 0); -- 8bit unsigned denominator
        quot : out std_logic_vector(8 downto 0)  -- 9bit unsigned fractional quotient
    );
end entity;

architecture beh of Divider is
    
    component inv_lut_256_17bit is
        port (
            address : in  std_logic_vector(7 downto 0);
            inv_out : out std_logic_vector(16 downto 0)
        );
    end component;

    signal inv_den : std_logic_vector(16 downto 0); -- 17bit fixed-point "round(2^17 / den)"
    signal prod    : unsigned(24 downto 0);         -- 25bit product "num * inv_den"

begin

    INV_LUT : inv_lut_256_17bit
        port map (
            address => den,
            inv_out => inv_den
        );
    
    -- the edge case with num=den (45 deg angle) overflows 
    -- the 9 fractional bits by setting the 17th to '1'
    prod <= unsigned(num) * unsigned(inv_den);

    -- discard the 8 unused integer bits (24..17) and 8 lower
    -- guard bits (7..0) to extract the 9-bit fractional quotient
    quot <= (others => '1') when prod(17) = '1' else -- 45 deg edge case
        std_logic_vector(prod(16 downto 8));         -- other angles

end architecture;