Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity prog_fsm is
    generic (
      address_size : integer := 6  -- Largeur du signal d'adresses
    );
    port (
      reset    : in  std_logic;
      clk      : in  std_logic;

      prog_btn      : in  std_logic;
      cpt_out       : in  std_logic_vector (address_size-1 downto 0);
      
      prog_status_led : out std_logic;
      clear           : out std_logic;
      cpu_init        : out std_logic;
      prog_out_en     : out std_logic
    );
end entity prog_fsm;

architecture rtl of prog_fsm is
    type STATES is (IDLE, PROGRAMMATION); 
    signal state      : STATES;
    signal next_state : STATES;

    signal prog_btn_r_r : std_logic := '0';
    signal prog_btn_r   : std_logic := '0';
begin

-- Pour éviter de planter la machine à états, on passe l'entrée par deux bascules
METASTAB : process (clk, reset) is
  begin

    if reset = '1' then
      prog_btn_r_r <= '0';
      prog_btn_r   <= '0';

    elsif rising_edge(clk) then

      prog_btn_r_r <= prog_btn_r;
      prog_btn_r   <= prog_btn;

    end if;
  end process METASTAB;


NEXTSTATE : process(state, cpt_out, prog_btn_r_r) is
  begin
    case state is 
    when IDLE => -- Programmeur en veille, on attend d'avoir l'ordre via le bouton
      if prog_btn_r_r = '1' then
        next_state <= PROGRAMMATION;
      end if;

    when PROGRAMMATION =>
      if cpt_out >= 2**address_size - 1 then
        next_state <= IDLE;
      end if;
      
    when others =>
      next_state <= IDLE;

    end case;
  end process;


  OUTPUTS : process(state) is
  begin
    case state is 
    when IDLE => -- Programmeur en veille, on attend d'avoir l'ordre via le bouton
      prog_status_led <= '0';
      clear           <= '1';
      cpu_init        <= '0';
      prog_out_en     <= '0';

    when PROGRAMMATION =>
      prog_status_led <= '1';
      clear           <= '0';
      cpu_init        <= '1';
      prog_out_en     <= '1';

    end case;
  end process;



  process(clk, reset) is
  begin
    if reset = '1' then
        state <= IDLE;

    elsif rising_edge(clk) then
      state <= next_state;

    end if;
  end process;

end architecture;