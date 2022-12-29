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
        clk          : in STD_LOGIC;
        i_reset      : in STD_LOGIC;

        Hsync, Vsync : out std_logic;
        vgaRed, vgaGreen, vgaBlue : out std_logic_vector(3 downto 0);

        -- test IO
        sw       : in std_logic_vector(15 downto 0);
        JA2, JA1 : out std_logic;
        led      : out std_logic_vector(3 downto 0)
    );

end t80_comp_top;

architecture Behavioral of t80_comp_top is

    signal clk25     : std_logic;
    signal n_reset   : std_logic;
    signal clk_div16 : std_logic;

    signal video_on          : std_logic;
    signal pixel_x, pixel_y  : integer;

    signal rgb_reg_0         : std_logic_vector(11 downto 0);
    signal rgb_reg_1         : std_logic_vector(11 downto 0);

    -- baggage?
    signal rgb_reg                      : std_logic_vector(11 downto 0);


    signal SEL               : std_logic;

begin
    -- drive IO
    -- test IO
    JA1 <= clk25;
    JA2 <= clk_div16;
    led <= sw(15 downto 12);

    SEL <= sw(15);
    
    n_reset <= not i_reset;

    --------------------------------------------------
    -- select image generator and drive the VGA outputs
    --------------------------------------------------
    rgb_reg  <= rgb_reg_0 when (SEL = '1') else rgb_reg_1;

    vgaRed   <= (rgb_reg(11 downto 8)) when video_on = '1' else (others => '0');
    vgaGreen <= (rgb_reg(7 downto 4)) when video_on = '1' else (others  => '0');
    vgaBlue  <= (rgb_reg(3 downto 0)) when video_on = '1' else (others  => '0');

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

    --------------------------------------------------
    -- Instantiate VGA sync circuit
    --------------------------------------------------
    vga_control_unit : entity work.vga_controller
        port map(
            pixel_clk => clk25,
            reset_n   => n_reset,
            h_sync    => Hsync,
            v_sync    => Vsync,
            disp_ena  => video_on,
            column    => pixel_x,
            row       => pixel_y,
            n_blank   => open,
            n_sync    => open
        );

    --------------------------------------------------
    -- Instantiate image generator
    --------------------------------------------------
    image_gen_0 : entity work.simple_image_gen
        port map(
            clk      => clk,
            reset_n  => n_reset,
            disp_ena => video_on,
            bits_in  => sw(11 downto 0),
            rgb      => rgb_reg_0);

    --------------------------------------------------
    -- Instantiate image generator 2 to another rgb buffer
    --------------------------------------------------
    image_gen_unit : entity work.hw_image_generator
        port map(
            disp_ena => video_on,
            row      => pixel_x,
            column   => pixel_y,

            red      => rgb_reg_1(11 downto 8),
            green    => rgb_reg_1(7 downto 4),
            blue     => rgb_reg_1(3 downto 0));            

end Behavioral;
