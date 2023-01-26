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
--  mostly original by Glenn Neidermeier
--   primary references are pacman vhdl project and particularly 
--   http://searle.x10host.com/Multicomp/index.html#BusIsolation
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

    signal reset_l          : std_logic;
    signal clk25            : std_logic;
    signal clk_div16        : std_logic;

    -- video
    signal rgb_reg_0        : std_logic_vector(11 downto 0);
    signal rgb_reg_1        : std_logic_vector(11 downto 0);
    signal rgb_reg_2        : std_logic_vector(11 downto 0);
    signal rgb_reg_3        : std_logic_vector(11 downto 0);

    signal rgb_reg          : std_logic_vector(11 downto 0);

    signal video_on         : std_logic;
    signal pixel_x, pixel_y : integer;

    -- cpu
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

    signal program_rom_din  : std_logic_vector(7 downto 0);
    signal program_rom_cs_l : std_logic;

    signal gpout_cs_l       : std_logic;

    signal rams_data_out    : std_logic_vector(7 downto 0);
    signal work_ram_cs_l    : std_logic;

    signal mem_wr_l         : std_logic;
    signal io_wr_l          : std_logic;
    signal io_rd_l          : std_logic;

    signal outp_reg         : std_logic_vector(7 downto 0);
    signal wsel             : std_logic_vector(1 downto 0);
    signal irq_req_out      : std_logic;

begin
    -- drive IO
    JA1     <= clk25;
    JA2     <= clk_div16;

    reset_l <= not i_reset;

    --------------------------------------------------
    -- clocks
    --------------------------------------------------
    u_clocks : entity work.clock_div_pow2
        port map(
            i_clk       => clk,
            i_rst       => reset_l,

            o_clk_div2  => open,
            o_clk_div4  => clk25,
            o_clk_div8  => open,
            o_clk_div16 => clk_div16
        );

    --------------------------------------------------
    -- IRQ
    --------------------------------------------------
    -- /INT is level triggered, must be held until interrupt is acknowledged (/IORQ during M1 time)
    irq_req : entity work.registers_2
        port map(
            C     => Vsync,
            D     => '1', -- sets latch to 1 on falling vsync
            CLR   => not (cpu_iorq_l or cpu_m1_l), -- IORQ == 0 and M1 == 0
            Q     => irq_req_out
        );
        cpu_int_l <= NOT(irq_req_out);

    --------------------------------------------------
    -- Instantiate t80
    --------------------------------------------------
    u_cpu : entity work.T80s
        port map(
            RESET_n => reset_l,
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
    -- primary addr decode (chip selects)
    --------------------------------------------------
    program_rom_cs_l <= '0' when cpu_addr(15) = '0' else '1'; -- ROM at $0000, RAM at $8000

    work_ram_cs_l    <= '0' when cpu_addr(15 downto 11) = "10000" else '1'; -- Work RAM at $8000 (1k or 2k)
--    gfx_ram_cs_l   <= '0' cpu_addr(15 downto 11) = "10001" else '1'; -- GFX RAM at $8800 (2k i.e. 

    gpout_cs_l       <= '0' when cpu_addr(7 downto 1)   = "1000000" and (io_wr_l = '0' or io_rd_l = '0') else '1'; -- 2 Bytes $80-$81
    --gp1_cs_l       <= '0' when cpuAddress(7 downto 1) = "1000001" and (io_wr_l = '0' or io_rd_l = '0') else '1'; -- 2 Bytes $82-$83

    -- mem r/w logic
    --mem_rd_l         <= cpu_rd_l or cpu_mreq_l;  -- RD==0 and MREQ==0
    io_rd_l          <= cpu_rd_l or cpu_iorq_l;  -- RD==0 and IOREQ==0
    mem_wr_l         <= cpu_wr_l or cpu_mreq_l;  -- WR==0 and MREQ==0
    io_wr_l          <= cpu_wr_l or cpu_iorq_l;  -- WR==0 and IOREQ==0

    -------------------
    -- cpu data in mux (bus isolation)
    cpu_data_in      <=
        program_rom_din when program_rom_cs_l = '0' else
        rams_data_out   when work_ram_cs_l    = '0' else
        x"FF"; -- should never be read by CPU?

    --------------------------------------------------
    -- output driver
    --------------------------------------------------
    u_gpout_reg : entity work.registers_4
    port map (
        C  => clk_div16,
        CE => not gpout_cs_l,
        D  => cpu_data_out,
        Q  => outp_reg
    );

    -- wsel          <= sw(15 downto 14);
    wsel             <= outp_reg(7 downto 6);
    led(3 downto 0)  <= outp_reg(7 downto 4);

    --------------------------------------------------
    -- work RAM
    --------------------------------------------------
  u_rams : entity work.rams_08
    port map (
      a    => cpu_addr(9 downto 0),
      di   => cpu_data_out,
      do   => rams_data_out,
      we   => not(mem_wr_l or work_ram_cs_l), -- write enable, active high
      en   => '1',                            -- chip enable, active high
      clk  => clk_div16
      );

    --------------------------------------------------
    -- internal program rom
    --------------------------------------------------
    u_program_rom : entity work.roms_1
        port map(
            clk_i  => clk_div16,
            en     => '1', -- program_rom_cs,
            addr   => cpu_addr(8 downto 0),
            data   => program_rom_din 
        );
 
    --------------------------------------------------
    -- video subsystem
    --------------------------------------------------
    vga_control_unit : entity work.vga_controller
        port map(
            pixel_clk => clk25,
            reset_n   => reset_l,
            h_sync    => Hsync,
            v_sync    => Vsync,
            disp_ena  => video_on, -- out
            column    => pixel_x,
            row       => pixel_y,
            n_blank   => open,
            n_sync    => open
        );

    --------------------------------------------------
    -- select image generator and drive the VGA outputs
    --------------------------------------------------
-- old one
--    rgb_reg <= rgb_reg_0 when (wsel = "00") else
--               rgb_reg_1 when (wsel = "01") else
--               rgb_reg_2 when (wsel = "10") else
--               (others => '1');
-- RTL schem looks better
    video_mux : entity work.multiplexers_2
        port map(
            sel => wsel,
            di0 => rgb_reg_0,
            di1 => rgb_reg_1,
            di2 => rgb_reg_2,
            di3 => "111100001111",
            do => rgb_reg
        );

    vgaRed   <= (rgb_reg(11 downto 8)) when video_on = '1' else (others => '0');
    vgaGreen <= (rgb_reg(7 downto 4)) when video_on = '1' else (others  => '0');
    vgaBlue  <= (rgb_reg(3 downto 0)) when video_on = '1' else (others  => '0');

    --------------------------------------------------
    -- Instantiate image generator
    --------------------------------------------------
    image_gen_0 : entity work.simple_image_gen
        port map(
            clk      => clk,
            reset_n  => reset_l,
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
            VGA_R    => rgb_reg_2(11 downto 8),
            VGA_G    => rgb_reg_2(7 downto 4),
            VGA_B    => rgb_reg_2(3 downto 0));

end Behavioral;
