-- Compass_Heading_tb1
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
    signal theta_ext  : std_logic_vector(10 downto 0) := (others => '0');
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
                -- 1. Release active-low reset & load initial biases: a_cal = +20, b_cal = -30
                when 1 =>
                    reset      <= '1';
                    a_ext      <= std_logic_vector(to_signed(20, 8));
                    a_bias_ext <= '1';
                    b_ext      <= std_logic_vector(to_signed(-30, 8));
                    b_bias_ext <= '1';

                -- 2. Zero vector after calibration: diff_a = 0, diff_b = 0 -> zero_err = '1'
                when 2 =>
                    a_bias_ext <= '0';
                    b_bias_ext <= '0';
                    a_ext      <= std_logic_vector(to_signed(20, 8));
                    b_ext      <= std_logic_vector(to_signed(-30, 8));

                -- 3. Positive diffs, |diff_a| < |diff_b| (no swap):
                --    diff_a = 60 - 20 = +40, diff_b = 90 - (-30) = +120 -> num = 40, den = 120
                when 4 =>
                    a_ext      <= std_logic_vector(to_signed(60, 8));
                    b_ext      <= std_logic_vector(to_signed(90, 8));

                -- 4. Negative diffs, |diff_a| > |diff_b| (swap):
                --    diff_a = -100 - 20 = -120, diff_b = -70 - (-30) = -40 -> num = 40, den = 120
                when 6 =>
                    a_ext      <= std_logic_vector(to_signed(-100, 8));
                    b_ext      <= std_logic_vector(to_signed(-70, 8));

                -- 5. Equal magnitudes & mixed signs (45 deg case):
                --    diff_a = 100 - 20 = +80, diff_b = -110 - (-30) = -80 -> num = 80, den = 80
                when 8 =>
                    a_ext      <= std_logic_vector(to_signed(100, 8));
                    b_ext      <= std_logic_vector(to_signed(-110, 8));

                -- 6. Reload max opposite biases: a_cal = +127, b_cal = -128
                when 10 =>
                    a_ext      <= std_logic_vector(to_signed(127, 8));
                    a_bias_ext <= '1';
                    b_ext      <= std_logic_vector(to_signed(-128, 8));
                    b_bias_ext <= '1';

                -- 7. Full-scale extremes (+-255):
                --    diff_a = -128 - 127 = -255, diff_b = 127 - (-128) = +255 -> num = 255, den = 255
                when 11 =>
                    a_bias_ext <= '0';
                    b_bias_ext <= '0';
                    a_ext      <= std_logic_vector(to_signed(-128, 8));
                    b_ext      <= std_logic_vector(to_signed(127, 8));

                -- 8. Verify active-low reset clears registers
                when 13 =>
                    reset      <= '0';

                when 15 =>
                    testing    <= false;

                when others =>
                    null;
            end case;
        
            t := t + 1;
        end if;
    end process;

end architecture;   