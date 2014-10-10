library IEEE;
use IEEE.std_logic_1164.all;

entity Decode is
  port (
    code : in std_logic_vector(31 downto 0);
    opcode : out std_logic_vector(3 downto 0);
    operand0 : out std_logic_vector(3 downto 0);
    operand1 : out std_logic_vector(3 downto 0);
    operand2 : out std_logic_vector(3 downto 0);
    operand3 : out std_logic_vector(15 downto 0));
end Decode;

architecture Behavioral of Decode is
begin

  -- combinational
  process(code)
  begin
    opcode <= code(31 downto 28);
    operand0 <= code(27 downto 24);
    operand1 <= code(23 downto 20);
    operand2 <= code(19 downto 16);
    operand3 <= code(15 downto 0);
  end process;

end Behavioral;
