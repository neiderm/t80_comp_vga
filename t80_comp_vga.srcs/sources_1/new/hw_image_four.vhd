-- Based on vhdlguide but modified for t80_com_vga to use as component:
--  https://vhdlguide.readthedocs.io/en/latest/vhdl/dex.html#fig-sync-vga-visualtest2

-- sync_VGA_visualTest2.vhd

-- created by   :   Meher Krishna Patel
-- date         :   27-Dec-16

-- Functionality:
  -- display four squares of different colors on the screen

-- ports:
  -- VGA_CLK : 25 MHz clock for VGA operation (generated by sync_VGA.vhd file)
  -- VGA_BLANK : required for VGA operations and set to 1
  -- VGA_HS and VGA_VS : synchronization signals required for VGA operation
  -- VGA_R, VGA_G and VGA_B : 10 bit RGB signals for displaying colors on screen
  
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_VGA_visualTest2 is
   port (
--      CLOCK_50, reset: in std_logic;
--      VGA_CLK, VGA_BLANK : out std_logic;
--      VGA_HS, VGA_VS: out  std_logic;
--      VGA_R, VGA_G, VGA_B: out std_logic_vector(9 downto 0)

--        video_on            : in  std_logic;
        disp_ena            : in  std_logic;
        pix_x, pix_y        : in  integer;
        VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0)
   );
end sync_VGA_visualTest2;

architecture arch of sync_VGA_visualTest2 is
--  signal rgb_reg: std_logic_vector(2 downto 0);
--  signal video_on: std_logic;
--  signal pixel_x, pixel_y : std_logic_vector (9 downto 0);
--  signal pix_x, pix_y : integer;
begin
--  -- set VGA_BLANK to 1
--  VGA_BLANK <='1';
--
--   -- instantiate sync_VGA for synchronization 
--   sync_VGA_unit: entity work.sync_VGA
--      port map(clk=>CLOCK_50, reset=>reset, hsync=>VGA_HS,
--                  vsync=>VGA_VS, video_on=>video_on,
--                  vga_clk=>VGA_CLK, pixel_x=>pixel_x, pixel_y=>pixel_y);
--          
--  pix_x <= to_integer(unsigned(pixel_x));
--  pix_y <= to_integer(unsigned(pixel_y));
--  process(CLOCK_50)

  process (disp_ena, pix_x, pix_y) -- component process
  begin
--    if (video_on = '1') then
    if (disp_ena = '1') then
      -- divide VGA screen i.e. 640-by-480 in four equal parts
      -- and display different colors in those parts

      -- Red color
      if (pix_x < 320 and pix_y < 240) then -- 640/2 = 320 and 480/2 = 240
        VGA_R <= (others=>'1');  -- send '1' to all 10 bits of VGA_R
        VGA_G <= (others=>'0');
        VGA_B <= (others=>'0');

      -- Green color
      elsif (pix_x >= 320 and pix_y < 240) then
        VGA_R <= (others=>'0');
        VGA_G <= (others=>'1');
        VGA_B <= (others=>'0');

      -- Blue color
      elsif (pix_x < 320 and pix_y >= 240) then
        VGA_R <= (others=>'0');
        VGA_G <= (others=>'0');
        VGA_B <= (others=>'1');

      -- Yellow color
      else
        VGA_R <= (others=>'1');
        VGA_G <= (others=>'1');
        VGA_B <= (others=>'0');     
      end if;
    else
      VGA_R <= (others=>'0');
      VGA_G <= (others=>'0');
      VGA_B <= (others=>'0');
    end if;
  end process;
end arch;
