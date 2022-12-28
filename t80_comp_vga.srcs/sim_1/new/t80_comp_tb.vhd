----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/28/2022 01:04:39 PM
-- Design Name: 
-- Module Name: t80_comp_tb - Behavioral
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
--    https://fpgatutorial.com/how-to-write-a-basic-testbench-using-vhdl/
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

entity t80_comp_tb is

end t80_comp_tb;

architecture Behavioral of t80_comp_tb is
    -- Clock
    signal clock    : std_logic := '0'; -- clock must be in known state for sim to start!
    signal reset    : std_logic := '0';
    
begin

    -- Reset and clock
    clock <= NOT clock AFTER 5ns;
    reset <= '1', '0' AFTER 10ns;

    -- Instantiate the design under test
    DUT : entity work.t80_comp_top
        port map(
            clk => clock,
            i_reset => reset,
            sw => (others => '0')
        ); -- main_inst

end Behavioral;
