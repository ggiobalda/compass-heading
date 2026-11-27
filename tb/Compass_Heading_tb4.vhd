-- Compass_Heading_tb4
-- Complete testbench verifying bias calibration, cardinal axes,
-- all 8 octants, corner cases (+-255, 45 deg, 0/0 hold), and reset
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Compass_Heading_tb4 is
end entity;

architecture struct of Compass_Heading_tb4 is

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
                -- release async reset and set biases: a=+10, b=-20
                when 1 =>
                    reset      <= '1';
                    a_ext      <= std_logic_vector(to_signed(10, 8));
                    b_ext      <= std_logic_vector(to_signed(-20, 8));
                    a_bias_ext <= '1';
                    b_bias_ext <= '1';

                -- cardinal 0 deg (+X): a_cal = 0, b_cal = +80 -> theta = 0
                when 2 =>
                    a_ext      <= std_logic_vector(to_signed(10, 8));
                    b_ext      <= std_logic_vector(to_signed(60, 8));
                    a_bias_ext <= '0';
                    b_bias_ext <= '0';

                -- cardinal 90 deg (+Y): a_cal = +80, b_cal = 0 -> theta = 512
                when 5 =>
                    a_ext <= std_logic_vector(to_signed(90, 8));
                    b_ext <= std_logic_vector(to_signed(-20, 8));

                -- cardinal 180 deg (-X): a_cal = 0, b_cal = -80 -> theta = 1024
                when 8 =>
                    a_ext <= std_logic_vector(to_signed(10, 8));
                    b_ext <= std_logic_vector(to_signed(-100, 8));

                -- cardinal 270 deg (-Y): a_cal = -80, b_cal = 0 -> theta = 1536
                when 11 =>
                    a_ext <= std_logic_vector(to_signed(-70, 8));
                    b_ext <= std_logic_vector(to_signed(-20, 8));

                -- octant 0 (0..45 deg): a_cal = +40, b_cal = +80 -> theta = 151 (~26.54 deg)
                when 14 =>
                    a_ext <= std_logic_vector(to_signed(50, 8));
                    b_ext <= std_logic_vector(to_signed(60, 8));

                -- octant 1 (45..90 deg): a_cal = +80, b_cal = +40 -> theta = 361 (~63.46 deg)
                when 17 =>
                    a_ext <= std_logic_vector(to_signed(90, 8));
                    b_ext <= std_logic_vector(to_signed(20, 8));

                -- octant 2 (90..135 deg): a_cal = +80, b_cal = -40 -> theta = 663 (~116.54 deg)
                when 20 =>
                    a_ext <= std_logic_vector(to_signed(90, 8));
                    b_ext <= std_logic_vector(to_signed(-60, 8));

                -- octant 3 (135..180 deg): a_cal = +40, b_cal = -80 -> theta = 873 (~153.46 deg)
                when 23 =>
                    a_ext <= std_logic_vector(to_signed(50, 8));
                    b_ext <= std_logic_vector(to_signed(-100, 8));

                -- octant 4 (180..225 deg): a_cal = -40, b_cal = -80 -> theta = 1175 (~206.54 deg)
                when 26 =>
                    a_ext <= std_logic_vector(to_signed(-30, 8));
                    b_ext <= std_logic_vector(to_signed(-100, 8));

                -- octant 5 (225..270 deg): a_cal = -80, b_cal = -40 -> theta = 1385 (~243.46 deg)
                when 29 =>
                    a_ext <= std_logic_vector(to_signed(-70, 8));
                    b_ext <= std_logic_vector(to_signed(-60, 8));

                -- octant 6 (270..315 deg): a_cal = -80, b_cal = +40 -> theta = 1687 (~296.54 deg)
                when 32 =>
                    a_ext <= std_logic_vector(to_signed(-70, 8));
                    b_ext <= std_logic_vector(to_signed(20, 8));

                -- octant 7 (315..360 deg): a_cal = -40, b_cal = +80 -> theta = 1897 (~333.46 deg)
                when 35 =>
                    a_ext <= std_logic_vector(to_signed(-30, 8));
                    b_ext <= std_logic_vector(to_signed(60, 8));

                -- corner: 45 deg diagonal with den = 3 (prod(17) saturation) -> theta = 255
                when 38 =>
                    a_ext <= std_logic_vector(to_signed(13, 8));
                    b_ext <= std_logic_vector(to_signed(-17, 8));

                -- corner: (0, 0) division-by-zero -> zero_div = '1', theta holds 255
                when 41 =>
                    a_ext <= std_logic_vector(to_signed(10, 8));
                    b_ext <= std_logic_vector(to_signed(-20, 8));

                -- corner: Load max opposite biases: a_bias = +127, b_bias = -128
                when 44 =>
                    a_ext      <= std_logic_vector(to_signed(127, 8));
                    a_bias_ext <= '1';
                    b_ext      <= std_logic_vector(to_signed(-128, 8));
                    b_bias_ext <= '1';

                -- corner: 315 deg diagonal at +-255 max C2 difference -> theta = 1793 (~315.18 deg)
                when 45 =>
                    a_bias_ext <= '0';
                    b_bias_ext <= '0';
                    a_ext      <= std_logic_vector(to_signed(-128, 8));
                    b_ext      <= std_logic_vector(to_signed(127, 8));

                -- async reset mid-operation -> theta clears immediately to 0
                when 48 =>
                    reset <= '0';

                -- End simulation
                when 50 =>
                    testing <= false;

                when others =>
                    null;
            end case;

            t := t + 1;
        end if;
    end process;

end architecture;
