-- Compass_Heading
-- Digital circuit that, given two 8bit C2 magnetometer inputs and stored biases,
-- computes the heading direction as an angle theta
library IEEE;
use IEEE.std_logic_1164.all;

entity Compass_Heading is
    port (
        clk    : in  std_logic;                    -- system clock
        reset  : in  std_logic;                    -- asynchronous reset, active low
        a      : in  std_logic_vector(7 downto 0); -- Y magnetic field intensity
        a_bias : in  std_logic;                    -- Y bias enable
        b      : in  std_logic_vector(7 downto 0); -- X magnetic field intensity
        b_bias : in  std_logic;                    -- X bias enable
        theta  : out std_logic_vector(10 downto 0) -- angle direction
    );
end entity;

architecture struct of Compass_Heading is

    ---------------------------
    -- COMPONENTS DECLARATIONS 
    ---------------------------
    component DFF_N is
        generic (
            N : positive := 8
        );
        port (
            clk     : in  std_logic;
            a_rst_n : in  std_logic;
            en      : in  std_logic;
            d       : in  std_logic_vector(N - 1 downto 0);
            q       : out std_logic_vector(N - 1 downto 0)
        );
    end component; 

    component Subtractor_N is
        generic (
            N : positive := 9
        );
        port (
            op1  : in  std_logic_vector(N-1 downto 0);
            op2  : in  std_logic_vector(N-1 downto 0);
            diff : out std_logic_vector(N-1 downto 0) 
        );
    end component;

    component Abs_Sign_N is
        generic (
            N : positive := 9
        );
        port (
            c2  : in  std_logic_vector(N-1 downto 0);
            mag : out std_logic_vector(N-2 downto 0);
            sgn : out std_logic
        );
    end component;

    component Div_Prep_N is
        generic (
            N : positive := 8
        );
        port (
            in_1     : in  std_logic_vector(N-1 downto 0);
            in_2     : in  std_logic_vector(N-1 downto 0);
            minor    : out std_logic_vector(N-1 downto 0);
            major    : out std_logic_vector(N-1 downto 0);
            swapped  : out std_logic;
            zero_err : out std_logic
        );
    end component;

    component Divider is
        port (
            num  : in  std_logic_vector(7 downto 0); 
            den  : in  std_logic_vector(7 downto 0); 
            quot : out std_logic_vector(8 downto 0)  
        );
    end component;

    component arctan_lut_512_8bit is
        port (
            address    : in  std_logic_vector(8 downto 0);
            arctan_out : out std_logic_vector(7 downto 0)
        );
    end component;

    component Angle_Reconstruct is
        port (
            base_angle : in  std_logic_vector(7 downto 0);
            swap       : in  std_logic;
            sgn_y      : in  std_logic;
            sgn_x      : in  std_logic;
            full_angle : out std_logic_vector(10 downto 0)
        );
    end component;    

    ---------------------------
    -- SIGNALS DECLARATIONS
    ---------------------------
    -- input register barrier's output signals
    signal a_reg      : std_logic_vector(7 downto 0);
    signal b_reg      : std_logic_vector(7 downto 0);
    signal a_bias_reg : std_logic_vector(7 downto 0);
    signal b_bias_reg : std_logic_vector(7 downto 0);

    -- 9 bit C2 sign-extended signals
    signal a_ext      : std_logic_vector(8 downto 0);
    signal b_ext      : std_logic_vector(8 downto 0);
    signal a_bias_ext : std_logic_vector(8 downto 0);
    signal b_bias_ext : std_logic_vector(8 downto 0);

    -- calibrated inputs signals
    signal a_cal : std_logic_vector(8 downto 0);
    signal b_cal : std_logic_vector(8 downto 0);

    -- module and sign of inputs signals
    signal a_abs : std_logic_vector(7 downto 0);
    signal a_sgn : std_logic;
    signal b_abs : std_logic_vector(7 downto 0);
    signal b_sgn : std_logic;

    -- numerator, denominator, swap and zero_div signals for division block. quot is the output
    signal num      : std_logic_vector(7 downto 0);
    signal den      : std_logic_vector(7 downto 0);
    signal swap     : std_logic;
    signal zero_div : std_logic;
    signal quot     : std_logic_vector(8 downto 0);

    -- LUT output, angle in the first octant
    signal angle_oct : std_logic_vector(7 downto 0);

begin

    -- input barrier registers
    REG_A : DFF_N
        generic map (
            N => 8
        )
        port map (
            clk     => clk,
            a_rst_n => reset,
            en      => '1',
            d       => a,
            q       => a_reg
        );

    REG_B : DFF_N
        generic map (
            N => 8
        )
        port map (
            clk     => clk,
            a_rst_n => reset,
            en      => '1',
            d       => b,
            q       => b_reg
        );
    
    -- bias registers
    REG_A_BIAS : DFF_N
        generic map (
            N => 8
        )
        port map (
            clk     => clk,
            a_rst_n => reset,
            en      => a_bias,
            d       => a,
            q       => a_bias_reg
        );
    
    REG_B_BIAS : DFF_N
        generic map (
            N => 8
        )
        port map (
            clk     => clk,
            a_rst_n => reset,
            en      => b_bias,
            d       => b,
            q       => b_bias_reg
        );
    
    -- sign extension
    a_ext      <= a_reg(7) & a_reg;
    b_ext      <= b_reg(7) & b_reg;
    a_bias_ext <= a_bias_reg(7) & a_bias_reg;
    b_bias_ext <= b_bias_reg(7) & b_bias_reg;

    -- subtractors to compute calibrated inputs
    SUB_A : Subtractor_N
        generic map (
            N => 9
        )
        port map (
            op1  => a_ext,
            op2  => a_bias_ext,
            diff => a_cal
        );

    SUB_B : Subtractor_N
        generic map (
            N => 9
        )
        port map (
            op1  => b_ext,
            op2  => b_bias_ext,
            diff => b_cal
        );
    
    -- combinational logic to extract module and sign
    ABS_SGN_A : Abs_Sign_N
        generic map (
            N => 9
        )
        port map (
            c2  => a_cal,
            mag => a_abs,
            sgn => a_sgn
        );
    
    ABS_SGN_B : Abs_Sign_N
        generic map (
            N => 9
        )
        port map (
            c2  => b_cal,
            mag => b_abs,
            sgn => b_sgn
        );
    
    -- combinational logic to prepare for division
    DIV_PREP : Div_Prep_N
        generic map (
            N => 8
        )
        port map (
            in_1     => a_abs,
            in_2     => b_abs,
            minor    => num,
            major    => den,
            swapped  => swap,
            zero_err => zero_div
        );

    -- divider block, quot = num/den
    DIV : Divider
        port map (
            num  => num,
            den  => den,
            quot => quot
        );

    -- arctan lookup, angle_oct = arctan(quot)
    ARCTAN_LUT : arctan_lut_512_8bit
        port map (
            address    => quot,
            arctan_out => angle_oct
        );
    
    -- full-scale angle reconstruction
    ANGLE_REC : Angle_Reconstruct
        port map (
            base_angle => angle_oct,
            swap       => swap,
            sgn_y      => a_sgn,
            sgn_x      => b_sgn,
            full_angle => theta
        );

end architecture;

    