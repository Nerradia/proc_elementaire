Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT

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
    sel_mux  : out std_logic_vector(1 downto 0);

    -- Registres (et la bascule FF)
    init_ff  : out std_logic;
    init_acc : out std_logic;
    load_ff  : out std_logic;
    load_ri  : out std_logic;
    load_rd  : out std_logic;
    load_ra  : out std_logic;
    load_ad  : out std_logic;

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

  type STATES is (INIT, FETCH_INST, DECODE, FETCH_OP_STATIC, FETCH_OP_DYNAMIC, FETCH_ADDR, EXE_UAL, STA_STATIC, STA_DYNAMIC, EXE_JCC, EXE_JMP); 
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
          when "10000" => -- OP_STA
            next_state <= STA_STATIC;

          when "10001" => -- OP_JCC
            next_state <= EXE_JCC;

          when "10010" => -- OP_JMP
            next_state <= EXE_JMP;

          when "11000" => -- OP_GAD
            next_state <= FETCH_ADDR;

          when "11001" => -- OP_SAD
            next_state <= FETCH_ADDR;

          when others =>  -- Opérations arithmétiques et logiques, ainsi que le GET pour que la donnée passe par l'UAL pour aller dans ACCU
            next_state <= FETCH_OP_STATIC;

        end case;

      when FETCH_ADDR =>
        if op_code = "11000" then -- OP_GAD
          next_state <= FETCH_OP_DYNAMIC;
        else 
          next_state <= STA_DYNAMIC;
        end if;

      when FETCH_OP_STATIC =>
        next_state <= EXE_UAL;

      when FETCH_OP_DYNAMIC =>
        next_state <= EXE_UAL;

      when EXE_UAL =>
        next_state <= FETCH_INST;      

      when STA_STATIC =>
        next_state <= FETCH_INST;

      when STA_DYNAMIC =>
        next_state <= FETCH_INST;

      when EXE_JCC =>
        next_state <= FETCH_INST;

      when EXE_JMP =>
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
          sel_mux  <= "00";
          init_ff  <= '1';
          load_ad  <= '0';
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

          load_ad  <= '0';
          init_cpt <= '0';
          init_acc <= '0';
          load_cpt <= '0';
          sel_mux  <= "00";
          init_ff  <= '0';
          load_ff  <= '0';
          load_rd  <= '0';
          load_ra  <= '0';
          sel_ual  <= (others => '0');     

        when DECODE =>
          sel_mux  <= "01";

          load_ad  <= '0';
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

        when FETCH_ADDR =>
          sel_mux  <= "01";
          en_mem   <= '1';
          R_W      <= '0';
          load_ad  <= '1';

          load_rd  <= '0';
          init_cpt <= '0';
          init_acc <= '0';
          en_cpt   <= '0';
          load_cpt <= '0';
          init_ff  <= '0';
          load_ff  <= '0';
          load_ri  <= '0';
          load_ra  <= '0';
          sel_ual  <= (others => '0');

        when FETCH_OP_STATIC =>
          sel_mux  <= "01";
          en_mem   <= '1';
          R_W      <= '0';
          load_rd  <= '1';

          load_ad  <= '0';
          init_cpt <= '0';
          init_acc <= '0';
          en_cpt   <= '0';
          load_cpt <= '0';
          init_ff  <= '0';
          load_ff  <= '0';
          load_ri  <= '0';
          load_ra  <= '0';
          sel_ual  <= (others => '0');

        when FETCH_OP_DYNAMIC =>
          sel_mux  <= "10";
          en_mem   <= '1';
          R_W      <= '0';
          load_rd  <= '1';

          init_cpt <= '0';
          init_acc <= '0';
          en_cpt   <= '0';
          load_cpt <= '0';
          load_ad  <= '0';
          init_ff  <= '0';
          load_ff  <= '0';
          load_ri  <= '0';
          load_ra  <= '0';
          sel_ual  <= (others => '0');

        when EXE_UAL =>
          sel_mux  <= "01";
          sel_ual  <= op_code;
          load_ra  <= '1';
          if op_code = "00100" -- OP_ADD
          or op_code = "00101" -- OP_SUB
          or op_code = "00110" -- OP_DIV
          or op_code = "00111" -- OP_MUL
          or op_code = "10100" -- OP_FTOI
          or op_code = "10101" -- OP_ITOF
          or op_code = "10100" -- OP_TGT
          or op_code = "10101" -- OP_TLT
          or op_code = "10110" -- OP_TEQ
          then
            load_ff  <= '1'; 

          else
            load_ff  <= '0';

          end if;

        init_cpt <= '0';
        init_acc <= '0';
        en_cpt   <= '0';
        load_cpt <= '0';
        init_ff  <= '0';
        load_ad  <= '0';
        load_ri  <= '0';
        load_rd  <= '0';
        R_W      <= '0';
        en_mem   <= '0';

      when STA_STATIC =>
        sel_mux  <= "01";
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

      when STA_DYNAMIC =>
        sel_mux  <= "10";
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
        sel_mux  <= "01";
        init_ff  <= carry;
        load_cpt <= not carry;
        load_ri  <= '1';

        init_cpt <= '0';
        init_acc <= '0';
        en_cpt   <= '0';
        load_ad  <= '0';
        load_ff  <= '0';
        load_rd  <= '0';
        load_ra  <= '0';
        R_W      <= '0';
        en_mem   <= '0';
        sel_ual  <= (others => '0');

      when EXE_JMP =>
        sel_mux  <= "01";
        init_ff  <= '0';
        load_cpt <= '1';
        load_ri  <= '1';

        init_cpt <= '0';
        init_acc <= '0';
        en_cpt   <= '0';
        load_ad  <= '0';
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