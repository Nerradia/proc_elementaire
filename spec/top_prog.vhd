Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity programmeur is 
  generic (
    data_size    : integer := 8;    -- Taille de chaque mot stocké
    address_size : integer := 6     -- Largeur de l'adresse
  );
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;

    prog_btn  : in  std_logic;
    uart_rx   : in  std_logic;

    prog_status_led : out std_logic;
    cpu_rst         : out std_logic;
    cpu_out_en      : out std_logic;

    en_mem          : out std_logic;
    R_W             : out std_logic;
    data_out        : out std_logic_vector (data_size-1 downto 0);
    addr            : out std_logic_vector (address_size-1 downto 0)
  );
end entity;

architecture rtl of programmeur is

  component prog_compteur is
    generic (
            address_size : integer := 6  -- Largeur du signal d'adresses
        );
    port (
        reset    : in  std_logic;
        clk      : in  std_logic;

        init_cpt : in  std_logic;
        en_cpt   : in  std_logic;

        cpt_out  : out std_logic_vector (address_size -1 downto 0)
        );

  end component prog_compteur;

  component uart_to_parallel is
    generic (
      data_size    : integer := 8;          -- Taille de chaque mot stocké dans la RAM
      clk_div      : integer := 868        -- diviseur de l'horloge du fpga, défaut à 115200 Bauds avec clk à 100 MHz
    );
    port (
      clk                 : in  std_logic;
      reset               : in  std_logic;
      uart_rx             : in  std_logic;
      uart_data_avail     : out std_logic;
      uart_data           : out std_logic_vector(data_size-1 downto 0)
    );
  end component;


  signal cpt_out          : std_logic_vector (address_size-1 downto 0);
  signal uart_data        : std_logic_vector (address_size-1 downto 0);
  signal uart_data_avail  : std_logic;
  signal cpt_rst          : std_logic;
  signal prog_out_en      : std_logic;

begin

inst_uart_to_parallel : uart_to_parallel is
  generic (
    data_size          => data_size,          -- Taille de chaque mot stocké dans la RAM
    clk_div            => clk_div         -- diviseur de l'horloge du fpga, défaut à 115200 Bauds avec clk à 100 MHz
  );
  port (
    clk                => clk, 
    reset              => reset, 
    uart_rx            => uart_rx, 
    uart_data_avail    => uart_data_avail, 
    uart_data          => uart_data 
  );

int_prog_compteur : prog_compteur is 
  generic map (

    )

// TODO : écrire la FSM, écrire le bloc bus_enable, modifier le CPU pour qu'il soit en "Z" tant qu'il est reset

end architecture;