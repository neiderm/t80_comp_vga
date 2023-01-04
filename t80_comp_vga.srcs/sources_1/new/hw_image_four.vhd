-- Based on vhdlguide but modified for use as component
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
        --      reset: in std_logic;
        disp_ena            : in  std_logic;
        pix_x, pix_y        : in  integer;
        VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0)
    );
end sync_VGA_visualTest2;

architecture arch of sync_VGA_visualTest2 is
begin
    process (pix_x, pix_y)
    begin
        if (disp_ena = '1') then
            -- divide VGA screen i.e. 640-by-480 in four equal parts
            -- and display different colors in those parts

            -- Red color
            if (pix_x < 320 and pix_y < 240) then -- 640/2 = 320 and 480/2 = 240
                VGA_R <= (others => '1'); -- send '1' to all 10 bits of VGA_R
                VGA_G <= (others => '0');
                VGA_B <= (others => '0');

                -- Green color
            elsif (pix_x >= 320 and pix_y < 240) then
                VGA_R <= (others => '0');
                VGA_G <= (others => '1');
                VGA_B <= (others => '0');

                -- Blue color
            elsif (pix_x < 320 and pix_y >= 240) then
                VGA_R <= (others => '0');
                VGA_G <= (others => '0');
                VGA_B <= (others => '1');

                -- Yellow color
            else
                VGA_R <= (others => '1');
                VGA_G <= (others => '1');
                VGA_B <= (others => '0');
            end if;
        else
            VGA_R <= (others => '0');
            VGA_G <= (others => '0');
            VGA_B <= (others => '0');
        end if;
    end process;
end arch;