----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/28/2022 04:24:52 PM
-- Design Name: 
-- Module Name: simple_image_gen - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- GN: 
--  simple vga test from switches ECE448_lecture9_VGA_1.pdf and P. Chu, FPGA Prototyping by VHDL Examples Chapter 12, VGA Controller I:
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity simple_image_gen is
    Port ( clk      : in STD_LOGIC;
           disp_ena : in STD_LOGIC;       -- not really used, as long as nothing is registered in this module
           reset_n  : in STD_LOGIC;
           -- 12-bit RGB for Basys-3
           bits_in  :  IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
           rgb      :  OUT  STD_LOGIC_VECTOR(11 DOWNTO 0));
end simple_image_gen;

architecture Behavioral of simple_image_gen is

begin
    -- image generator from switches to rgb buffer
    process (clk, reset_n)
    begin
        if reset_n = '0' then
            rgb <= (others => '0');

        elsif (clk'event and clk = '1') then
            rgb <= bits_in(11 downto 0);

        end if;
    end process;

end Behavioral;
