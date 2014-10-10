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
      clk : in std_logic;
      code : in std_logic_vector(1 downto 0);
      arg0 : in std_logic_vector(31 downto 0);
      arg1 : in std_logic_vector(31 downto 0);
      ival : in std_logic_vector(31 downto 0);
      retv : out std_logic_vector(31 downto 0));
  end component;

  signal myregfile : regfile_t := (others => (others => '0'));

  -- Fetch
  signal mypc, my_pc : std_logic_vector(31 downto 0) := (others => '0');
  signal mycode : std_logic_vector(31 downto 0) := (others => '0');

  -- Decode
  signal myopcode : std_logic_vector(3 downto 0) := (others => '0');
  signal myoperand0 : std_logic_vector(3 downto 0) := (others => '0');
  signal myoperand1 : std_logic_vector(3 downto 0) := (others => '0');
  signal myoperand2 : std_logic_vector(3 downto 0) := (others => '0');
  signal myoperand3 : std_logic_vector(15 downto 0) := (others => '0');
  signal myALUcode : std_logic_vector(1 downto 0) := (others => '0');
  signal myALUarg0 : std_logic_vector(31 downto 0) := (others => '0');
  signal myALUarg1 : std_logic_vector(31 downto 0) := (others => '0');
  signal myALUival : std_logic_vector(31 downto 0) := (others => '0');
  signal myALUretv : std_logic_vector(31 downto 0) := (others => '0');
  signal myALUretx : std_logic_vector(3 downto 0) := (others => '0');

  -- Execute
  signal mydestx : std_logic_vector(3 downto 0) := (others => '0');

  -- Write
  signal myretx : std_logic_vector(3 downto 0) := (others => '0');
  signal myretv : std_logic_vector(31 downto 0) := (others => '0');

begin

  myALU : ALU port map (
    clk => clk,
    code => myALUcode,
    arg0 => myALUarg0,
    arg1 => myALUarg1,
    ival => myALUival,
    retv => myALUretv);

  -----------
  -- Fetch --
  -----------

  -- latch
  process(clk)
  begin
    if rising_edge(clk) then
      mypc <= my_pc;
    end if;
  end process;

  -- body
  process(mypc)
  begin
    my_pc <= mypc + 1;
    mycode <= ram(conv_integer(mypc));
    myregfile(15) <= mypc;
  end process;

  ------------
  -- Decode --
  ------------

  -- latch
  process(clk)
  begin
    if rising_edge(clk) then
      myopcode <= mycode(31 downto 28);
      myoperand0 <= mycode(27 downto 24);
      myoperand1 <= mycode(23 downto 20);
      myoperand2 <= mycode(19 downto 16);
      myoperand3 <= mycode(15 downto 0);
    end if;
  end process;

  -- body
  process(myopcode, myoperand0, myoperand1, myoperand2, myoperand3)
  begin
    case myopcode(3 downto 2) is
      when "00" =>
        myALUcode <= myopcode(1 downto 0);
        myALUarg0 <= myregfile(conv_integer(myoperand1));
        myALUarg1 <= myregfile(conv_integer(myoperand2));
        if myoperand3(15) = '0' then
          myALUival <= x"0000" & myoperand3;
        else
          myALUival <= x"1111" & myoperand3;
        end if;
        myALUretx <= myoperand0;
      when others =>
        assert false report "unsuppoted instruction";
    end case;
  end process;

  -------------
  -- Execute --
  -------------

  process(clk)
  begin
    if rising_edge(clk) then
      mydestx <= myALUretx;
    end if;
  end process;

  -----------
  -- Write --
  -----------

  -- latch
  process(clk)
  begin
    if rising_edge(clk) then
      myretx <= mydestx;
      myretv <= myALUretv;
    end if;
  end process;

  -- body
  process(myretx, myretv)
  begin
    myregfile(conv_integer(myretx)) <= myretv;
  end process;

end Behavioral;
