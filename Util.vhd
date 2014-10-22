library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package Util is

  type regfile_t is
    array(0 to 15) of std_logic_vector(31 downto 0);

  type ram_t is
    array(0 to 16383) of std_logic_vector(31 downto 0);
    --array(0 to 1048576) of std_logic_vector(31 downto 0);

  type state_t is (
    FETCHING, DECODING, EXECUTING, WRITING);

end package;
