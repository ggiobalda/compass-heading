-- Compass_Heading_tb3
-- Used to test the Arctan LUT
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Compass_Heading_tb3 is
end entity;

architecture struct of Compass_Heading_tb3 is

    constant CLK_PERIOD : time := 100 ns;

    component Compass_Heading is
        port (
            clk    : in  std_logic;
            reset  : in  std_logic;
            a      : in  std_logic_vector(7 downto 0);
            a_bias : in  std_logic;
            b      : in  std_logic_vector(7 downto 0);
            b_bias : in  std_logic;
            theta  : out std_logic_vector(10 downto 0)
        );
    end component;

    signal clk        : std_logic                     := '0';
    signal reset      : std_logic                     := '0';
    signal a_ext      : std_logic_vector(7 downto 0)  := (others => '0');
    signal a_bias_ext : std_logic                     := '0';
    signal b_ext      : std_logic_vector(7 downto 0)  := (others => '0');
    signal b_bias_ext : std_logic                     := '0';
    signal theta_ext  : std_logic_vector(10 downto 0);
    signal testing    : boolean                       := true;

begin

    clk <= not clk after CLK_PERIOD/2 when testing else '0';

    DUT : Compass_Heading
        port map (
            clk    => clk,
            reset  => reset,
            a      => a_ext,
            a_bias => a_bias_ext,
            b      => b_ext,
            b_bias => b_bias_ext,
            theta  => theta_ext
        );

    STIMULUS : process (clk)
        variable t : integer := 0;
    begin
        if rising_edge(clk) then
            case t is
                -- release reset and set biases to 0
                when 1 =>
                    reset      <= '1';
                    a_ext      <= std_logic_vector(to_signed(0, 8));
                    b_ext      <= std_logic_vector(to_signed(0, 8));
                    a_bias_ext <= '1';
                    b_bias_ext <= '1';

                -- ratio = 0/100 = 0.000 -> quot = 0, angle_oct = 0 (0.00 deg)
                when 2 =>
                    a_ext      <= std_logic_vector(to_signed(0, 8));
                    b_ext      <= std_logic_vector(to_signed(100, 8));
                    a_bias_ext <= '0';
                    b_bias_ext <= '0';

                -- ratio = 1/8 = 0.125 -> quot = 64, angle_oct = 41 (7.21 deg)
                when 4 =>
                    a_ext <= std_logic_vector(to_signed(1, 8));
                    b_ext <= std_logic_vector(to_signed(8, 8));

                -- ratio = 1/4 = 0.250 -> quot = 128, angle_oct = 80 (14.06 deg)
                when 6 =>
                    a_ext <= std_logic_vector(to_signed(1, 8));
                    b_ext <= std_logic_vector(to_signed(4, 8));

                -- ratio = 40/120 = 0.333 -> quot = 170, angle_oct = 104 (18.28 deg)
                when 8 =>
                    a_ext <= std_logic_vector(to_signed(40, 8));
                    b_ext <= std_logic_vector(to_signed(120, 8));

                -- ratio = 1/2 = 0.500 -> quot = 256, angle_oct = 151 (26.54 deg)
                when 10 =>
                    a_ext <= std_logic_vector(to_signed(1, 8));
                    b_ext <= std_logic_vector(to_signed(2, 8));

                -- ratio = 3/4 = 0.750 -> quot = 384, angle_oct = 210 (36.91 deg)
                when 12 =>
                    a_ext <= std_logic_vector(to_signed(3, 8));
                    b_ext <= std_logic_vector(to_signed(4, 8));

                -- ratio = 7/8 = 0.875 -> quot = 448, angle_oct = 234 (41.13 deg)
                when 14 =>
                    a_ext <= std_logic_vector(to_signed(7, 8));
                    b_ext <= std_logic_vector(to_signed(8, 8));

                -- ratio = 3/3 = 1.000 -> quot = 511, angle_oct = 255 (capped 44.82 deg)
                when 16 =>
                    a_ext <= std_logic_vector(to_signed(3, 8));
                    b_ext <= std_logic_vector(to_signed(3, 8));

                -- async reset
                when 18 =>
                    reset <= '0';

                -- end simulation
                when 20 =>
                    testing <= false;

                when others =>
                    null;
            end case;

            t := t + 1;
        end if;
    end process;

end architecture;
