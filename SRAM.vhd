library IEEE;
use IEEE.std_logic_1164.all;

entity SRAM is
  port (
    CLK : in std_logic;
    ADDR : in std_logic_vector(19 downto 0);
    RX : out std_logic_vector(31 downto 0);
    RX_EN : in std_logic;
    TX : in std_logic_vector(31 downto 0);
    TX_EN : in std_logic;

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
begin

  process(CLK)
  begin
    if rising_edge(CLK) then
      if TX_EN = '1' then
        XWA <= '0';
      else
        XWA <= '1';
      end if;

      if RX_EN = '1' then
        ZD <= (others => 'Z');
      elsif TX_EN = '1' then
        ZD <= TX;
      end if;

      RX <= ZD;
    end if;
  end process;

-- ignore ZDP
  ZA <= ADDR;
  XE1 <= '0';
  E2A <= '1';
  XE3 <= '0';
  XZBE <= "0000";
  XGA <= '0';
  XZCKE <= '0';
  ADVA <= '0';
  XFT <= '1';
  XLBO <= '1';
  ZZA <= '0';

end Behavioral;
