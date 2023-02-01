--
-- Description of a ROM with a VHDL signal
--
-- Download: ftp://ftp.xilinx.com/pub/documentation/misc/xstug_examples.zip
-- File: HDL_Coding_Techniques/rams/roms_signal.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity roms_signal is
    port (clk  : in  std_logic;
          en   : in  std_logic;
      pix_x, pix_y : in  INTEGER;
    RGB : out std_logic_vector(11 downto 0));
end roms_signal;

architecture syn of roms_signal is

    type rom_type is array (0 to 639) of std_logic_vector (11 downto 0);
    signal ROM : rom_type:= (
         0   to 159 => x"F00",
         160 to 319 => x"0F0",
         320 to 479 => x"00F",
         480 to 639 => x"FFF"
	);

    signal data : std_logic_vector(11 downto 0);
--    signal addr : std_logic_vector(8 downto 0);
  signal addr : INTEGER;

begin

    process (clk, pix_y, pix_x, en)
    begin
        if (clk'event and clk = '1') then
            if (en = '1') then
                data <= ROM(pix_x); -- ROM(conv_integer(addr));                                       
            end if;
        end if;

      if (pix_x < 160 and pix_y < 120) then
          RGB <= data;
      else
          RGB <= (others => '0');
      end if;

      addr <= pix_y * 160 + pix_x;

    end process;
end syn;
