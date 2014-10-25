library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity FPU is
  port (
    code : in std_logic_vector(1 downto 0);
    arg0 : in std_logic_vector(31 downto 0);
    arg1 : in std_logic_vector(31 downto 0);
    retv : out std_logic_vector(31 downto 0));
end FPU;

architecture Behavioral of FPU is

  component fadd is
    port (
      x, y : in  std_logic_vector(31 downto 0);
      q    : out std_logic_vector(31 downto 0));
  end component;

  component fmul is
    port (
      x, y : in  std_logic_vector(31 downto 0);
      q    : out std_logic_vector(31 downto 0));
  end component;

  signal fadd_retv : std_logic_vector(31 downto 0) := (others => '0');
  signal fmul_retv : std_logic_vector(31 downto 0) := (others => '0');

begin

  myFADD : FADD port map (
    x => arg0,
    y => arg1,
    q => fadd_retv);

  myFMUL : FMUL port map (
    x => arg0,
    y => arg1,
    q => fmul_retv);

  -- combinational
  process(code, arg0, arg1, fadd_retv, fmul_retv)
  begin
    case code is
      when "00" =>
        retv <= fadd_retv;
      when "01" =>
        retv <= fmul_retv;
      when others =>
        retv <= (others => 'Z');
    end case;
  end process;

end Behavioral;
