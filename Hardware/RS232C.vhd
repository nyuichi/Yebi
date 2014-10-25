library IEEE;
use IEEE.std_logic_1164.all;

entity RS232C is
  port (
    clk : in std_logic;
    tx_pin : out std_logic;
    rx_pin : in std_logic;
    tx_go : in std_logic;
    tx_busy : out std_logic;
    tx_data : in std_logic_vector(7 downto 0);
    rx_invalid : in std_logic;
    rx_ready : out std_logic;
    rx_data : out std_logic_vector(7 downto 0));
end RS232C;

architecture Behavioral of RS232C is

  component Tx is
    port (
      clk : in std_logic;
      tx_pin : out std_logic;
      go : in std_logic;
      busy : out std_logic;
      data : in std_logic_vector(7 downto 0));
  end component;

  component Rx is
    port (
      clk : in std_logic;
      rx_pin : in std_logic;
      invalid : in std_logic;
      data : out std_logic_vector(7 downto 0);
      ready : out std_logic);
  end component;

begin

  myTx : Tx port map (
    clk => clk,
    tx_pin => tx_pin,
    go => tx_go,
    busy => tx_busy,
    data => tx_data);

  myRx : Rx port map (
    clk => clk,
    rx_pin => rx_pin,
    invalid => rx_invalid,
    data => rx_data,
    ready => rx_ready);

end Behavioral;
