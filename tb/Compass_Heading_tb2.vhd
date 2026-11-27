-- Compass_Heading_tb2
-- Used to test divider stage (LUT + mul + slice)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Compass_Heading_tb2 is
end entity;

architecture struct of Compass_Heading_tb2 is
    
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

                -- release biases, num=0 den=100 -> 0.0 (quot = 0)
                when 2 =>
                    a_ext      <= std_logic_vector(to_signed(0, 8));
                    b_ext      <= std_logic_vector(to_signed(100, 8));
                    a_bias_ext <= '0';
                    b_bias_ext <= '0';

                -- num=1 den=4 -> 0.25 (quot = 128)
                when 4 =>
                    a_ext <= std_logic_vector(to_signed(1, 8));
                    b_ext <= std_logic_vector(to_signed(4, 8));

                -- num=1 den=2 -> 0.50 (quot = 256)
                when 6 =>
                    a_ext <= std_logic_vector(to_signed(1, 8));
                    b_ext <= std_logic_vector(to_signed(2, 8));

                -- num=3 den=4 -> 0.75 (quot = 384)
                when 8 =>
                    a_ext <= std_logic_vector(to_signed(3, 8));
                    b_ext <= std_logic_vector(to_signed(4, 8));

                -- non power of 2 den: num=40 den=120 -> 1/3 (quot = 170)
                when 10 =>
                    a_ext <= std_logic_vector(to_signed(40, 8));
                    b_ext <= std_logic_vector(to_signed(120, 8));

                -- loads bias = -128 so magnitudes up to 255 are reachable
                when 11 =>
                    a_ext      <= std_logic_vector(to_signed(-128, 8));
                    b_ext      <= std_logic_vector(to_signed(-128, 8));
                    a_bias_ext <= '1';
                    b_bias_ext <= '1';

                -- smallest non-zero ratio: num=1 den=255 -> quot = 2
                when 12 =>
                    a_ext      <= std_logic_vector(to_signed(-127, 8));
                    b_ext      <= std_logic_vector(to_signed(127, 8));
                    a_bias_ext <= '0';
                    b_bias_ext <= '0';

                -- largest strictly < 1 ratio: num=254 den=255 -> quot = 509
                when 14 =>
                    a_ext <= std_logic_vector(to_signed(126, 8));
                    b_ext <= std_logic_vector(to_signed(127, 8));

                -- 45 deg diagonal with rounded-up LUT[3]=43691: num=den=3 -> quot = 511
                when 16 =>
                    a_ext <= std_logic_vector(to_signed(-125, 8));
                    b_ext <= std_logic_vector(to_signed(-125, 8));

                -- 45-deg diagonal at max scale: num=den=255 -> quot = 511
                when 18 =>
                    a_ext <= std_logic_vector(to_signed(127, 8));
                    b_ext <= std_logic_vector(to_signed(127, 8));

                -- division by zero check: num=den=0 -> zero_div = '1', quot = 0
                when 20 =>
                    a_ext <= std_logic_vector(to_signed(-128, 8));
                    b_ext <= std_logic_vector(to_signed(-128, 8));

                -- async reset
                when 22 =>
                    reset <= '0';

                -- test ending
                when 24 =>
                    testing <= false;

                when others =>
                    null;
            end case;
        
            t := t + 1;
        end if;
    end process;

end architecture;   