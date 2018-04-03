Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity FSM is
    generic (
            op_code_size : integer := 2;  -- Largeur du signal des instructions
            sel_ual_size : integer := 1   -- Largeur du nombre d'instructions de l'UAL
        );
    port (
        reset    : in  std_logic;
        clk      : in  std_logic;
        clk_en   : in  std_logic;

        -- Compteur 
        init_cpt : out std_logic;
        en_cpt   : out std_logic;
        load_cpt : out std_logic;

        -- mux
        sel_mux  : out std_logic;

        -- Registres (et la bascule FF)
        init_ff  : out std_logic;
        load_ff  : out std_logic;
        load_ri  : out std_logic;
        load_rd  : out std_logic;
        load_ra  : out std_logic;

        -- UAL
        sel_ual  : out std_logic_vector (sel_ual_size-1 downto 0);
        carry    : in  std_logic;

        -- RAM
        en_mem   : out std_logic;
        R_W      : out std_logic;

        op_code  : in std_logic_vector(op_code_size-1 downto 0)
        );

end entity FSM;

architecture rtl of FSM is
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
            if op_code(1) = '0' then
                next_state <= FETCH_OP;

            elsif op_code = "10" then
                next_state <= STA;

            elsif op_code = "11" then
                next_state <= EXE_JCC;

            end if;

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
            init_cpt <= '0';
            en_cpt   <= '0';
            load_cpt <= '0';
            sel_mux  <= '0';
            init_ff  <= '0';
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
            en_cpt   <= '0';
            load_cpt <= '0';
            init_ff  <= '0';
            load_ff  <= '0';
            load_ri  <= '0';
            load_ra  <= '0';
            sel_ual  <= (others => '0');

        when EXE_UAL =>
            sel_mux  <= '1';
            sel_ual  <= op_code(0 downto 0);
            load_ra  <= '1';
            load_ff  <= op_code(0);

            init_cpt <= '0';
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
            if clk_en = '1' then
                state <= next_state;
                
            end if;
        end if;
    end process;

end architecture;