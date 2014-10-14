library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

entity Loopback is
  port (
    MCLK1 : in std_logic;
    RS_TX : out std_logic;
    RS_RX : in std_logic);
end Loopback;

architecture Behavioral of Loopback is

  signal iclk, clk : std_logic := '0';

  signal DOUT : std_logic_vector(7 downto 0) := (others => '0');
  signal DIN : std_logic_vector(7 downto 0) := (others => '0');
  signal tx_go : std_logic := '0';
  signal tx_busy : std_logic;
  signal rx_invalid : std_logic;
  signal rx_ready : std_logic;

  component RS232C is
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
  end component;

  signal data_ready : std_logic := '0';

begin

  ib: IBUFG port map (
    i => MCLK1,
    o => iclk);

  bg: BUFG port map (
    i => iclk,
    o => clk);

  uart : RS232C port map (
    CLK => CLK,
    rx_pin => RS_RX,
    tx_pin => RS_TX,
    tx_go => tx_go,
    tx_busy => tx_busy,
    tx_data => DIN,
    rx_invalid => rx_invalid,
    rx_ready => rx_ready,
    rx_data => DOUT);

  process(clk)
  begin
    if rising_edge(clk) then
      -- read
      if rx_ready = '1' then
        if 97 <= conv_integer(DOUT) and conv_integer(DOUT) <= 122 then
          DIN <= DOUT - x"20";
        else
          DIN <= DOUT;
        end if;
        data_ready <= '1';
      end if;
      -- write
      if tx_busy = '0' and data_ready = '1'then
        tx_go <= '1';
        rx_invalid <= '1';
        data_ready <= '0';
      else
        tx_go <= '0';
      end if;
    end if;
  end process;

end Behavioral;
