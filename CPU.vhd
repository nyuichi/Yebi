library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.Util.all;

entity CPU is
  port (
    clk : in std_logic;
    ram_addr : out std_logic_vector(19 downto 0);
    ram_rx_en : out std_logic;
    ram_rx_data : in std_logic_vector(31 downto 0);
    ram_tx_en : out std_logic;
    ram_tx_data : out std_logic_vector(31 downto 0);
    io_tx_en : out std_logic;
    io_tx_data : out std_logic_vector(31 downto 0);
    io_rx_en : out std_logic;
    io_rx_data : in std_logic_vector(31 downto 0));
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

  signal myregfile, my_regfile : regfile_t := (others => (others => '0'));
  signal mystate, my_state : state_t := FETCHING;
  signal mycount, my_count : integer range 0 to 3 := 1;

  -- Fetch
  signal mypc, my_pc : std_logic_vector(31 downto 0) := (others => '0');
  signal mycode, my_code : std_logic_vector(31 downto 0) := (others => '0');

  -- Decode
  signal myopcode, my_opcode : std_logic_vector(3 downto 0) := (others => '0');
  signal myregindex, my_regindex : std_logic_vector(3 downto 0) := (others => '0');
  signal myoperand0, my_operand0 : std_logic_vector(31 downto 0) := (others => '0');
  signal myoperand1, my_operand1 : std_logic_vector(31 downto 0) := (others => '0');
  signal myoperand2, my_operand2 : std_logic_vector(31 downto 0) := (others => '0');
  signal myoperand3, my_operand3 : std_logic_vector(31 downto 0) := (others => '0');
  signal mynextcount : integer range 0 to 3 := 3;

  -- Execute
  signal myALUarg1 : std_logic_vector(31 downto 0) := (others => '0');
  signal myALUarg2 : std_logic_vector(31 downto 0) := (others => '0');
  signal myALUarg3 : std_logic_vector(31 downto 0) := (others => '0');
  signal myALUcode : std_logic_vector(1 downto 0) := (others => '0');
  signal myALUretx : std_logic_vector(3 downto 0) := (others => '0');
  signal myALUretv : std_logic_vector(31 downto 0) := (others => '0');
  signal myIOretx : std_logic_vector(3 downto 0) := (others => '0');
  signal myIOretv : std_logic_vector(31 downto 0) := (others => '0');
  signal myRAMretx : std_logic_vector(3 downto 0) := (others => '0');
  signal myRAMretv : std_logic_vector(31 downto 0) := (others => '0');
  signal myretx, my_retx : std_logic_vector(3 downto 0) := (others => '0');
  signal myretv, my_retv : std_logic_vector(31 downto 0) := (others => '0');
  signal mynextpc, my_nextpc : std_logic_vector(31 downto 0) := (others => '0');

begin

  myALU : ALU port map (
    code => myALUcode,
    arg0 => myALUarg1,
    arg1 => myALUarg2,
    ival => myALUarg3,
    retv => myALUretv);

  process(clk)
  begin
    if rising_edge(clk) then
      case mystate is
        when FETCHING =>
          mypc <= my_pc;
          mycode <= my_code;
        when DECODING =>
          myopcode <= my_opcode;
          myregindex <= my_regindex;
          myoperand0 <= my_operand0;
          myoperand1 <= my_operand1;
          myoperand2 <= my_operand2;
          myoperand3 <= my_operand3;
        when EXECUTING =>
          myretx <= my_retx;
          myretv <= my_retv;
          mynextpc <= my_nextpc;
        when WRITING =>
          myregfile <= my_regfile;
      end case;

      -- RAM

      if mystate = FETCHING then
        ram_addr <= myregfile(15)(19 downto 0);
        ram_rx_en <= '1';
      elsif mystate = EXECUTING and myopcode = "1000" then
        ram_addr <= myoperand2 + myoperand3;
        ram_rx_en <= '1';
      elsif mystate = EXECUTING and myopcode = "1001" then
        ram_addr <= myoperand2 + myoperand3;
        ram_tx_data <= myoperand1;
        ram_tx_en <= '1';
      else
        ram_tx_en <= '0';
        ram_rx_en <= '0';
      end if;

      -- IO

      if mystate = WRITING and myopcode = "1010" then
        io_rx_en <= '1';
      elsif mystate = EXECUTING and myopcode = "1011" and mycount = 0 then
        io_tx_data <= myoperand1;
        io_tx_en <= '1';
      else
        io_rx_en <= '0';
        io_tx_en <= '0';
      end if;

      mystate <= my_state;
      mycount <= my_count;
    end if;
  end process;

  -----------
  -- State --
  -----------

  process(mystate, mycount, mynextcount)
  begin
    case mystate is
      when FETCHING =>
        if mycount = 0 then
          my_state <= DECODING;
        else
          my_count <= mycount - 1;
        end if;
      when DECODING =>
        my_state <= EXECUTING;
        my_count <= mynextcount;
      when EXECUTING =>
        if mycount = 0 then
          my_state <= WRITING;
        else
          my_count <= mycount - 1;
        end if;
      when WRITING =>
        my_state <= FETCHING;
        my_count <= 3;
    end case;
  end process;

  -----------
  -- Fetch --
  -----------

  process(myregfile, ram_rx_data)
  begin
    my_pc <= myregfile(15);
    my_code <= ram_rx_data;
  end process;

  ------------
  -- Decode --
  ------------

  process(mycode, myregfile)
  begin
    my_opcode <= mycode(31 downto 28);
    my_regindex <= mycode(27 downto 24);
    my_operand0 <= myregfile(conv_integer(mycode(27 downto 24)));
    my_operand1 <= myregfile(conv_integer(mycode(23 downto 20)));
    my_operand2 <= myregfile(conv_integer(mycode(19 downto 16)));

    if mycode(15) = '0' then
      my_operand3 <= x"0000" & mycode(15 downto 0);
    else
      my_operand3 <= x"FFFF" & mycode(15 downto 0);
    end if;

    case mycode(31 downto 29) is
      when "100" =>
        mynextcount <= 1;
      when others =>
        mynextcount <= 0;
    end case;
  end process;

  -------------
  -- Execute --
  -------------

  -- ALU
  process(myopcode, myregindex, myoperand1, myoperand2, myoperand3)
  begin
    case myopcode(3 downto 2) is
      when "00" =>
        myALUcode <= myopcode(1 downto 0);
        myALUarg1 <= myoperand1;
        myALUarg2 <= myoperand2;
        myALUarg3 <= myoperand3;
        myALUretx <= myregindex;
      when others =>
        myALUcode <= (others => '0');
        myALUarg1 <= (others => '0');
        myALUarg2 <= (others => '0');
        myALUarg3 <= (others => '0');
        myALUretx <= (others => '0');
    end case;
  end process;

  -- Branch
  process(mypc, myopcode, myoperand0, myoperand1, myoperand2, myoperand3)
  begin
    case myopcode(3 downto 1) is
      when "110" =>
        if myopcode(0) = '0' then
          if myoperand0 = myoperand1 then
            my_nextpc <= myoperand2 + myoperand3;
          else
            my_nextpc <= mypc + 1;
          end if;
        else
          if myoperand0 <= myoperand1 then
            my_nextpc <= myoperand2 + myoperand3;
          else
            my_nextpc <= mypc + 1;
          end if;
        end if;
      when others =>
        my_nextpc <= mypc + 1;
    end case;
  end process;

  -- IO
  process(myopcode, myregindex, myoperand1, io_rx_data)
  begin
    case myopcode is
      when "1010" =>                    -- READ
        myIOretx <= myregindex;
        myIOretv <= io_rx_data;
      when "1011" =>                    -- WRITE
        myIOretx <= (others => '0');
        myIOretv <= (others => '0');
      when others =>
        myIOretx <= (others => '0');
        myIOretv <= (others => '0');
    end case;
  end process;

  -- RAM
  process(myopcode, myregindex, ram_rx_data)
  begin
    case myopcode is
      when "1000" =>                    -- load
        myRAMretx <= myregindex;
        myRAMretv <= ram_rx_data;
      when "1001" =>                    -- store
        myRAMretx <= (others => '0');
        myRAMretv <= (others => '0');
      when others =>
        myRAMretx <= (others => '0');
        myRAMretv <= (others => '0');
    end case;
  end process;

  -- Join
  process(myopcode, myALUretx, myALUretv, myIOretx, myIOretv, myRAMretx, myRAMretv)
  begin
    case myopcode(3 downto 2) is
      when "00" =>
        my_retx <= myALUretx;
        my_retv <= myALUretv;
      when "10" =>
        case myopcode(1) is
          when '0' =>
            my_retx <= myRAMretx;
            my_retv <= myRAMretv;
          when '1' =>
            my_retx <= myIOretx;
            my_retv <= myIOretv;
          when others =>
            my_retx <= (others => '0');
            my_retv <= (others => '0');
        end case;
      when others =>
        my_retx <= (others => '0');
        my_retv <= (others => '0');
    end case;
  end process;

  -----------
  -- Write --
  -----------

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
