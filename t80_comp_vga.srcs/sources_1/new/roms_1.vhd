-- ROM Inference on array
-- File: ug901-vivado-synthesis-examples/roms_1.vhd
-- See also:
--  xilinx_xstug_examples-master/HDL_Coding_Techniques/rams/rams_20c.vhd

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
-- numeric-std is used to replace the proprietary std-logic-unsigned package.
use IEEE.NUMERIC_STD.all;
use std.textio.all;

entity roms_1 is
	generic (
		-- Number of bits in the address bus. The size of the memory will be 2**G_ADDR_BITS bytes.
		G_ADDR_BITS : INTEGER;
		G_INIT_FILE : STRING
	);
	port (
		clk_i : in STD_LOGIC;
                   en : in STD_LOGIC;
                 addr : in STD_LOGIC_VECTOR((G_ADDR_BITS - 1) downto 0);
                 data : out STD_LOGIC_VECTOR(7 downto 0)
	);
end roms_1;

architecture behavioral of roms_1 is
	--    type rom_type is array (0 to 63) of std_logic_vector(7 downto 0);
	--    signal ROM : rom_type :=
	--        (
	--        0       => x"21", --	ld hl,08000h	;0100	21 00 80
	--       10 to 63 => x"00"
	--        );

	type RamType is array (0 to 2 ** (G_ADDR_BITS)) of STD_LOGIC_VECTOR(7 downto 0);

	impure function InitRamFromFile (RamFileName : in STRING) return RamType is
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

	signal ROM : RamType := InitRamFromFile(G_INIT_FILE);

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
