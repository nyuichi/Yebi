library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

entity Top_IO is
  port (
    MCLK1 : in std_logic;
    RS_TX : out std_logic;
    RS_RX : in std_logic);
end Top_IO;

architecture Behavioral of Top_IO is

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

  myIO : IO port map (
    clk => clk,
    tx_pin => RS_TX,
    rx_pin => RS_RX,
    tx_en => tx_en,
    tx_data => tx_data,
    rx_en => rx_en,
    rx_data => rx_data);

  process(clk)
  begin
    if rising_edge(clk) then
      if rx_data /= x"FFFFFFFF" and rx_en = '0' then
        tx_data <= rx_data;
        tx_en <= '1';
        rx_en <= '1';
      else
        tx_en <= '0';
        rx_en <= '0';
      end if;
    end if;
  end process;

end Behavioral;
