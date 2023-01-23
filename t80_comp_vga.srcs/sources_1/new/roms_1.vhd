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
--       10 to 63 => x"00"
--        );

	-- xilinx_xstug_examples-master/HDL_Coding_Techniques/rams/rams_20c.vhd
	type RamType is array (0 to 512) of std_logic_vector(7 downto 0);

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

Signal ROM : RamType := InitRamFromFile("z80test_hex.dat"); -- added to Vivado project

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

