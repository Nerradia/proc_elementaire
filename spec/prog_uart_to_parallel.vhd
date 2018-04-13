library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT
 
entity uart_to_parallel is
  generic (
    data_size    : integer := 8;    -- Taille de chaque mot stocké dans la RAM
    clk_div      : integer := 347        -- diviseur de l'horloge du fpga, défaut à 115200 Bauds avec clk à 100 MHz
  );
  port (
    clk                 : in  std_logic;
    reset               : in  std_logic;
    clear               : in  std_logic;
    uart_rx             : in  std_logic;
    uart_data_avail     : out std_logic;
    uart_data           : out std_logic_vector(data_size-1 downto 0)
  );
end uart_to_parallel;

architecture uart of uart_to_parallel is

  component uart_receiver is
    generic (
        clk_div : integer := 347
    );
    port (
      clk                 : in  std_logic;
      clear               : in  std_logic;
      uart_rx             : in  std_logic;
      uart_byte_avail     : out std_logic;
      uart_byte           : out std_logic_vector(7 downto 0)
    );
  end component;

  constant nb_bytes     : integer := 4; -- Nombre d'octets par mot dans la RAM, bloqué à 4 pour simplifier
  signal compteur       : integer range 0 to nb_bytes-1;
  signal coming_word    : std_logic_vector ((nb_bytes*8)-1 downto 0); -- Registre utilisé pour stocker les octets.

  signal uart_byte        : std_logic_vector(7 downto 0);
  signal uart_byte_avail  : std_logic;

begin

  process(clk, reset) is
  begin
    if reset = '1' then
      compteur <= 0;
      uart_data_avail <= '0'; 
    
    elsif rising_edge(clk) then

      if clear = '1' then
        compteur        <= 0;
        coming_word     <= (others => '0');

      else 
        if uart_byte_avail = '1' then
          if compteur < nb_bytes-1 then -- Le dernier octet d'un mot est arrivé
            compteur  <= compteur + 1;
            uart_data_avail <= '0';

          else 
            compteur        <= 0;
            uart_data_avail <= '1';

          end if;

          -- On enregistre l'octet qui vient d'arriver au bon endroit
          case compteur is 
            when 0 => 
              coming_word(7 downto 0) <= uart_byte;
            when 1 => 
              coming_word(15 downto 8) <= uart_byte;
            when 2 => 
              coming_word(23 downto 16) <= uart_byte;
            when 3 => 
              coming_word(31 downto 24) <= uart_byte;
          end case;

        else
          uart_data_avail <= '0'; 

        end if;
      end if;
    end if;
  end process;

-- On route vers la sortie les bits utiles
route_sortie : for i in 0 to data_size-1 generate
  uart_data(i) <= coming_word(i);
end generate;


inst_uart_rx : uart_receiver 
  generic map (
    clk_div => clk_div
  )
  port map (
    clk               => clk,
    clear             => clear,
    uart_rx           => uart_rx,
    uart_byte_avail   => uart_byte_avail,
    uart_byte         => uart_byte
  );


end architecture;