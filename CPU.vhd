library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.Util.all;

entity CPU is
  port (
    clk : in std_logic;
    ram : in ram_t);
end CPU;

architecture Behavioral of CPU is

  component ALU is
    port (
      code : in std_logic_vector(1 downto 0);
      arg0 : in std_logic_vector(31 downto 0);
      arg1 : in std_logic_vector(31 downto 0);
      ival : in std_logic_vector(31 downto 0);
      retv : out std_logic_vector(31 downto 0));
  end component;

  component Decode is
    port (
      code : in std_logic_vector(31 downto 0);
      opcode : out std_logic_vector(3 downto 0);
      operand0 : out std_logic_vector(3 downto 0);
      operand1 : out std_logic_vector(3 downto 0);
      operand2 : out std_logic_vector(3 downto 0);
      operand3 : out std_logic_vector(15 downto 0));
  end component;

  signal mypc, my_pc : std_logic_vector(31 downto 0) := (others => '0');
  signal myregfile, my_regfile : regfile_t := (others => (others => '0'));

  -- Fetch
  signal mycode : std_logic_vector(31 downto 0) := (others => '0');

  -- Decode
  signal myopcode : std_logic_vector(3 downto 0) := (others => '0');
  signal myoperand0 : std_logic_vector(3 downto 0) := (others => '0');
  signal myoperand1 : std_logic_vector(3 downto 0) := (others => '0');
  signal myoperand2 : std_logic_vector(3 downto 0) := (others => '0');
  signal myoperand3 : std_logic_vector(15 downto 0) := (others => '0');

  -- Read
  signal myarg0 : std_logic_vector(31 downto 0) := (others => '0');
  signal myarg1 : std_logic_vector(31 downto 0) := (others => '0');
  signal myarg2 : std_logic_vector(31 downto 0) := (others => '0');

  -- Execute
  signal myALUcode : std_logic_vector(1 downto 0) := (others => '0');

  -- Write
  signal myretx : std_logic_vector(3 downto 0) := (others => '0');
  signal myretv : std_logic_vector(31 downto 0) := (others => '0');

begin

  myALU : ALU port map (
    code => myALUcode,
    arg0 => myarg0,
    arg1 => myarg1,
    ival => myarg2,
    retv => myretv);

  myDecode : Decode port map (
    code => mycode,
    opcode => myopcode,
    operand0 => myoperand0,
    operand1 => myoperand1,
    operand2 => myoperand2,
    operand3 => myoperand3);

  sequential: process(clk)
  begin
    if rising_edge(clk) then
      mypc <= my_pc;
      myregfile <= my_regfile;
    end if;
  end process;

  -----------
  -- Fetch --
  -----------

  process(mypc, ram)
  begin
    mycode <= ram(conv_integer(mypc));
    my_pc <= mypc + 1;
  end process;

  ----------
  -- Read --
  ----------

  process(myregfile, myoperand1, myoperand2, myoperand3)
  begin
    if myoperand1 = 15 then
      myarg0 <= x"00000000";
    else
      myarg0 <= myregfile(conv_integer(myoperand1));
    end if;

    if myoperand2 = 15 then
      myarg1 <= x"00000000";
    else
      myarg1 <= myregfile(conv_integer(myoperand2));
    end if;

    if myoperand3(15) = '0' then
      myarg2 <= x"0000" & myoperand3;
    else
      myarg2 <= x"1111" & myoperand3;
    end if;
  end process;

  -------------
  -- Execute --
  -------------

  process(myopcode, myoperand0)
  begin
    case myopcode(3 downto 2) is
      when "00" =>
        myALUcode <= myopcode(1 downto 0);
        myretx <= myoperand0;
      when others =>
        myALUcode <= (others => '0');
        myretx <= (others => '0');
    end case;
  end process;

  -----------
  -- Write --
  -----------

  process(myretx, myretv)
  begin
    if myretx /= 15 then
      my_regfile(conv_integer(myretx)) <= myretv;
    end if;
  end process;

end Behavioral;
