library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.Util.all;

entity CPU is
  port (
    clk : in std_logic;
    ram : in ram_t;
    tx_go : out std_logic;
    tx_busy : in std_logic;
    tx_data : out std_logic_vector(7 downto 0));
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

  signal myregfile, my_regfile : regfile_t := (others => (others => '0'));

  -- Fetch
  signal mypc : std_logic_vector(31 downto 0) := (others => '0');
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
  signal myarg3 : std_logic_vector(31 downto 0) := (others => '0');

  -- Execute
  signal myALUarg1 : std_logic_vector(31 downto 0) := (others => '0');
  signal myALUarg2 : std_logic_vector(31 downto 0) := (others => '0');
  signal myALUarg3 : std_logic_vector(31 downto 0) := (others => '0');
  signal myALUcode : std_logic_vector(1 downto 0) := (others => '0');
  signal mynextpc : std_logic_vector(31 downto 0) := (others => '0');

  -- Write
  signal myretx : std_logic_vector(3 downto 0) := (others => '0');
  signal myretv : std_logic_vector(31 downto 0) := (others => '0');

begin

  myALU : ALU port map (
    code => myALUcode,
    arg0 => myALUarg1,
    arg1 => myALUarg2,
    ival => myALUarg3,
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
      myregfile <= my_regfile;
    end if;
  end process;

  -----------
  -- Fetch --
  -----------

  process(myregfile, ram)
  begin
    mypc <= myregfile(15);
    mycode <= ram(conv_integer(myregfile(15)));
  end process;

  ----------
  -- Read --
  ----------

  process(myregfile, myoperand0, myoperand1, myoperand2, myoperand3)
  begin
    myarg0 <= myregfile(conv_integer(myoperand0));
    myarg1 <= myregfile(conv_integer(myoperand1));
    myarg2 <= myregfile(conv_integer(myoperand2));

    if myoperand3(15) = '0' then
      myarg3 <= x"0000" & myoperand3;
    else
      myarg3 <= x"1111" & myoperand3;
    end if;
  end process;

  -------------
  -- Execute --
  -------------

  -- ALU
  process(myopcode, myoperand0, myarg1, myarg2, myarg3)
  begin
    case myopcode(3 downto 2) is
      when "00" =>
        myALUcode <= myopcode(1 downto 0);
        myALUarg1 <= myarg1;
        myALUarg2 <= myarg2;
        myALUarg3 <= myarg3;
        myretx <= myoperand0;
      when others =>
        myALUcode <= (others => '0');
        myALUarg1 <= (others => '0');
        myALUarg2 <= (others => '0');
        myALUarg3 <= (others => '0');
        myretx <= (others => '0');
    end case;
  end process;

  -- Branch
  process(mypc, myopcode, myarg0, myarg1, myarg2, myarg3)
  begin
    case myopcode(3 downto 1) is
      when "110" =>
        if myopcode(0) = '0' then
          if myarg0 = myarg1 then
            mynextpc <= myarg2 + myarg3;
          else
            mynextpc <= mypc + 1;
          end if;
        else
          if myarg0 <= myarg1 then
            mynextpc <= myarg2 + myarg3;
          else
            mynextpc <= mypc + 1;
          end if;
        end if;
      when others =>
        mynextpc <= mypc + 1;
    end case;
  end process;

  -----------
  -- Write --
  -----------

  process(myregfile, myretx, myretv, mynextpc)
  begin
    for i in 0 to 14 loop
      if myretx = i then
        my_regfile(i) <= myretv;
      else
        my_regfile(i) <= myregfile(i);
      end if;
    end loop;
    my_regfile(15) <= mynextpc;
  end process;

  -----------
  -- Debug --
  -----------

  process(clk)
  begin
    if tx_busy = '1' then
      tx_go <= '0';
    else
      tx_go <= '1';
      tx_data <= myregfile(4)(7 downto 0);
    end if;
  end process;

end Behavioral;
