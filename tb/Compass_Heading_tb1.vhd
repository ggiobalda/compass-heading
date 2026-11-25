-- Compass_Heading_tb1
-- Used to test correct input calibration and
-- combinational logic up to the division module
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Compass_Heading_tb1 is
end entity;

architecture struct of Compass_Heading_tb1 is
    
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
                -- release reset and set biases: a=+20, b=-30
                when 1 =>
                    reset      <= '1';
                    a_ext      <= std_logic_vector(to_signed(20, 8));
                    a_bias_ext <= '1';
                    b_ext      <= std_logic_vector(to_signed(-30, 8));
                    b_bias_ext <= '1';

                -- set a and b values same as bias -> calibrated signals should be 0
                when 2 =>
                    a_bias_ext <= '0';
                    b_bias_ext <= '0';
                    a_ext      <= std_logic_vector(to_signed(20, 8));
                    b_ext      <= std_logic_vector(to_signed(-30, 8));

                -- set both calibrated values positive with no swap 
                when 4 =>
                    a_ext      <= std_logic_vector(to_signed(60, 8));
                    b_ext      <= std_logic_vector(to_signed(90, 8));

                -- set both calibrated values negative with swap
                when 6 =>
                    a_ext      <= std_logic_vector(to_signed(-100, 8));
                    b_ext      <= std_logic_vector(to_signed(-70, 8));

                -- set same absolute value with different signs
                when 8 =>
                    a_ext      <= std_logic_vector(to_signed(100, 8));
                    b_ext      <= std_logic_vector(to_signed(-110, 8));

                -- set bias values to the edges (-128 and +127)
                when 10 =>
                    a_ext      <= std_logic_vector(to_signed(127, 8));
                    a_bias_ext <= '1';
                    b_ext      <= std_logic_vector(to_signed(-128, 8));
                    b_bias_ext <= '1';

                -- set input values to get the extremes of calibrated ones (+-255)
                when 11 =>
                    a_bias_ext <= '0';
                    b_bias_ext <= '0';
                    a_ext      <= std_logic_vector(to_signed(-128, 8));
                    b_ext      <= std_logic_vector(to_signed(127, 8));

                -- async reset
                when 13 =>
                    reset      <= '0';

                -- test ending
                when 15 =>
                    testing    <= false;

                when others =>
                    null;
            end case;
        
            t := t + 1;
        end if;
    end process;

end architecture;   