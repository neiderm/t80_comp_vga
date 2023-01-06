-- ROM Inference on array
-- File: ug901-vivado-synthesis-examples/roms_1.vhd
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
-- numeric-std is used to replace the proprietary std-logic-unsigned package.
use IEEE.NUMERIC_STD.ALL;

entity roms_1 is
    port (
        clk_i : in  std_logic;
        en    : in  std_logic;
        addr  : in  std_logic_vector(5 downto 0);
        data  : out std_logic_vector(7 downto 0)
    );
end roms_1;

architecture behavioral of roms_1 is

    type rom_type is array (63 downto 0) of std_logic_vector(7 downto 0);

    signal ROM : rom_type :=
        (
        0       => x"21", --	ld hl,08000h	;0100	21 00 80
	    1       => x"00",
        2       => x"80",

        3       => x"af", --	xor a			;0103	af
        4       => x"3c", --	inc a			;0104	3c
        5       => x"77", --	ld (hl),a		;0105	77

        6       => x"c3", --	jp 00004h		;0106	c3 04 00
        7       => x"04",
        8       => x"00",

        9 to 63 => x"00"
        );

    -- attribute rom_style : string;
    -- attribute rom_style of ROM : signal is "block";

begin
    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if (en = '1') then
                -- data <= ROM(conv_integer(addr));
                data <= ROM(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;

end behavioral;
