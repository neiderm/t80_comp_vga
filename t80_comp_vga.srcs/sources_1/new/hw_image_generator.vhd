-- Original source:
--   https://forum.digikey.com/uploads/short-url/qQ6EHbTWSZa5jbn0GF21Ku6Gw5X.vhd
--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hw_image_generator IS
--  GENERIC(
--    pixels_y :  INTEGER := 160;   --row that first color will persist until
--    pixels_x :  INTEGER := 160);  --column that first color will persist until
  PORT(
    clk_in   :  IN   STD_LOGIC;
    disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    row      :  IN   INTEGER;    --row pixel coordinate
    column   :  IN   INTEGER;    --column pixel coordinate
-- GN: change from 24-bit RGB to 12-bit RGB for Basys-3
    red      :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

    signal rgb_reg  : std_logic_vector(11 downto 0);

BEGIN
    image_gen_3 : entity work.roms_signal
        port map(
            clk    => clk_in,
            en     => disp_ena,
            pix_y  => row,
            pix_x  => column,
            data   => rgb_reg);

  PROCESS(disp_ena, row, column, rgb_reg)
  BEGIN
    IF(disp_ena = '1') THEN        --display time

      red <= rgb_reg(11 downto 8);
      green <= rgb_reg(7 downto 4);
      blue <= rgb_reg(3 downto 0);

----      IF(row < pixels_y AND column < pixels_x) THEN
--      IF(row < 16 AND column < 640) THEN  -- tmp test
--        red <= rgb_reg(11 downto 8);
--        green <= rgb_reg(7 downto 4);
--        blue <= rgb_reg(3 downto 0);
--      ELSE
--        red <= (OTHERS => '1');
--        green  <= (OTHERS => '1');
--        blue <= (OTHERS => '1');
--      END IF;
    ELSE                           --blanking time
      red <= (OTHERS => '0');
      green <= (OTHERS => '0');
      blue <= (OTHERS => '0');
    END IF;  
  END PROCESS;

END behavior;
