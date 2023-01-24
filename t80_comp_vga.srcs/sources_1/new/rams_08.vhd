--
-- Single-Port RAM with Enable
--
-- Download: ftp://ftp.xilinx.com/pub/documentation/misc/xstug_examples.zip
-- File: HDL_Coding_Techniques/rams/rams_08.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rams_08 is
	port (
		clk : in std_logic;
		en  : in std_logic;
		we  : in std_logic;
		a   : in std_logic_vector(9 downto 0);
		di  : in std_logic_vector(7 downto 0);
		do  : out std_logic_vector(7 downto 0)
	);
end rams_08;

architecture syn of rams_08 is
	type ram_type is array (0 to 1023) of std_logic_vector (7 downto 0);
	-- intialize memory, otherwise unwritten locations remain UU in simulation
	-- signal RAM : ram_type := (others => (others => '0'));
	signal RAM : ram_type := -- initial values for help debugging in sim
	(
	0 => x"FE",
	1 => x"FD", 
	2 => x"FC", 
	3 => x"FB",
	4 => x"FA",
	5 => x"F9",
	6 => x"F8",
	7 => x"F7",
	8 => x"F6", 
	9 => x"F5", 
	10 to 1023 => x"00"
	);
	signal read_a : std_logic_vector(9 downto 0);
begin
	process (clk)
	begin
		if (clk'EVENT and clk = '1') then
			if (en = '1') then
				if (we = '1') then
					RAM(conv_integer(a)) <= di;
				end if;
				read_a <= a;
			end if;
		end if;
	end process;

	do <= RAM(conv_integer(read_a));

end syn;