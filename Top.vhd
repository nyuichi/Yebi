library IEEE;
use IEEE.std_logic_1164.all;

library UNISIM;
use UNISIM.VComponents.all;

use work.Util.all;

entity Top is
  port (
    MCLK1 : in std_logic;
    RS_TX : out std_logic;
    RS_RX : in std_logic;
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
end Top;

architecture Behavioral of Top is

  component CPU is
    port (
      clk : in std_logic;
      ram_addr : out std_logic_vector(19 downto 0);
      ram_rx_en : out std_logic;
      ram_rx_data : in std_logic_vector(31 downto 0);
      ram_tx_en : out std_logic;
      ram_tx_data : out std_logic_vector(31 downto 0);
      io_tx_en : out std_logic;
      io_tx_data : out std_logic_vector(31 downto 0);
      io_rx_en : out std_logic;
      io_rx_data : in std_logic_vector(31 downto 0));
  end component;

  component RAM is
    port (
      clk : in std_logic;
      addr : in std_logic_vector(19 downto 0);
      rx : out std_logic_vector(31 downto 0);
      rx_en : in std_logic;
      tx : in std_logic_vector(31 downto 0);
      tx_en : in std_logic;
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

  component IO is
    port (
      clk : in std_logic;
      tx_pin : out std_logic;
      rx_pin : in std_logic;
      tx_en : in std_logic;
      tx_data : in std_logic_vector(31 downto 0);
      rx_en : in std_logic;
      rx_data : out std_logic_vector(31 downto 0));
  end component;

  signal iclk, clk : std_logic := '0';

  signal ram_addr : std_logic_vector(19 downto 0) := (others => '0');
  signal ram_rx_en : std_logic := '0';
  signal ram_rx_data :std_logic_vector(31 downto 0) := (others => '0');
  signal ram_tx_en : std_logic := '0';
  signal ram_tx_data : std_logic_vector(31 downto 0) := (others => '0');

  signal tx_en : std_logic;
  signal tx_data : std_logic_vector(31 downto 0);
  signal rx_en : std_logic;
  signal rx_data : std_logic_vector(31 downto 0);

begin

  ib: IBUFG port map (
    i => MCLK1,
    o => iclk);

  bg: BUFG port map (
    i => iclk,
    o => clk);

  myCPU : CPU port map (
    clk => clk,
    ram_addr => ram_addr,
    ram_rx_en => ram_rx_en,
    ram_rx_data => ram_rx_data,
    ram_tx_en => ram_tx_en,
    ram_tx_data => ram_tx_data,
    io_tx_en => tx_en,
    io_tx_data => tx_data,
    io_rx_en => rx_en,
    io_rx_data => rx_data);

  myRAM : RAM port map (
    clk => clk,
    addr => ram_addr,
    rx => ram_rx_data,
    rx_en => ram_rx_en,
    tx => ram_tx_data,
    tx_en => ram_tx_en,
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

  myIO : IO port map (
    clk => clk,
    tx_pin => RS_TX,
    rx_pin => RS_RX,
    tx_en => tx_en,
    tx_data => tx_data,
    rx_en => rx_en,
    rx_data => rx_data);

end Behavioral;
