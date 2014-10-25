library IEEE;
use IEEE.std_logic_1164.all;

entity SRAM is
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
end SRAM;

architecture Behavioral of SRAM is

  signal prev_tx : std_logic_vector(31 downto 0) := (others => '0');
  signal prev_tx_en : std_logic := '0';

begin

  process(clk)
  begin
    if rising_edge(clk) then
      prev_tx <= tx;
      prev_tx_en <= tx_en;
    end if;
  end process;

  rx <= ZD;

  ZA <= addr;
  ZD <= prev_tx when prev_tx_en = '1' else (others => 'Z');
  ZDP <= "0000" when prev_tx_en = '1' else (others => 'Z');
  XE1 <= '0';
  E2A <= '1';
  XE3 <= '0';
  XWA <= not tx_en;
  XZBE <= "0000";
  XGA <= '0';
  XZCKE <= '0';
  ZCLKMA(0) <= clk;
  ZCLKMA(1) <= clk;
  ADVA <= '0';
  XFT <= '0';
  XLBO <= '1';
  ZZA <= '0';

end Behavioral;
