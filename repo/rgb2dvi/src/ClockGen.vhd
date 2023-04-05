-------------------------------------------------------------------------------
--
-- File: ClockGen.vhd
-- Author: Elod Gyorgy
-- Original Project: HDMI input on 7-series Xilinx FPGA
-- Date: 8 October 2014
--
-------------------------------------------------------------------------------
-- (c) 2014 Copyright Digilent Incorporated
-- All Rights Reserved
-- 
-- This program is free software; distributed under the terms of BSD 3-clause 
-- license ("Revised BSD License", "New BSD License", or "Modified BSD License")
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
-- 3. Neither the name(s) of the above-listed copyright holder(s) nor the names
--    of its contributors may be used to endorse or promote products derived
--    from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------
--
-- Purpose:
-- This module generate the serial clock, which is 5 times of the pixel clock.
--  
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ClockGen is
   Generic (
      kClkRange : natural := 1;  -- MULT_F = kClkRange*5 (choose >=120MHz=1, >=60MHz=2, >=40MHz=3, >=30MHz=4, >=25MHz=5
      kClkPrimitive : string := "MMCM"); -- "MMCM" or "PLL" to instantiate, if kGenerateSerialClk true
   Port (
      PixelClkIn : in STD_LOGIC;
      PixelClkOut : out STD_LOGIC;
      SerialClk : out STD_LOGIC;
      aRst : in STD_LOGIC;
      aLocked : out STD_LOGIC);
end ClockGen;

architecture Behavioral of ClockGen is
signal PixelClkInX1, PixelClkInX5, FeedbackClk : std_logic;
signal aLocked_int, pLocked, pRst, pLockWasLost : std_logic;
signal pLocked_q : std_logic_vector(2 downto 0) := (others => '1');
begin

-- We need a reset bridge to use the asynchronous aRst signal to reset our circuitry
-- and decrease the chance of metastability. The signal pRst can be used as
-- asynchronous reset for any flip-flop in the PixelClkIn domain, since it will be de-asserted
-- synchronously.
LockLostReset: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => aRst,
      OutClk => PixelClkIn,
      oRst => pRst);

PLL_LockSyncAsync: entity work.SyncAsync
   port map (
      aReset => '0',
      aIn => aLocked_int,
      OutClk => PixelClkIn,
      oOut => pLocked);
      
PLL_LockLostDetect: process(PixelClkIn)
begin
   if (pRst = '1') then
      pLocked_q <= (others => '1');
      pLockWasLost <= '1'; 
   elsif Rising_Edge(PixelClkIn) then
      pLocked_q <= pLocked_q(pLocked_q'high-1 downto 0) & pLocked;
      pLockWasLost <= (not pLocked_q(0) or not pLocked_q(1)) and pLocked_q(2); --two-pulse 
   end if;
end process;

-- The TMDS Clk channel carries a character-rate frequency reference
-- In a single Clk period a whole character (10 bits) is transmitted
-- on each data channel. For deserialization of data channel a faster,
-- serial clock needs to be generated. In 7-series architecture an
-- OSERDESE2 primitive doing a 10:1 deserialization in DDR mode needs
-- a fast 5x clock and a slow 1x clock. These two clocks are generated
-- below with an MMCME2_ADV/PLLE2_ADV.
-- Caveats:
-- 1. The primitive uses a multiply-by-5 and divide-by-1 to generate
-- a 5x fast clock.
-- While changes in the frequency of the TMDS Clk are tracked by the
-- MMCM, for some TMDS Clk frequencies the datasheet specs for the VCO
-- frequency limits are not met. In other words, there is no single
-- set of MMCM multiply and divide values that can work for the whole
-- range of resolutions and pixel clock frequencies.
-- For example: MMCM_FVCOMIN = 600 MHz
-- MMCM_FVCOMAX = 1200 MHz for Artix-7 -1 speed grade
-- while FVCO = FIN * MULT_F
-- The TMDS Clk for 720p resolution in 74.25 MHz
-- FVCO = 74.25 * 10 = 742.5 MHz, which is between FVCOMIN and FVCOMAX
-- However, the TMDS Clk for 1080p resolution in 148.5 MHz
-- FVCO = 148.5 * 10 = 1480 MHZ, which is above FVCOMAX
-- In the latter case, MULT_F = 5, DIVIDE_F = 5, DIVIDE = 1 would result
-- in a correct VCO frequency, while still generating 5x and 1x clocks
-- 2. The MMCM+BUFIO+BUFR combination results in the highest possible
-- frequencies. PLLE2_ADV could work only with BUFGs, which limits
-- the maximum achievable frequency. The reason is that only the MMCM
-- has dedicated route to BUFIO.
-- If a PLLE2_ADV with BUFGs are used a second CLKOUTx can be used to
-- generate the 1x clock.
GenMMCM: if kClkPrimitive = "MMCM" generate
DVI_ClkGenerator: MMCME2_ADV
   generic map
      (BANDWIDTH            => "OPTIMIZED",
      CLKOUT4_CASCADE      => FALSE,
      COMPENSATION         => "ZHOLD",
      STARTUP_WAIT         => FALSE,
      DIVCLK_DIVIDE        => 1,
      CLKFBOUT_MULT_F      => real(kClkRange) * 5.0,
      CLKFBOUT_PHASE       => 0.000,
      CLKFBOUT_USE_FINE_PS => FALSE,
      CLKOUT0_DIVIDE_F     => real(kClkRange) * 1.0,
      CLKOUT0_PHASE        => 0.000,
      CLKOUT0_DUTY_CYCLE   => 0.500,
      CLKOUT0_USE_FINE_PS  => FALSE,
      CLKOUT1_DIVIDE       => kClkRange * 5,
      CLKOUT1_DUTY_CYCLE   => 0.5,
      CLKOUT1_PHASE        => 0.0,
      CLKOUT1_USE_FINE_PS  => FALSE,
      CLKIN1_PERIOD        => real(kClkRange) * 6.0,
      REF_JITTER1          => 0.010)
   port map
   -- Output clocks
   (
      CLKFBOUT            => FeedbackClk,
      CLKFBOUTB           => open,
      CLKOUT0             => PixelClkInX5,
      CLKOUT0B            => open,
      CLKOUT1             => PixelClkInX1,
      CLKOUT1B            => open,
      CLKOUT2             => open,
      CLKOUT2B            => open,
      CLKOUT3             => open,
      CLKOUT3B            => open,
      CLKOUT4             => open,
      CLKOUT5             => open,
      CLKOUT6             => open,
      -- Input clock control
      CLKFBIN             => FeedbackClk,
      CLKIN1              => PixelClkIn,
      CLKIN2              => '0',
      -- Tied to always select the primary input clock
      CLKINSEL            => '1',
      -- Ports for dynamic reconfiguration
      DADDR               => (others => '0'),
      DCLK                => '0',
      DEN                 => '0',
      DI                  => (others => '0'),
      DO                  => open,
      DRDY                => open,
      DWE                 => '0',
      -- Ports for dynamic phase shift
      PSCLK               => '0',
      PSEN                => '0',
      PSINCDEC            => '0',
      PSDONE              => open,
      -- Other control and status signals
      LOCKED              => aLocked_int,
      CLKINSTOPPED        => open,
      CLKFBSTOPPED        => open,
      PWRDWN              => '0',
      RST                 => pLockWasLost);
end generate;

GenPLL: if kClkPrimitive /= "MMCM" generate
DVI_ClkGenerator: PLLE2_ADV
   generic map (
      BANDWIDTH            => "OPTIMIZED",
      CLKFBOUT_MULT        => (kClkRange + 1) * 5,
      CLKFBOUT_PHASE       => 0.000,
      CLKIN1_PERIOD        => real(kClkRange) * 6.25,
      COMPENSATION         => "ZHOLD",
      DIVCLK_DIVIDE        => 1,
      REF_JITTER1          => 0.010,
      STARTUP_WAIT         => "FALSE",
      CLKOUT0_DIVIDE       => (kClkRange + 1) * 1,
      CLKOUT0_PHASE        => 0.000,
      CLKOUT0_DUTY_CYCLE   => 0.500,
      CLKOUT1_DIVIDE       => (kClkRange + 1) * 5,
      CLKOUT1_DUTY_CYCLE   => 0.5,
      CLKOUT1_PHASE        => 0.0)
   port map
   -- Output clocks
   (
      CLKFBOUT            => FeedbackClk,
      CLKOUT0             => PixelClkInX5,
      CLKOUT1             => PixelClkInX1,
      CLKOUT2             => open,
      CLKOUT3             => open,
      CLKOUT4             => open,
      CLKOUT5             => open,
      -- Input clock control
      CLKFBIN             => FeedbackClk,
      CLKIN1              => PixelClkIn,
      CLKIN2              => '0',
      -- Tied to always select the primary input clock
      CLKINSEL            => '1',
      -- Ports for dynamic reconfiguration
      DADDR               => (others => '0'),
      DCLK                => '0',
      DEN                 => '0',
      DI                  => (others => '0'),
      DO                  => open,
      DRDY                => open,
      DWE                 => '0',
      -- Other control and status signals
      LOCKED              => aLocked_int,
      PWRDWN              => '0',
      RST                 => pLockWasLost);
      
end generate;

--No buffering used
--These clocks will only drive the OSERDESE2 primitives
SerialClk <= PixelClkInX5;
PixelClkOut <= PixelClkInX1;
aLocked <= aLocked_int;

end Behavioral;
