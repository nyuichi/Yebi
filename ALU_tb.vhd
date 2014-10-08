library IEEE;
use IEEE.std_logic_1164.all;

entity ALU_tb is
  port (
    );
end ALU_tb;

architecture Behavioral of ALU_tb is

  component ALU is
    port (
      clk : in std_logic;
      code : in std_logic_vector(1 downto 0);
      arg0 : in std_logic_vector(31 downto 0);
      arg1 : in std_logic_vector(31 downto 0);
      ival : in std_logic_vector(31 downto 0);
      retv : out std_logic_vector(31 downto 0));
  end component;

  signal clk_gen : std_logic;

  signal mycode : std_logic_vector(1 downto 0);
  signal myarg0 : std_logic_vector(31 downto 0);
  signal myarg1 : std_logic_vector(31 downto 0);
  signal myival : std_logic_vector(31 downto 0);
  signal myretv : std_logic_vector(31 downto 0);

begin

  myALU : ALU port map (
    clk => clk_gen,
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

    myarg0 <= 100;
    myarg1 <= 200;
    ival <= 300;

    wait for 30 ns;

    assert retv == 300 report "NG";

    -- SUB

    mycode <= "01";

    wait for 15 ns;

    myarg0 <= 100;
    myarg1 <= 200;
    ival <= 0;

    wait for 30 ns;

    assert retv == -100 report "NG";

    -- SHIFT LEFT

    mycode <= "10";

    wait for 15 ns;

    myarg0 <= 100;
    myarg1 <= 0;
    ival <= 3;

    wait for 30 ns;

    assert retv == 800 report "NG";

    -- SHIFT RIGHT

    mycode <= "10";

    wait for 15 ns;

    myarg0 <= 100;
    myarg1 <= 0;
    ival <= -3;

    wait for 30 ns;

    assert retv == 12 report "NG";

    -- FNEG

    mycode <= "11";

    wait for 15 ns;

    myarg0 <= 2147483648;
    myarg1 <= 0;
    ival <= 0;

    wait for 30 ns;

    assert retv == 0 report "NG";

  end process;

end Behavioral;
