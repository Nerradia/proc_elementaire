Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT

 --library xil_defaultlib;
 --use xil_defaultlib.op_codes.all;

 entity FSM is
  generic (
    op_code_size : integer  -- Largeur du signal des instructions
    );
  port (
    reset    : in  std_logic;
    clk      : in  std_logic;
    clk_en   : in  std_logic;

    cpu_init :  in std_logic; -- Du programmeur

    -- Compteur 
    init_cpt : out std_logic;
    en_cpt   : out std_logic;
    load_cpt : out std_logic;

    -- mux
    sel_mux  : out std_logic;

    -- Registres (et la bascule FF)
    init_ff  : out std_logic;
    init_acc : out std_logic;
    load_ff  : out std_logic;
    load_ri  : out std_logic;
    load_rd  : out std_logic;
    load_ra  : out std_logic;

    -- UAL
    sel_ual  : out std_logic_vector (op_code_size-1 downto 0);
    carry    : in  std_logic;

    -- RAM
    en_mem   : out std_logic;
    R_W      : out std_logic;

    op_code  : in std_logic_vector(op_code_size-1 downto 0)
    );

end entity FSM;

architecture rtl of FSM is

  
--  constant op_code_size : integer := 5;
  -- Instructions logiques
  constant OP_NOR  : std_logic_vector (op_code_size-1 downto 0) := "00000";
  constant OP_OR   : std_logic_vector (op_code_size-1 downto 0) := "00001";
  constant OP_AND  : std_logic_vector (op_code_size-1 downto 0) := "00010";
  constant OP_XOR  : std_logic_vector (op_code_size-1 downto 0) := "00011";
  
  -- Instructions mathématiques sur entiers
  constant OP_ADD  : std_logic_vector (op_code_size-1 downto 0) := "00100";
  constant OP_SUB  : std_logic_vector (op_code_size-1 downto 0) := "00101";
  constant OP_DIV  : std_logic_vector (op_code_size-1 downto 0) := "00110";
  constant OP_MUL  : std_logic_vector (op_code_size-1 downto 0) := "00111";
  constant OP_MOD  : std_logic_vector (op_code_size-1 downto 0) := "01000";

  -- Instructions mathématiques sur flottants
  constant OP_ADDF : std_logic_vector (op_code_size-1 downto 0) := "01001";
  constant OP_DIVF : std_logic_vector (op_code_size-1 downto 0) := "01010";
  constant OP_MULF : std_logic_vector (op_code_size-1 downto 0) := "01011";

  -- Conversions flottants/entiers
  constant OP_FTOI : std_logic_vector (op_code_size-1 downto 0) := "01100";
  constant OP_ITOF : std_logic_vector (op_code_size-1 downto 0) := "01101";

  -- Opérations mémoire
  constant OP_STA  : std_logic_vector (op_code_size-1 downto 0) := "10000";
  constant OP_JCC  : std_logic_vector (op_code_size-1 downto 0) := "10001";
  constant OP_JMP  : std_logic_vector (op_code_size-1 downto 0) := "10010";
  constant OP_GET  : std_logic_vector (op_code_size-1 downto 0) := "10011";

  -- Tests sur les entiers
  constant OP_TGT  : std_logic_vector (op_code_size-1 downto 0) := "10100";
  constant OP_TLT  : std_logic_vector (op_code_size-1 downto 0) := "10101";
  constant OP_TEQ  : std_logic_vector (op_code_size-1 downto 0) := "10110";

  -- Tests sur les flottants
  constant OP_TGTF : std_logic_vector (op_code_size-1 downto 0) := "10111";
  constant OP_TLTF : std_logic_vector (op_code_size-1 downto 0) := "11000";
  constant OP_TEQF : std_logic_vector (op_code_size-1 downto 0) := "11001";

  type STATES is (INIT, FETCH_INST, DECODE, FETCH_OP, EXE_UAL, STA, EXE_JCC); 
  signal state : STATES;
  signal next_state : STATES;
  begin

    process(state, op_code) is
    begin

      case state is
      when INIT =>
      next_state <= FETCH_INST;

      when FETCH_INST =>
      next_state <= DECODE;

      when DECODE =>
        case op_code is
          when OP_STA =>
            next_state <= STA;

          when OP_JCC =>
            next_state <= EXE_JCC;

          when others =>
            next_state <= FETCH_OP;

        end case;

           -- if op_code = OP_STA then -- MSB de l'op-code à 0 = Opération arithmétique ou logique 
           -- next_state <= FETCH_OP;
--
           -- elsif op_code = "10000" then
           -- next_state <= STA;
--
           -- elsif op_code = "10001" then
           -- next_state <= EXE_JCC;
--
           -- else 
           -- next_state <= FETCH_OP;

          --end if;

        when FETCH_OP =>
        next_state <= EXE_UAL;

        when EXE_UAL =>
        next_state <= FETCH_INST;      

        when STA =>
        next_state <= FETCH_INST;

        when EXE_JCC =>
        next_state <= FETCH_INST;

        when others =>
        next_state <= INIT;

      end case;
    end process;



      process (state, carry, op_code)
      begin
        case state is 

        when INIT =>
          init_cpt <= '1';
          init_acc <= '1';
          en_cpt   <= '0';
          load_cpt <= '0';
          sel_mux  <= '0';
          init_ff  <= '1';
          load_ff  <= '0';
          load_ri  <= '0';
          load_rd  <= '0';
          load_ra  <= '0';
          R_W      <= '0';
          en_mem   <= '0';
          sel_ual  <= (others => '0');

        when FETCH_INST =>
          en_cpt   <= '1';
          load_ri  <= '1';
          en_mem   <= '1';
          R_W      <= '0';

          init_cpt <= '0';
          init_acc <= '0';
          load_cpt <= '0';
          sel_mux  <= '0';
          init_ff  <= '0';
          load_ff  <= '0';
          load_rd  <= '0';
          load_ra  <= '0';
          sel_ual  <= (others => '0');     

        when DECODE =>
          sel_mux  <= '1';

          init_cpt <= '0';
          init_acc <= '0';
          en_cpt   <= '0';
          load_cpt <= '0';
          init_ff  <= '0';
          load_ff  <= '0';
          load_ri  <= '0';
          load_rd  <= '0';
          load_ra  <= '0';
          R_W      <= '0';
          en_mem   <= '0';
          sel_ual  <= (others => '0');

        when FETCH_OP =>
          sel_mux  <= '1';
          en_mem   <= '1';
          R_W      <= '0';
          load_rd  <= '1';

          init_cpt <= '0';
          init_acc <= '0';
          en_cpt   <= '0';
          load_cpt <= '0';
          init_ff  <= '0';
          load_ff  <= '0';
          load_ri  <= '0';
          load_ra  <= '0';
          sel_ual  <= (others => '0');

        when EXE_UAL =>
          sel_mux  <= '1';
          sel_ual  <= op_code;
          load_ra  <= '1';
          if op_code = OP_ADD
          or op_code = OP_SUB
          or op_code = OP_MUL 
          then
            load_ff  <= '1'; -- On enregistre l'éventuelle retenue

          else
            load_ff  <= '0';

          end if;

        init_cpt <= '0';
        init_acc <= '0';
        en_cpt   <= '0';
        load_cpt <= '0';
        init_ff  <= '0';
        load_ri  <= '0';
        load_rd  <= '0';
        R_W      <= '0';
        en_mem   <= '0';

      when STA =>
        sel_mux  <= '1';
        en_mem   <= '1';
        R_W      <= '1';

        init_cpt <= '0';
        init_acc <= '0';
        en_cpt   <= '0';
        load_cpt <= '0';
        init_ff  <= '0';
        load_ff  <= '0';
        load_ri  <= '0';
        load_rd  <= '0';
        load_ra  <= '0';
        sel_ual  <= (others => '0');

      when EXE_JCC =>
        sel_mux  <= '1';
        init_ff  <= carry;
        load_cpt <= not carry;
        load_ri  <= '1';

        init_cpt <= '0';
        init_acc <= '0';
        en_cpt   <= '0';
        load_ff  <= '0';
        load_rd  <= '0';
        load_ra  <= '0';
        R_W      <= '0';
        en_mem   <= '0';
        sel_ual  <= (others => '0');
    end case;
  end process;




  process(clk, reset) is
  begin
    if reset = '1' then
      state <= INIT;

    elsif rising_edge(clk) then
      if cpu_init = '1' then
        state <= INIT;

      else
        if clk_en = '1' then
        state <= next_state;

        end if;
      end if;
    end if;
  end process;

end architecture;