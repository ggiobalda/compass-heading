-- DFF_N
-- Parallel D Flip-Flop with configurable number of bits (N), asynchronous reset active low and enable
library ieee;
use ieee.std_logic_1164.all;

entity DFF_N is
    generic (
        N : positive := 8
    );
    port (
        clk   : in  std_logic;                        -- system clock
        arstn : in  std_logic;                        -- asynchronous reset, active low
        en    : in  std_logic;                        -- enable, active high
        d     : in  std_logic_vector(N - 1 downto 0); -- data input
        q     : out std_logic_vector(N - 1 downto 0)  -- data output
    );
end entity;

architecture beh of DFF_N is
begin

    p_DFF_N : process(clk, arstn)
    begin
        if arstn = '0' then
            q <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process;

end architecture;
