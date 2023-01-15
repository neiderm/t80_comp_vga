-- ROM Inference on array
-- File: ug901-vivado-synthesis-examples/roms_1.vhd
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
-- numeric-std is used to replace the proprietary std-logic-unsigned package.
use IEEE.NUMERIC_STD.all;
use std.textio.all;

entity roms_1 is
	port (
		clk_i : in std_logic;
		en : in std_logic;
		addr : in std_logic_vector(8 downto 0);
		data : out std_logic_vector(7 downto 0)
	);
end roms_1;

architecture behavioral of roms_1 is
--    type rom_type is array (0 to 63) of std_logic_vector(7 downto 0);
--    signal ROM : rom_type :=
--        (
--        0       => x"21", --	ld hl,08000h	;0100	21 00 80
--        1       => x"00",
--        2       => x"80",
--        3       => x"af", --	xor a			;0103	af
--        4       => x"7e", --    ld a,(hl)
--        5       => x"3c", --	inc a			;0104	3c
--        6       => x"77", --	ld (hl),a		;0105	77
--        7       => x"c3", --	jp 00004h		;0106	c3 04 00
--        8       => x"04",
--        9       => x"00",
--       10 to 63 => x"00"
--        );

	-- xilinx_xstug_examples-master/HDL_Coding_Techniques/rams/rams_20c.vhd
	type RamType is array (0 to 63) of std_logic_vector(7 downto 0);

	impure function InitRamFromFile (RamFileName : in string) return RamType is
	file RamFile : text is in RamFileName;
	file TestFile : text;
	variable RamFileLine : line;
	variable RAM : RamType;
begin
    --file_open(RamFile, RamFileName, read_mode); -- is in ramfilename
    for I in RamType'range loop
        -- read (RamFileLine, RAM(I));
        if (not endfile(RamFile)) then
            readline (RamFile, RamFileLine);
            if (RamFileLine'length > 0) then ---prbably overkill
                hread (RamFileLine, RAM(i)); -- requires VHDL 2008
            else
                report "Line length zero!";
            end if;
        else
            report "End of file reached!";
            exit; --break out of loop
        end if;
	end loop;
	file_close(RamFile);
	return RAM;
end function;

signal ROM : RamType := InitRamFromFile("/home/xubuntu/src/t80_comp_vga/z80test_hex.dat");
--Signal ROM : RamType := InitRamFromFile("z80test_hex.dat"); -- borked

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
