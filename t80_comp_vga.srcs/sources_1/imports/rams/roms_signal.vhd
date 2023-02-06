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
  GENERIC(
    img_h :  integer := 64;   --tmp image h
    img_w :  integer := 160); --tmp image w
    port (
        clk : in std_logic;
        en  : in std_logic;
        -- addr : in std_logic_vector(6 downto 0);
        pix_y  : in integer; --row pixel coordinate
        pix_x  : in integer; --column pixel coordinate
        data   : out std_logic_vector(11 downto 0)
    );
end roms_signal;

architecture syn of roms_signal is

    type rom_type is array (0 to (img_h*img_w-1)) of std_logic_vector (11 downto 0);
    signal ROM : rom_type := (
           0 to 2559  => x"F00",
        2560 to 5119  => x"0F0",
        5120 to 7679  => x"00F",
        7680 to 10239 => x"FFF"
    );

    -- signal addr : std_logic_vector(6 downto 0);
    signal addr : integer;

begin
    addr <= pix_y * img_w + pix_x;

    process (clk)
    begin
        if (clk'event and clk = '1') then
            if (en = '1') then
--                data <= ROM(addr);
                IF(pix_y < img_h AND pix_x < img_w) THEN  -- tmp test
                  data <= ROM(addr);
                ELSE
                  data <= (others => '0');
                END IF;

            end if;
        end if;
    end process;
end syn;

