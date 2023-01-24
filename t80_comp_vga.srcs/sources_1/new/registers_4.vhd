--
-- Flip-Flop with Positive-Edge Clock and Clock Enable
--
-- Download: ftp://ftp.xilinx.com/pub/documentation/misc/xstug_examples.zip
-- File: HDL_Coding_Techniques/registers/registers_4.vhd
--   Modified to 8-bit data for t80_comp_vga
--
library ieee;
use ieee.std_logic_1164.all;

entity registers_4 is
    port(C,  CE : in std_logic;
         D      : in std_logic_vector(7 downto 0);
         Q      : out std_logic_vector(7 downto 0));
end registers_4;

architecture archi of registers_4 is
begin

    process (C)
    begin
        if (C'event and C='1') then
            if (CE='1') then
                Q <= D;
            end if;
        end if;
    end process;

end archi;
