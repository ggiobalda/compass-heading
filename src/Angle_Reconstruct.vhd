-- Angle_Reconstruct
-- Combinational logic that reconstructs the full-scale angle,
-- given a base angle, swap bit to determine the octant and axis
-- signs to determine the quadrant

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Angle_Reconstruct is
    port (
        base_angle : in  std_logic_vector(7 downto 0); -- octant angle
        swap       : in  std_logic;                    -- octant number
        sgn_y      : in  std_logic;                    -- y-axis sign
        sgn_x      : in  std_logic;                    -- x-axis sign
        full_angle : out std_logic_vector(10 downto 0) -- output angle
    );
end entity;

architecture beh of Angle_Reconstruct is

    -- useful angles in the 11 bits full-scale angle range (2048 possible values) 
    constant DEG_90  : unsigned(10 downto 0) := to_unsigned(512, 11);  --  90 deg = 2048 / 4
    constant DEG_180 : unsigned(10 downto 0) := to_unsigned(1024, 11); -- 180 deg = 2048 / 2

    signal oct_ext    : unsigned(10 downto 0);        -- octant angle:      [0,45]  -> (0,255)
    signal quad_angle : unsigned(10 downto 0);        -- quadrant angle:    [0,90]  -> (0,511)
    signal circ_angle : unsigned(10 downto 0);        -- full-circle angle: [0,360] -> (0,2047)
    signal signs      : std_logic_vector(1 downto 0); -- quadrant selector

begin
    
    -- 8bit octant angle is firstly extended to 11bit, then reflected if the 
    -- axis had been swapped and finally translated to the right quadrant
    oct_ext    <= unsigned("000" & base_angle);
    quad_angle <= (DEG_90 - oct_ext) when swap = '1' else oct_ext;
    signs      <= sgn_y & sgn_x;
    circ_angle <= quad_angle           when signs = "00" else -- first quadrant
                  DEG_180 - quad_angle when signs = "01" else -- second quadrant
                  0 - quad_angle       when signs = "10" else -- fourth quadrant     
                  DEG_180 + quad_angle;                       -- third quadrant

    full_angle <= std_logic_vector(circ_angle);

end architecture;

    