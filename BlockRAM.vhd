library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.Util.all;

entity BlockRAM is
  port (
    clk : in std_logic;
    addr : in std_logic_vector(19 downto 0);
    rx : out std_logic_vector(31 downto 0);
    rx_en : in std_logic;
    tx : in std_logic_vector(31 downto 0);
    tx_en : in std_logic);
end BlockRAM;

architecture Behavioral of BlockRAM is

  constant myramfib : ram_t := (
    0 => x"00000000",                        -- 0 nop
    1 => x"0300000A",                        -- 1 mov $3, 10
    2 => x"01000001",                        -- 2 mov $1, 1
    3 => x"02000001",                        -- 3 mov $2, 1
                                        --  LOOP:
    4 => x"C30F0006",                        -- 4 beq $3, $0, EXIT
    5 => x"0330FFFF",                        -- 5 add $3, $3, -1
    6 => x"04200000",                        -- 6 mov $4, $2
    7 => x"02210000",                        -- 7 add $2, $2, $1
    8 => x"01400000",                        -- 8 mov $1, $4
    9 => x"C00FFFFB",                        -- 9 br LOOP
                                        --  EXIT:
    10 => x"B0100000",                        -- A write $1
    11 => x"C00FFFFF",                        -- B br EXIT
    others => (others => '0'));

  constant myramlo : ram_t := (
    0 => x"00000000",                        -- 0 nop
    1 => x"0100FFFF",                        -- 1 mov $1, -1
    2 => x"A2000000",                        -- 2 read $2
    3 => x"C12FFFFF",                        -- 3 beq $1, $2, $ip, -1
    4 => x"B0200000",                        -- 4 write $2
    5 => x"C00FFFFD",                        -- 5 br -3
    others => (others => '0'));

  signal ram : ram_t := myramfib;

  signal addr_reg : std_logic_vector(19 downto 0) := (others => '0');

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if tx_en = '1' then
        ram(conv_integer(addr)) <= tx;
      end if;
      addr_reg <= addr;
    end if;
  end process;

  rx <= ram(conv_integer(addr_reg));

end Behavioral;
