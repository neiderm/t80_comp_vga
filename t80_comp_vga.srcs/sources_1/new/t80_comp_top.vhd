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
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity t80_comp_top is
    port (
        vgaRed   : out std_logic_vector(3 downto 0);
        vgaGreen : out std_logic_vector(3 downto 0);
        vgaBlue  : out std_logic_vector(3 downto 0);
        Hsync    : out std_logic;
        Vsync    : out std_logic;

        sw       : in  std_logic_vector(15 downto 0);
        led      : out std_logic_vector(3 downto 0);

        i_reset  : in  std_logic;
        clk      : in  std_logic;

        -- test IO
        JA2, JA1 : out std_logic
    );

end t80_comp_top;

architecture Behavioral of t80_comp_top is

    signal n_reset          : std_logic;
    signal clk25            : std_logic;
    signal clk_div16        : std_logic;

    signal video_on         : std_logic;
    signal pixel_x, pixel_y : integer;

    -- cpu
    --    signal cpu_ena          : std_logic;
    signal cpu_m1_l         : std_logic;
    signal cpu_mreq_l       : std_logic;
    signal cpu_iorq_l       : std_logic;
    signal cpu_rd_l         : std_logic;
    signal cpu_wr_l         : std_logic;
    --    signal cpu_rfsh_l       : std_logic;
    --    signal cpu_halt_l       : std_logic;
    --    signal cpu_wait_l       : std_logic;
    signal cpu_int_l        : std_logic;
    signal cpu_nmi_l        : std_logic;
    --    signal cpu_busrq_l      : std_logic;
    --    signal cpu_busak_l      : std_logic;
    signal cpu_addr         : std_logic_vector(15 downto 0);
    signal cpu_data_out     : std_logic_vector(7 downto 0);
    signal cpu_data_in      : std_logic_vector(7 downto 0);

    -- video
    signal rgb_reg_0        : std_logic_vector(11 downto 0);
    signal rgb_reg_1        : std_logic_vector(11 downto 0);
    signal rgb_reg_2        : std_logic_vector(11 downto 0);

    signal rgb_reg          : std_logic_vector(11 downto 0);

    signal SEL              : std_logic_vector(1 downto 0);

begin
    -- drive IO
    JA1     <= clk25;
    JA2     <= clk_div16;
    led     <= sw(15 downto 12);

    SEL     <= sw(15 downto 14);

    n_reset <= not i_reset;

    --------------------------------------------------
    -- clocks
    --------------------------------------------------
    u_clocks : entity work.clock_div_pow2
        port map(
            i_clk       => clk,
            i_rst       => n_reset, -- not I_RESET (VHDL 2008)

            o_clk_div2  => open,
            o_clk_div4  => clk25,
            o_clk_div8  => open,
            o_clk_div16 => clk_div16
        );

    --------------------------------------------------
    -- video subsystem
    --------------------------------------------------
    vga_control_unit : entity work.vga_controller
        port map(
            pixel_clk => clk25,
            reset_n   => n_reset,
            h_sync    => Hsync,
            v_sync    => Vsync,
            disp_ena  => video_on, -- out
            column    => pixel_x,
            row       => pixel_y,
            n_blank   => open,
            n_sync    => open
        );

    --------------------------------------------------
    -- internal program rom
    --------------------------------------------------
    u_program_rom : entity work.roms_1
        port map(
            clk_i            => clk_div16, -- todo cpu clock rate?
            en               => '1', -- ena_6
            addr(5 downto 0) => cpu_addr(5 downto 0), -- 64-byte test ROM
            data             => cpu_data_in -- program_rom_dinl 
        );
    --------------------------------------------------
    -- Instantiate t80
    --------------------------------------------------
    u_cpu : entity work.T80s
        port map(
            RESET_n => n_reset, -- watchdog_reset_l,
            CLK_n   => clk_div16,
            WAIT_n  => '1', -- cpu_wait_l,
            INT_n   => cpu_int_l,
            NMI_n   => cpu_nmi_l,
            BUSRQ_n => '1', -- cpu_busrq_l,
            M1_n    => cpu_m1_l,
            MREQ_n  => cpu_mreq_l,
            IORQ_n  => cpu_iorq_l,
            RD_n    => cpu_rd_l,
            WR_n    => cpu_wr_l,
            --              RFSH_n  => cpu_rfsh_l,
            --              HALT_n  => cpu_halt_l,
            --              BUSAK_n => cpu_busak_l,
            A       => cpu_addr,
            DI      => cpu_data_in,
            DO      => cpu_data_out
        );

    --------------------------------------------------
    -- select image generator and drive the VGA outputs
    --------------------------------------------------
    -- todo component see startingelectronics.org/software/VHDL-CPLD-course/tut4-multiplexers/
    rgb_reg <= rgb_reg_0 when (SEL = "00") else
               rgb_reg_1 when (SEL = "01") else
               rgb_reg_2 when (SEL = "10") else
               (others                                                      => '1');

    vgaRed   <= (rgb_reg(11 downto 8)) when video_on = '1' else (others => '0');
    vgaGreen <= (rgb_reg(7 downto 4)) when video_on = '1' else (others  => '0');
    vgaBlue  <= (rgb_reg(3 downto 0)) when video_on = '1' else (others  => '0');

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
    -- Instantiate image generator 2 to rgb buffer
    --------------------------------------------------
    image_gen_1 : entity work.hw_image_generator
        port map(
            disp_ena => video_on,
            row      => pixel_x,
            column   => pixel_y,
            red      => rgb_reg_1(11 downto 8),
            green    => rgb_reg_1(7 downto 4),
            blue     => rgb_reg_1(3 downto 0));

    --------------------------------------------------
    -- Instantiate image generator 3 to rgb buffer
    --------------------------------------------------
    image_gen_2 : entity work.sync_VGA_visualTest2
        port map(
            disp_ena => video_on,
            pix_x    => pixel_x,
            pix_y    => pixel_y,
            --            clock_50 => clk,
            --            reset    => '0', -- tmp not used
            VGA_R    => rgb_reg_2(11 downto 8),
            VGA_G    => rgb_reg_2(7 downto 4),
            VGA_B    => rgb_reg_2(3 downto 0));

end Behavioral;
