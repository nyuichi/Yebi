library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package Util is

  type regfile_t is
    array(0 to 14) of std_logic_vector(31 downto 0);

  type ram_t is
    array(0 to 107) of std_logic_vector(31 downto 0);

end package;
