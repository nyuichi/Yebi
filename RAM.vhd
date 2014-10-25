library IEEE;
use IEEE.std_logic_1164.all;

entity RAM is
  port (
    clk : in std_logic;
    addr : in std_logic_vector(19 downto 0);
    rx : out std_logic_vector(31 downto 0);
    rx_en : in std_logic;
    tx : in std_logic_vector(31 downto 0);
    tx_en : in std_logic;

    -- Hardware Pins
    ZD : inout std_logic_vector(31 downto 0);
    ZDP : inout std_logic_vector(3 downto 0);
    ZA : out std_logic_vector(19 downto 0);
    XE1 : out std_logic;
    E2A : out std_logic;
    XE3 : out std_logic;
    XZBE : out std_logic_vector(3 downto 0);
    XGA : out std_logic;
    XWA : out std_logic;
    XZCKE : out std_logic;
    ZCLKMA : out std_logic_vector(1 downto 0);
    ADVA : out std_logic;
    XFT : out std_logic;
    XLBO : out std_logic;
    ZZA : out std_logic);
end RAM;

architecture Behavioral of RAM is

  component SRAM is
    port (
      clk : in std_logic;
      addr : in std_logic_vector(19 downto 0);
      rx : out std_logic_vector(31 downto 0);
      tx : in std_logic_vector(31 downto 0);
      tx_en : in std_logic;

      -- Hardware Pins
      ZD : inout std_logic_vector(31 downto 0);
      ZDP : inout std_logic_vector(3 downto 0);
      ZA : out std_logic_vector(19 downto 0);
      XE1 : out std_logic;
      E2A : out std_logic;
      XE3 : out std_logic;
      XZBE : out std_logic_vector(3 downto 0);
      XGA : out std_logic;
      XWA : out std_logic;
      XZCKE : out std_logic;
      ZCLKMA : out std_logic_vector(1 downto 0);
      ADVA : out std_logic;
      XFT : out std_logic;
      XLBO : out std_logic;
      ZZA : out std_logic);
  end component;

  component BlockRAM is
    port (
      clk : in std_logic;
      addr : in std_logic_vector(13 downto 0);
      rx : out std_logic_vector(31 downto 0);
      tx : in std_logic_vector(31 downto 0);
      tx_en : in std_logic);
  end component;

  signal sram_rx, bram_rx : std_logic_vector(31 downto 0);
  signal sram_tx_en, bram_tx_en, bram_rx_en : std_logic;

begin

  mySRAM : SRAM port map (
    clk => clk,
    addr => addr,
    rx => sram_rx,
    tx => tx,
    tx_en => sram_tx_en,
    ZD => ZD,
    ZDP => ZDP,
    ZA => ZA,
    XE1 => XE1,
    E2A => E2A,
    XE3 => XE3,
    XZBE => XZBE,
    XGA => XGA,
    XWA => XWA,
    XZCKE => XZCKE,
    ZCLKMA => ZCLKMA,
    ADVA => ADVA,
    XFT => XFT,
    XLBO => XLBO,
    ZZA => ZZA);

  myBlockRAM : BlockRAM port map (
    clk => clk,
    addr => addr(13 downto 0),
    rx => bram_rx,
    tx => tx,
    tx_en => bram_tx_en);

  rx <= sram_rx when addr >= x"04000" else bram_rx;

  sram_tx_en <= '1' when addr >= x"04000" and tx_en = '1' else '0';
  bram_tx_en <= '1' when addr < x"04000" and tx_en = '1' else '0';

end Behavioral;
