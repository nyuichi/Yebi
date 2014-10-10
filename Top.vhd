library IEEE;
use IEEE.std_logic_1164.all;

library UNISIM;
use UNISIM.VComponents.all;

entity Top is
  port (
    MCLK1 : in std_logic;
    RS_TX : in std_logic);
end Top;

architecture Behavioral of Top is

  component CPU is
    port (
      clk : in std_logic;
      ram : in ram_t);
  end component;

  component RS232C is
    port (
      clk : in std_logic;
      tx_pin : out std_logic;
      go : in std_logic;
      busy : out std_logic;
      data : in std_logic_vector(7 downto 0));
  end component;

  signal iclk, clk : std_logic := '0';

  signal myram : ram_t := (
    x"00000000",
    x"01000001",
    x"02100000",
    x"03210000",
    x"0430000A",
    x"11420000",
    x"22300003",
    x"31300000",
    --x"00000000",
    --x"00000000",
    --x"00000000",
    --x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000"
    );

begin

  ib: IBUFG port map (
    i => MCLK1,
    o => iclk);

  bg: BUFG port map (
    i => iclk,
    o => clk);

  myCPU : CPU port map (
    clk => clk,
    ram =>);

  myRS232C : RS232C port map (
    clk => clk,
    tx_pin => RS_TX,
    go => tx_go,
    busy => tx_busy,
    data => tx_data);

end Behavioral;
