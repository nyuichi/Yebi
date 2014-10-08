library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity ALU is
  port (
    clk : in std_logic;
    code : in std_logic_vector(1 downto 0);
    arg0 : in std_logic_vector(31 downto 0);
    arg1 : in std_logic_vector(31 downto 0);
    ival : in std_logic_vector(31 downto 0);
    retv : out std_logic_vector(31 downto 0));
end ALU;

architecture Behavioral of ALU is

  signal mycode : std_logic_vector(1 downto 0) := "00";
  signal myarg0 : std_logic_vector(31 downto 0);
  signal myarg1 : std_logic_vector(31 downto 0);
  signal myival : std_logic_vector(31 downto 0);

begin

  -- latch
  process(clk)
  begin
    if rising_edge(clk) then
      mycode <= code;
      myarg0 <= arg0;
      myarg1 <= arg1;
      myival <= ival;
    end if;
  end process;

  -- body
  process(mycode, myarg0, myarg1, myival)
  begin
    case mycode is
      when "00" =>
        retv <= myarg0 + myarg1 + myival;
      when "01" =>
        retv <= myarg0 - myarg1;
      when "10" =>
        if ival(31) = '0' then
          retv <= std_logic_vector(shift_left(unsigned(myarg0), to_integer(unsigned(ival))));
        else
          retv <= std_logic_vector(shift_right(unsigned(myarg0), -to_integer(signed(ival))));
        end if;
      when "11" =>
        retv <= not myarg0(31) & myarg0(30 downto 0);
      when others =>
        assert false;
    end case;
  end process;

end Behavioral;
