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

  signal clk_gen : std_logic := '0';
  signal rs_tx, rs_rx : std_logic;

begin

  myTop : Top port map (
    MCLK1 => clk_gen,
    RS_TX => RS_TX,
    RS_RX => RS_RX);

  -- clock generator
  process
  begin
    clk_gen <= '0';
    wait for 5 ns;
    clk_gen <= '1';
    wait for 5 ns;
  end process;

end Behavioral;
