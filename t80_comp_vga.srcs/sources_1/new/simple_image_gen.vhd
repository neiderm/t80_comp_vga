----------------------------------------------------------------------------------
-- Simple VGA Pattern Generator
-- Modified for use as component in t80_comp_vga and 12-bit RGB output.
-- Original file:
--  http://www.ece.ualberta.ca/~elliott/ee552/studentAppNotes/1998_w/Altera_UP1_Board_Map/vga.html#anchor2505379
----------------------------------------------------------------------------------

-- RGB VGA test pattern  Rob Chapman  Mar 9, 1998

 -- This file uses the VGA driver and creates 3 squares on the screen which
 -- show all the available colors from mixing red, green and blue

Library IEEE;
use IEEE.STD_Logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity vgatest is
--  port(clock         : in std_logic;
--       R, G, B, H, V : out std_logic);
    port( row, column : in INTEGER;-- std_logic_vector(9 downto 0);
          RGBout      : out std_logic_vector(11 downto 0));
end entity;

architecture test of vgatest is

--  component vgadrive is
--    port( clock          : in std_logic;  -- 25.175 Mhz clock
--        red, green, blue : in std_logic;  -- input values for RGB signals
--        row, column      : out std_logic_vector(9 downto 0); -- for current pixel
--        Rout, Gout, Bout, H, V : out std_logic); -- VGA drive signals
--  end component;
  
--  signal row, column : std_logic_vector(9 downto 0);
  signal red, green, blue : std_logic;

begin
--  -- for debugging: to view the bit order
--  VGA : component vgadrive
--    port map ( clock => clock, red => red, green => green, blue => blue,
--               row => row, column => column,
--               Rout => R, Gout => G, Bout => B, H => H, V => V);
 
  -- red square from 0,0 to 360, 350
  -- green square from 0,250 to 360, 640
  -- blue square from 120,150 to 480,500
  RGB : process(row, column)
  begin
    -- wait until clock = '1';
    
    if  row < 360 and column < 380  then
      red <= '1';
    else
      red <= '0';
    end if;
    
    if  row < 360 and column > 260 and column < 640  then
      green <= '1';
    else
      green <= '0';
    end if;
    
    if  row > 120 and row < 480 and column > 140 and column < 500  then
      blue <= '1';
    else
      blue <= '0';
    end if;

  end process;

  RGBout(11 downto 8) <= x"F" when red   = '1' else x"0";
  RGBout( 7 downto 4) <= x"F" when green = '1' else x"0";
  RGBout( 3 downto 0) <= x"F" when blue  = '1' else x"0";

end architecture;
