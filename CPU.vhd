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
    tx_data : out std_logic_vector(7 downto 0);
    rx_invalid : out std_logic;
    rx_ready : in std_logic;
    rx_data : in std_logic_vector(7 downto 0));
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
  signal mystate, my_state : state_t := RUNNING;

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
  signal myALUretx : std_logic_vector(3 downto 0) := (others => '0');
  signal myALUretv : std_logic_vector(31 downto 0) := (others => '0');
  signal mynextpc : std_logic_vector(31 downto 0) := (others => '0');

  -- IO
  signal my_iox : std_logic_vector(3 downto 0) := (others => '0');
  signal my_iov : std_logic_vector(3 downto 0) := (others => '0');

  -- Write
  signal myretx : std_logic_vector(3 downto 0) := (others => '0');
  signal myretv : std_logic_vector(31 downto 0) := (others => '0');

begin

  myALU : ALU port map (
    code => myALUcode,
    arg0 => myALUarg1,
    arg1 => myALUarg2,
    ival => myALUarg3,
    retv => myALUretv);

  myDecode : Decode port map (
    code => mycode,
    opcode => myopcode,
    operand0 => myoperand0,
    operand1 => myoperand1,
    operand2 => myoperand2,
    operand3 => myoperand3);

  process(clk)
  begin
    if rising_edge(clk) then
      case mystate is
        when RUNNING =>
          myregfile <= my_regfile;
          mystate <= my_state;

        -- WRITE
        when PRE_WRITING =>
          tx_go <= '1';
          tx_data <= my_iov;
        when WRITING =>
          tx_go <= '0';
          if tx_busy = '0' then
            mystate <= RUNNING;
          end if;

        -- READ
        when READING =>
          if rx_ready = '1' then
            rx_invalid <= '1';
            myregfile(conv_integer(my_iox)) <= x"000000" & rx_data;
            mystate <= RUNNING;
          end if;
        when POST_READING =>
          rx_invalid <= '0';
      end case;
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
        myALUretx <= myoperand0;
      when others =>
        myALUcode <= (others => '0');
        myALUarg1 <= (others => '0');
        myALUarg2 <= (others => '0');
        myALUarg3 <= (others => '0');
        myALUretx <= (others => '0');
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

  -- IO
  process(myopcode, myoperand0, myarg1)
  begin
    case myopcode is
      when "1010" =>                    -- READ
        my_iox <= myoperand0;
        my_iov <= (others => '0');
        my_state <= READING;
      when "1011" =>                    -- WRITE
        my_iox <= (others => '0');
        my_iov <= myarg1(7 downto 0);
        my_state <= PRE_WRITING;
      when others =>
        my_iox <= (others => '0');
        my_iov <= (others => '0');
        my_state <= RUNNING;
    end case;
  end process;

  -----------
  -- Write --
  -----------

  process(myopcode, myALUretx, myALUretv)
  begin
    case myopcode(3 downto 2) is
      when "00" =>
        myretx <= myALUretx;
        myretv <= myALUretv;
      when others =>
        myretx <= (others => '0');
        myretv <= (others => '0');
    end case;
  end process;

  process(myregfile, myretx, myretv, mynextpc)
  begin
    my_regfile(0) <= (others => '0');

    for i in 1 to 14 loop
      if myretx = i then
        my_regfile(i) <= myretv;
      else
        my_regfile(i) <= myregfile(i);
      end if;
    end loop;

    my_regfile(15) <= mynextpc;
  end process;

end Behavioral;
