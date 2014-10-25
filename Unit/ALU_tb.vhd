library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ALU_tb is
  -- pass
end ALU_tb;

architecture Behavioral of ALU_tb is

  component ALU is
    port (
      code : in std_logic_vector(1 downto 0);
      arg0 : in std_logic_vector(31 downto 0);
      arg1 : in std_logic_vector(31 downto 0);
      ival : in std_logic_vector(31 downto 0);
      retv : out std_logic_vector(31 downto 0));
  end component;

  signal clk_gen : std_logic;

  signal mycode : std_logic_vector(1 downto 0) := "00";
  signal myarg0 : std_logic_vector(31 downto 0) := (others => '0');
  signal myarg1 : std_logic_vector(31 downto 0) := (others => '0');
  signal myival : std_logic_vector(31 downto 0) := (others => '0');
  signal myretv : std_logic_vector(31 downto 0) := (others => '0');

begin

  myALU : ALU port map (
    code => mycode,
    arg0 => myarg0,
    arg1 => myarg1,
    ival => myival,
    retv => myretv);

  -- clock generator
  process
  begin
    clk_gen <= '0';
    wait for 5 ns;
    clk_gen <= '1';
    wait for 5 ns;
  end process;

  -- test cases
  process
  begin

    -- ADD

    mycode <= "00";

    wait for 15 ns;

    myarg0 <= x"00000064";
    myarg1 <= x"000000c8";
    myival <= x"0000012c";

    wait for 30 ns;

    assert myretv = x"00000258" report "this";

    -- SUB

    mycode <= "01";

    wait for 15 ns;

    myarg0 <= x"00000064";
    myarg1 <= x"000000c8";
    myival <= x"0000012c";

    wait for 30 ns;

    assert myretv = x"ffffff9c";

    -- SHIFT LEFT

    mycode <= "10";

    wait for 15 ns;

    myarg0 <= x"00000064";
    myarg1 <= x"00000000";
    myival <= x"00000003";

    wait for 30 ns;

    assert myretv = x"00000320";

    -- SHIFT LEFT(2)

    mycode <= "10";

    wait for 15 ns;

    myarg0 <= x"00000064";
    myarg1 <= x"00000004";
    myival <= x"00000003";

    wait for 30 ns;

    assert myretv = x"00003200";

    -- SHIFT LEFT(3)

    mycode <= "10";

    wait for 15 ns;

    myarg0 <= x"00000064";
    myarg1 <= x"00000032";
    myival <= x"00000003";

    wait for 30 ns;

    assert myretv = x"00000000";

    -- SHIFT RIGHT

    mycode <= "10";

    wait for 15 ns;

    myarg0 <= x"00000064";
    myarg1 <= x"00000000";
    myival <= x"fffffffd";

    wait for 30 ns;

    assert myretv = x"0000000c";

    -- SHIFT RIGHT(2)

    mycode <= "10";

    wait for 15 ns;

    myarg0 <= x"00000064";
    myarg1 <= x"00000001";
    myival <= x"fffffffd";

    wait for 30 ns;

    assert myretv = x"00000019";

    -- SHIFT RIGHT(3)

    mycode <= "10";

    wait for 15 ns;

    myarg0 <= x"00000064";
    myarg1 <= x"ffffff00";
    myival <= x"fffffffd";

    wait for 30 ns;

    assert myretv = x"00000000";

    -- FNEG

    mycode <= "11";

    wait for 15 ns;

    myarg0 <= x"80000000";
    myarg1 <= x"00000000";
    myival <= x"00000000";

    wait for 30 ns;

    assert myretv = x"00000000";

  end process;

end Behavioral;
