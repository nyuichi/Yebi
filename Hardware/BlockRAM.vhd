library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.Util.all;

entity BlockRAM is
  port (
    clk : in std_logic;
    addr : in std_logic_vector(13 downto 0);
    rx : out std_logic_vector(31 downto 0);
    tx : in std_logic_vector(31 downto 0);
    tx_en : in std_logic);
end BlockRAM;

architecture Behavioral of BlockRAM is

  constant myramhello : ram_t := (
    0 => x"00000000",
    1 => x"01000041",
    2 => x"C0000001",
    others => (others => '0'));

  constant myramaaa : ram_t := (
    0 => x"00000000",
    1 => x"01000041",
    2 => x"B0100000",
    3 => x"C0000002",
    others => (others => '0'));

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
    11 => x"C00F0000",                        -- B br $ip
    others => (others => '0'));

  constant myramlo : ram_t := (
    0 => x"00000000",                        -- 0 nop
    1 => x"0100FFFF",                        -- 1 mov $1, -1
    2 => x"A2000000",                        -- 2 read $2
    3 => x"C12FFFFF",                        -- 3 beq $1, $2, $ip, -1
    4 => x"B0200000",                        -- 4 write $2
    5 => x"C00FFFFD",                        -- 5 br -3
    others => (others => '0'));

  constant myramlo2 : ram_t := (
    0 => x"00000000",                        -- 0 nop
    1 => x"0100FFFF",                        -- 1 mov $1, -1
    2 => x"A2000000",                        -- 2 read $2
    3 => x"C1200005",                        -- 3 beq $1, $2, 5
    4 => x"C0000006",                        -- 4 br 6
    5 => x"03300001",                        -- 5 add $3, $3, 1
    6 => x"B0300000",                        -- 6 write $2
    7 => x"C0000002",                        -- 7 br 2
    others => (others => '0'));

  constant myramfib2 : ram_t := (
    0 => x"00000000",
    1 => x"c00f001f",
    2 => x"02000002",
    3 => x"d12f001b",
    4 => x"0dd0ffff",
    5 => x"901d0000",
    6 => x"0110ffff",
    7 => x"90edffff",
    8 => x"90fdfffe",
    9 => x"0dd0fffe",
    10 => x"0ed00000",
    11 => x"c00ffff7",
    12 => x"0de00002",
    13 => x"8e0dffff",
    14 => x"02010000",
    15 => x"810d0000",
    16 => x"0dd00001",
    17 => x"0dd0ffff",
    18 => x"902d0000",
    19 => x"0110fffe",
    20 => x"90edffff",
    21 => x"90fdfffe",
    22 => x"0dd0fffe",
    23 => x"0ed00000",
    24 => x"c00fffea",
    25 => x"0de00002",
    26 => x"8e0dffff",
    27 => x"820d0000",
    28 => x"0dd00001",
    29 => x"01120000",
    30 => x"8c0e0000",
    31 => x"c00c0004",
    32 => x"0e001000",
    33 => x"0d001000",
    34 => x"0100000a",
    35 => x"90edffff",
    36 => x"90fdfffe",
    37 => x"0dd0fffe",
    38 => x"0ed00000",
    39 => x"c00fffdb",
    40 => x"0de00002",
    41 => x"8e0dffff",
    42 => x"b0100000",
    43 => x"c00fffff",
    44 => x"c00f0000",
    45 => x"c00f0000",
    46 => x"c00f0000",
    others => (others => '0'));

  constant myramfib3 : ram_t := (
    0 => x"00000000",
    1 => x"c00f001f",
    2 => x"02000002",
    3 => x"d12f001b",
    4 => x"0dd0ffff",
    5 => x"901d0000",
    6 => x"0110ffff",
    7 => x"90edffff",
    8 => x"90fdfffe",
    9 => x"0dd0fffe",
    10 => x"0ed00000",
    11 => x"c00ffff7",
    12 => x"0de00002",
    13 => x"8e0dffff",
    14 => x"02010000",
    15 => x"810d0000",
    16 => x"0dd00001",
    17 => x"0dd0ffff",
    18 => x"902d0000",
    19 => x"0110fffe",
    20 => x"90edffff",
    21 => x"90fdfffe",
    22 => x"0dd0fffe",
    23 => x"0ed00000",
    24 => x"c00fffea",
    25 => x"0de00002",
    26 => x"8e0dffff",
    27 => x"820d0000",
    28 => x"0dd00001",
    29 => x"01120000",
    30 => x"8c0e0000",
    31 => x"c00c0004",
    32 => x"0100000a",
    33 => x"90edffff",
    34 => x"90fdfffe",
    35 => x"0dd0fffe",
    36 => x"0ed00000",
    37 => x"c00fffdd",
    38 => x"0de00002",
    39 => x"8e0dffff",
    40 => x"b0100000",
    41 => x"c00f0000",
    42 => x"c00f0000",
    43 => x"c00f0000",
    44 => x"c00f0000",
    others => (others => '0'));

  constant myramboot : ram_t := (
    0 => x"00000000",
    1 => x"c00f0007",
    2 => x"a1000000",
    3 => x"d01f0002",
    4 => x"c00ffffe",
    5 => x"8c0e0000",
    6 => x"c00c0004",
    7 => x"c00f0000",
    8 => x"05004001",
    9 => x"06000003",
    10 => x"870ffffd",
    11 => x"0d000001",
    12 => x"2dd00014",
    13 => x"0e0d0000",
    14 => x"90edffff",
    15 => x"90fdfffe",
    16 => x"0dd0fffe",
    17 => x"0ed00000",
    18 => x"c00ffff0",
    19 => x"0de00002",
    20 => x"8e0dffff",
    21 => x"04010000",
    22 => x"90edffff",
    23 => x"90fdfffe",
    24 => x"0dd0fffe",
    25 => x"0ed00000",
    26 => x"c00fffe8",
    27 => x"0de00002",
    28 => x"8e0dffff",
    29 => x"03010000",
    30 => x"90edffff",
    31 => x"90fdfffe",
    32 => x"0dd0fffe",
    33 => x"0ed00000",
    34 => x"c00fffe0",
    35 => x"0de00002",
    36 => x"8e0dffff",
    37 => x"02010000",
    38 => x"90edffff",
    39 => x"90fdfffe",
    40 => x"0dd0fffe",
    41 => x"0ed00000",
    42 => x"c00fffd8",
    43 => x"0de00002",
    44 => x"8e0dffff",
    45 => x"22200008",
    46 => x"23300010",
    47 => x"24400018",
    48 => x"01120000",
    49 => x"03340000",
    50 => x"01130000",
    51 => x"90150000",
    52 => x"05500001",
    53 => x"c17f0003",
    54 => x"06000003",
    55 => x"c00fffd7",
    56 => x"0660ffff",
    57 => x"c60f0002",
    58 => x"c00fffd4",
    59 => x"90504000",
    60 => x"c0004001",
    61 => x"c00f0000",
    62 => x"c00f0000",
    63 => x"c00f0000",
    others => (others => '0'));

  -- shows 'OK' before starting reading
  constant myramboot2 : ram_t := (
    0 => x"00000000",
    1 => x"c00f0007",
    2 => x"a1000000",
    3 => x"d01f0002",
    4 => x"c00ffffe",
    5 => x"8c0e0000",
    6 => x"c00c0004",
    7 => x"c00f0000",
    8 => x"05004001",
    9 => x"06000003",
    10 => x"870ffffd",
    11 => x"0d000001",
    12 => x"2dd00014",
    13 => x"0e0d0000",
    14 => x"0100004f",
    15 => x"0200004b",
    16 => x"0300000a",
    17 => x"b0100000",
    18 => x"b0200000",
    19 => x"b0300000",
    20 => x"90edffff",
    21 => x"90fdfffe",
    22 => x"0dd0fffe",
    23 => x"0ed00000",
    24 => x"c00fffea",
    25 => x"0de00002",
    26 => x"8e0dffff",
    27 => x"04010000",
    28 => x"90edffff",
    29 => x"90fdfffe",
    30 => x"0dd0fffe",
    31 => x"0ed00000",
    32 => x"c00fffe2",
    33 => x"0de00002",
    34 => x"8e0dffff",
    35 => x"03010000",
    36 => x"90edffff",
    37 => x"90fdfffe",
    38 => x"0dd0fffe",
    39 => x"0ed00000",
    40 => x"c00fffda",
    41 => x"0de00002",
    42 => x"8e0dffff",
    43 => x"02010000",
    44 => x"90edffff",
    45 => x"90fdfffe",
    46 => x"0dd0fffe",
    47 => x"0ed00000",
    48 => x"c00fffd2",
    49 => x"0de00002",
    50 => x"8e0dffff",
    51 => x"22200008",
    52 => x"23300010",
    53 => x"24400018",
    54 => x"01120000",
    55 => x"03340000",
    56 => x"01130000",
    57 => x"90150000",
    58 => x"05500001",
    59 => x"c17f0003",
    60 => x"06000003",
    61 => x"c00fffd7",
    62 => x"0660ffff",
    63 => x"c60f0002",
    64 => x"c00fffd4",
    65 => x"90504000",
    66 => x"c0004001",
    67 => x"c00f0000",
    68 => x"c00f0000",
    69 => x"c00f0000",
    others => (others => '0'));

  constant myramboot3 : ram_t := (
    0 => x"00000000",
    1 => x"c00f0007",
    2 => x"a1000000",
    3 => x"d01f0002",
    4 => x"c00ffffe",
    5 => x"8c0e0000",
    6 => x"c00c0004",
    7 => x"c00f0000",
    8 => x"05004001",
    9 => x"06000003",
    10 => x"870ffffd",
    11 => x"0d000001",
    12 => x"2dd00014",
    13 => x"0e0d0000",
    14 => x"90edffff",
    15 => x"90fdfffe",
    16 => x"0dd0fffe",
    17 => x"0ed00000",
    18 => x"c00ffff0",
    19 => x"0de00002",
    20 => x"8e0dffff",
    21 => x"04010000",
    22 => x"90edffff",
    23 => x"90fdfffe",
    24 => x"0dd0fffe",
    25 => x"0ed00000",
    26 => x"c00fffe8",
    27 => x"0de00002",
    28 => x"8e0dffff",
    29 => x"03010000",
    30 => x"90edffff",
    31 => x"90fdfffe",
    32 => x"0dd0fffe",
    33 => x"0ed00000",
    34 => x"c00fffe0",
    35 => x"0de00002",
    36 => x"8e0dffff",
    37 => x"02010000",
    38 => x"90edffff",
    39 => x"90fdfffe",
    40 => x"0dd0fffe",
    41 => x"0ed00000",
    42 => x"c00fffd8",
    43 => x"0de00002",
    44 => x"8e0dffff",
    45 => x"22200008",
    46 => x"23300010",
    47 => x"24400018",
    48 => x"01120000",
    49 => x"03340000",
    50 => x"01130000",
    51 => x"90150000",
    52 => x"05500001",
    53 => x"c17f0003",
    54 => x"06000003",
    55 => x"c00fffd7",
    56 => x"0660ffff",
    57 => x"c60f0002",
    58 => x"c00fffd4",
    59 => x"90504000",
    60 => x"010000aa",
    61 => x"b0100000",
    62 => x"c0004001",
    63 => x"c00f0000",
    64 => x"c00f0000",
    65 => x"c00f0000",
    others => (others => '0'));

  signal ram : ram_t := myramboot3;

  signal addr_reg : std_logic_vector(13 downto 0) := (others => '0');

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
