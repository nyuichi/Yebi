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
  signal Tx_GO : std_logic := '0';
  signal Rx_BUSY : std_logic;
  signal Tx_BUSY : std_logic;

  component RS232C is
    port (
      clk : in std_logic;
      tx_pin : out std_logic;
      rx_pin : in std_logic;
      tx_go : in std_logic;
      tx_busy : out std_logic;
      tx_data : in std_logic_vector(7 downto 0);
      rx_busy : out std_logic;
      rx_data : out std_logic_vector(7 downto 0));
  end component;

  signal prev_busy : std_logic := '0';
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
    tx_data => DIN,
    rx_data => DOUT,
    tx_go => Tx_GO,
    Rx_BUSY => Rx_BUSY,
    Tx_BUSY => Tx_BUSY);

  process(clk)
  begin
    if rising_edge(clk) then
      -- read
      if prev_busy /= Rx_BUSY then
        if Rx_BUSY = '0' then
          if 97 <= conv_integer(DOUT) and conv_integer(DOUT) <= 122 then
            DIN <= DOUT - x"20";
          else
            DIN <= DOUT;
          end if;
          data_ready <= '1';
        end if;
        prev_busy <= Rx_BUSY;
      end if;
      -- write
      if Tx_BUSY = '0' and Tx_GO = '0' and data_ready = '1'then
        Tx_GO <= '1';
        data_ready <= '0';
      else
        Tx_GO <= '0';
      end if;
    end if;
  end process;

end Behavioral;
