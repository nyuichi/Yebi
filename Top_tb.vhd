library IEEE;
use IEEE.std_logic_1164.all;

entity Top_tb is
end Top_tb;

architecture Behavioral of Top_tb is

  component Top is
    port (
      MCLK1 : in std_logic;
      RS_TX : out std_logic;
      RS_RX : in std_logic);
  end component;

  signal CLK : std_logic := '0';
  signal rs_tx, rs_rx : std_logic;

  -- global clock period
  constant CP: time := 15.15 ns;
  -- bit rate (1 / 9600bps)
  constant BR: time := 104166 ns;

begin

  myTop : Top port map (
    MCLK1 => CLK,
    RS_TX => RS_TX,
    RS_RX => RS_RX);

  -- clock generator
  process
  begin
    CLK <= '0';
    wait for CP / 2;
    CLK <= '1';
    wait for CP / 2;
  end process;

  process
  begin

    RS_RX <= '1';

    wait for (16 * BR);

    wait for BR; RS_RX <= '0'; -- start-bit
    wait for BR; RS_RX <= '1'; -- data-bit 8'hc5
    wait for BR; RS_RX <= '0';
    wait for BR; RS_RX <= '1';
    wait for BR; RS_RX <= '0';
    wait for BR; RS_RX <= '0';
    wait for BR; RS_RX <= '0';
    wait for BR; RS_RX <= '1';
    wait for BR; RS_RX <= '1';
    wait for BR; RS_RX <= '1'; -- stop-bit

    wait for (2 * BR);

    wait for BR; RS_RX <= '0'; -- start-bit
    wait for BR; RS_RX <= '0'; -- data-bit 8'hf0
    wait for BR; RS_RX <= '0';
    wait for BR; RS_RX <= '0';
    wait for BR; RS_RX <= '0';
    wait for BR; RS_RX <= '1';
    wait for BR; RS_RX <= '1';
    wait for BR; RS_RX <= '1';
    wait for BR; RS_RX <= '1';
    wait for BR; RS_RX <= '1'; -- stop-bit

    wait for (16 * BR);

    assert false report "Simulation End." severity failure;
  end process;

end Behavioral;
