-- Compass_Heading
-- Digital circuit that, given two 8bit C2 magnetometer inputs and stored biases,
-- computes the heading direction as an angle theta
library IEEE;
use IEEE.std_logic_1164.all;

entity Compass_Heading is
    generic (
        M : positive := 8; -- division quotient bits
        K : positive := 10 -- angle output bits
    );
    port (
        clk    : in  std_logic;                     -- system clock
        reset  : in  std_logic;                     -- asynchronous reset, active low
        a      : in  std_logic_vector(7 downto 0);  -- Y magnetic field intensity
        a_bias : in  std_logic;                     -- Y bias enable
        b      : in  std_logic_vector(7 downto 0);  -- X magnetic field intensity
        b_bias : in  std_logic;                     -- X bias enable
        theta  : out std_logic_vector(K-1 downto 0) -- angle direction
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
end architecture;

    