-- Div_Prep_N.vhd
-- Orders two unsigned N bit numbers, flags if swapped
-- and detects the (0,0) input error condition
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Div_Prep_N is
    generic (
        N : positive := 8
    );
    port (
        in_1     : in  std_logic_vector(N-1 downto 0); -- first unsigned input
        in_2     : in  std_logic_vector(N-1 downto 0); -- second unsigned input
        minor    : out std_logic_vector(N-1 downto 0); -- smaller number output 
        major    : out std_logic_vector(N-1 downto 0); -- bigger muber output
        swap     : out std_logic;                      -- '1' if in_1 > in_2, meaning they have been swapped
        zero_div : out std_logic                       -- '1' if in_1 = in_2 = 0
    );
end entity;

architecture beh of Div_Prep_N is
    signal is_zero : std_logic;
    signal is_swap : std_logic;

begin

    is_zero <= '1' when (unsigned(in_1) = 0 and unsigned(in_2) = 0) else '0';
    is_swap <= '1' when (unsigned(in_1) > unsigned(in_2)) else '0';
    
    minor    <= (others => '0') when is_zero = '1' else
                in_2            when is_swap = '1' else
                in_1;
    major    <= (others => '0') when is_zero = '1' else
                in_1            when is_swap = '1' else
                in_2;
    swap     <= is_swap;
    zero_div <= is_zero;

end architecture;