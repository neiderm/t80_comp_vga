----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/22/2023 03:34:47 PM
-- Design Name: 
-- Module Name: sig_int - Behavioral
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
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sig_int is
    port (
        n_sig_in   : in  std_logic;
        n_reset_in : in  std_logic;
        n_irq_out  : out std_logic);
end sig_int;

architecture Behavioral of sig_int is
    signal irq_latch : std_logic;

begin
    process (n_sig_in)
    begin
        if falling_edge(n_sig_in) then
            irq_latch <= '0';
            --vsync_cntr <= vsync_cntr + 1;
        end if;

        if n_reset_in = '0' then
            irq_latch <= '1';
        end if;
        n_irq_out <= irq_latch;

    end process;
end Behavioral;
