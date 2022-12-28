----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/28/2022 12:27:59 PM
-- Design Name: 
-- Module Name: t80_comp_top - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity t80_comp_top is
    Port (
        clk : in STD_LOGIC;
        i_reset : in STD_LOGIC;
        -- test IO
        sw : in std_logic_vector(3 downto 0);
        JA2, JA1 : out std_logic;
        led : out std_logic_vector(3 downto 0)
    );

end t80_comp_top;

architecture Behavioral of t80_comp_top is

    signal clk25 : std_logic;
    signal n_reset : std_logic;
    signal clk_div16 : std_logic;

begin

    JA1 <= clk25;
    JA2 <= clk_div16;
    led <= sw;

    n_reset <= not i_reset;

    --------------------------------------------------
    -- Instantiate Clock generation
    --------------------------------------------------
    clk_inst : entity work.clock_div_pow2
        port map(
            i_rst => n_reset, -- not I_RESET (VHDL 2008)
            i_clk => clk,
            o_clk_div2  => open,
            o_clk_div4 => clk25,
            o_clk_div8 => open,
            o_clk_div16 => clk_div16
        );

end Behavioral;
