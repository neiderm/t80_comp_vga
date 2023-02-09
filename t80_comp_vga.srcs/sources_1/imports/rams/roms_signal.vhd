--
-- Description of a ROM with a VHDL signal
--
-- Download: ftp://ftp.xilinx.com/pub/documentation/misc/xstug_examples.zip
-- File: HDL_Coding_Techniques/rams/roms_signal.vhd
--
-- Reference for bitmap loading: https://vhdlwhiz.com/read-bmp-file/

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
-- numeric-std is used to replace the proprietary std-logic-unsigned package.
use IEEE.numeric_std.all;

use std.textio.all;
--
-- reset_n is introduced because the address is generated from pix x/y which are signals
-- from the VGA controller block which has a reset
-- RAMB36E1 bmp_img_gen/data_reg_0 has an input control pin bmp_img_gen/data_reg_0/RSTRAMARSTRAM (net: bmp_img_gen/data_reg_0_i_1_n_0) which is driven by a register (u_vga_control/column_reg[2]) that has an active asychronous set or reset. 
--
entity roms_signal is
    port (
        clk : in std_logic;
        en  : in std_logic;
        -- addr : in std_logic_vector(6 downto 0); -- todo pixel clock
        reset_n : in std_logic;
        pix_y  : in integer; --row pixel coordinate
        pix_x  : in integer; --column pixel coordinate
        data   : out std_logic_vector(11 downto 0)
    );
end roms_signal;

architecture syn of roms_signal is

    type header_type is array (0 to 53) of std_logic_vector (7 downto 0);

    type bmp_info_type is record
        width : integer;
        height : integer;
    end record;

    impure function ReadHeaderFromFile (RamFileName : in string) return bmp_info_type is
        file bmp_file : text;
        variable RamFileLine : line;
        variable bmp_dims : bmp_info_type;
        variable header : header_type;
        variable read_index : integer := 0;
    begin
        file_open(bmp_file, RamFileName, read_mode);
        -- read BMP header from file
        for i in header_type'range loop
            -- read(bmp_file, header(i));
            readline (bmp_file, RamFileLine);
            hread (RamFileLine, header(i)); -- requires VHDL 2AA8
        end loop;
        -- extract image dimensions
        bmp_dims.width := to_integer(unsigned(header(18))) + 
                          to_integer(unsigned(header(19))) * 2 ** 8 + 
                          to_integer(unsigned(header(20))) * 2 ** 16 + 
                          to_integer(unsigned(header(21))) * 2 ** 24;
        bmp_dims.height := to_integer(unsigned(header(22))) + 
                           to_integer(unsigned(header(23))) * 2 ** 8 + 
                           to_integer(unsigned(header(24))) * 2 ** 16 + 
                           to_integer(unsigned(header(25))) * 2 ** 24;
        file_close(bmp_file);
        return bmp_dims;
    end function;

    constant bmp_hdr : bmp_info_type := ReadHeaderFromFile("rgb.bmp.dat");
    constant bmp_img_sz : integer := bmp_hdr.height * bmp_hdr.width * 3 + 1; -- tmp 1 byte EOF
    subtype byte_type is std_logic_vector(8-1 downto 0);
    type bmp_img_dat_type is array (0 to bmp_img_sz - 1) of byte_type;

    -- use 12-bit RGB outpu, which is specific to the FPGA board output for now
    type rgb_data_type is array (0 to (bmp_img_sz - 1)) of std_logic_vector (11 downto 0);

    type bmp_type is record
        dimensions : bmp_info_type;
        pixel_data : rgb_data_type;
    end record;

    impure function InitRamFromFile (RamFileName : in string) return bmp_type is
        file bmp_file : text;
        variable RamFileLine : line;    
        variable bmp_data : bmp_type;
        variable header : header_type;
        variable pix_data_buf : bmp_img_dat_type; -- temp byte buffer to read in bmp inage data
        variable read_index : integer := 0;
    begin
        file_open(bmp_file, RamFileName, read_mode);
        -- read BMP header from file (only needed to skip over header to image data)
        for i in header_type'range loop
            -- read(bmp_file, header(i));
            readline (bmp_file, RamFileLine);
--            hread (RamFileLine, header(i)); -- requires VHDL 2AA8
        end loop;

        bmp_data.dimensions.width := bmp_hdr.width;
        bmp_data.dimensions.height := bmp_hdr.height;

        -- read RGB image data from file
        read_index := 0;
        while(not ENDFILE(bmp_file)) loop --until end of file is reached (todo ... 1 extra line)
            readline (bmp_file, RamFileLine);
            hread (RamFileLine, pix_data_buf(read_index)); -- read into tmp rgb byte buffer
            read_index := read_index + 1;
        end loop;
        file_close(bmp_file);

        -- loop 8-bit data to array of 12-bit vector. 
        read_index := 0;
        while ( read_index < (bmp_data.dimensions.width * bmp_data.dimensions.height)) loop
            assert (read_index < rgb_data_type'length);
            bmp_data.pixel_data(read_index)(11 downto 8) := pix_data_buf(read_index * 3 + 2)(7 downto 4);
            bmp_data.pixel_data(read_index)(7 downto 4) := pix_data_buf(read_index * 3 + 1)(7 downto 4);
            bmp_data.pixel_data(read_index)(3 downto 0) := pix_data_buf(read_index * 3 + 0)(7 downto 4);
            read_index := read_index + 1;
        end loop;

        return bmp_data;
    end function;

    --declare and initialize the image ram.
    constant bmp_dat : bmp_type := InitRamFromFile("rgb.bmp.dat");
    constant bmp_w : integer := bmp_dat.dimensions.width;
    constant bmp_h : integer := bmp_dat.dimensions.height;
    signal addr : integer;

begin -- architecture
    -- todo multiplation infers a DSP block, need to use a pixel clock instead
    addr <= pix_y * bmp_w + pix_x;

    process (clk, reset_n)
    begin
        if (reset_n = '0') then
            data <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (en = '1') then
                IF(pix_y < bmp_h AND pix_x < bmp_w) THEN
                  data <= bmp_dat.pixel_data(addr);
                ELSE
                  data <= (others => '0');
                END IF;
            end if;
        end if;
    end process;
end syn;
