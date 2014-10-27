library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned.all;
use work.Util.all;

entity IO is
  port (
    clk : in std_logic;
    tx_pin : out std_logic;
    rx_pin : in std_logic;
    tx_en : in std_logic;
    tx_data : in std_logic_vector(31 downto 0);
    rx_en : in std_logic;
    rx_data : out std_logic_vector(31 downto 0) := x"FFFFFFFF");
end IO;

architecture Behavioral of IO is

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

  signal tx_go : std_logic := '0';
  signal tx_busy : std_logic := '0';
  signal tx_dat : std_logic_vector(7 downto 0) := (others => '0');
  signal rx_invalid : std_logic := '0';
  signal rx_ready : std_logic := '0';
  signal rx_dat : std_logic_vector(7 downto 0) := (others => '0');

  type buf_t is
    array(0 to 2047) of std_logic_vector(7 downto 0);

  signal tx_buf : buf_t := (others => (others => '0'));
  signal tx_ptr : std_logic_vector(10 downto 0) := (others => '0');
  signal tx_len : integer range 0 to 2048 := 0;

  signal rx_buf : buf_t := (others => (others => '0'));
  signal rx_ptr : std_logic_vector(10 downto 0) := (others => '0');
  signal rx_len : integer range 0 to 2048 := 0;

begin

  myRS232C : RS232C port map (
    clk => clk,
    tx_pin => tx_pin,
    rx_pin => rx_pin,
    tx_go => tx_go,
    tx_busy => tx_busy,
    tx_data => tx_dat,
    rx_invalid => rx_invalid,
    rx_ready => rx_ready,
    rx_data => rx_dat);

  -- WRITE

  process(clk)
  begin
    if rising_edge(clk) then
      if tx_en = '1' and tx_len < 2048 then
        tx_buf(conv_integer(tx_ptr + tx_len)) <= tx_data(7 downto 0);
        tx_len <= tx_len + 1;
      else
        if tx_busy = '0' and tx_go = '0' and tx_len > 0 then
          tx_dat <= tx_buf(conv_integer(tx_ptr));
          tx_ptr <= tx_ptr + 1;
          tx_len <= tx_len - 1;
          tx_go <= '1';
        else
          tx_go <= '0';
        end if;
      end if;
    end if;
  end process;

  -- READ

  process(clk)
  begin
    if rising_edge(clk) then
      if rx_en = '1' and rx_len > 0 then
        if rx_len = 1 then
          rx_data <= x"FFFFFFFF";
        else
          rx_data <= x"000000" & rx_buf(conv_integer(rx_ptr + 1));
        end if;
        rx_ptr <= rx_ptr + 1;
        rx_len <= rx_len - 1;
      else
        if rx_ready = '1' and rx_invalid = '0' and rx_len < 2048 then
          if rx_len = 0 then
            rx_data <= x"000000" & rx_dat;
          end if;
          rx_buf(conv_integer(rx_ptr + rx_len)) <= rx_dat;
          rx_len <= rx_len + 1;
          rx_invalid <= '1';
        else
          rx_invalid <= '0';
        end if;
      end if;
    end if;
  end process;

end Behavioral;
