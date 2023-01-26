--
-- 8-to-1 1-bit MUX using a Case statement.
--
-- Download: ftp://ftp.xilinx.com/pub/documentation/misc/xstug_examples.zip
-- File: HDL_Coding_Techniques/multiplexers/multiplexers_2.vhd
-- Modified to 4-1 8-bit Mux for t80_comp_vga.
--
library ieee;
use ieee.std_logic_1164.all;

entity multiplexers_2 is

    port (di0 : in  std_logic_vector(11 downto 0);
          di1 : in  std_logic_vector(11 downto 0);
          di2 : in  std_logic_vector(11 downto 0);
          di3 : in  std_logic_vector(11 downto 0);
          sel : in  std_logic_vector(1 downto 0);
          do  : out std_logic_vector(11 downto 0));
	  
end multiplexers_2;

architecture archi of multiplexers_2 is
begin
    process (sel, di0, di1, di2, di3)
    begin
        case sel is
            when "00"  => do <= di3;
            when "01"  => do <= di2;
            when "10"  => do <= di1;
            when others => do <= di0;
        end case;
    end process;
end archi;
