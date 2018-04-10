Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity top_prog is 
  generic (
    data_size    : integer;    -- Taille de chaque mot stocké
    address_size : integer;     -- Largeur de l'adresse
    clk_div      : integer;        -- diviseur de l'horloge du fpga, défaut à 115200 Bauds avec clk à 100 MHz
    ram_address_size : integer
  );
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;

    prog_btn  : in  std_logic;
    uart_rx   : in  std_logic;

    prog_status_led : out std_logic;
    cpu_init        : out std_logic;

    bus_en_mem      : out std_logic;
    bus_R_W         : out std_logic;
    bus_data_out    : out std_logic_vector (data_size-1 downto 0);
    bus_address     : out std_logic_vector (address_size-1 downto 0)
  );
end entity top_prog;

architecture rtl of top_prog is

  component uart_to_parallel is
    generic (
      data_size    : integer := 8;          -- Taille de chaque mot stocké dans la RAM
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
  end component;

  component prog_fsm is
    generic (
      ram_address_size : integer := 6  -- Largeur du signal d'adresses
      );
    port (
      reset    : in  std_logic;
      clk      : in  std_logic;

      prog_btn : in  std_logic;
      cpt_out  : in  std_logic_vector (ram_address_size -1 downto 0);
      
      prog_status_led : out std_logic;
      clear           : out std_logic;
      cpu_init        : out std_logic;
      prog_out_en     : out std_logic
    );
  end component prog_fsm;

  component prog_compteur is
    generic (
      ram_address_size : integer := 6  -- Largeur du signal d'adresses
      );
    port (
        clk         : in  std_logic;

        init_cpt    : in  std_logic;
        cpt_count   : in  std_logic;

        cpt_out     : out std_logic_vector (ram_address_size -1 downto 0)
        );
    end component;

  component bus_interface is
    generic (
      address_size  : integer := 6;  -- Largeur du signal d'adresses
      data_size     : integer := 8
    );
    port (
      en            : in  std_logic;

      data_out      : in  std_logic_vector(data_size-1 downto 0);
      bus_data_out  : out std_logic_vector(data_size-1 downto 0);

      data_in       : out std_logic_vector(data_size-1 downto 0);
      bus_data_in   : in  std_logic_vector(data_size-1 downto 0);

      address       : in  std_logic_vector(address_size-1 downto 0);
      bus_address   : out std_logic_vector(address_size-1 downto 0);

      bus_R_W       : out std_logic;
      R_W           : in  std_logic;

      bus_en_mem    : out std_logic;
      en_mem        : in  std_logic
      );
  end component;


  signal cpt_out          : std_logic_vector (ram_address_size-1 downto 0);
  signal uart_data        : std_logic_vector (data_size-1 downto 0);
  signal uart_data_avail  : std_logic;
  signal clear            : std_logic;
  signal prog_out_en      : std_logic;

begin

inst_uart_to_parallel : uart_to_parallel
  generic map (
    data_size          => data_size,          -- Taille de chaque mot stocké dans la RAM
    clk_div            => clk_div             -- diviseur de l'horloge du fpga, défaut à 115200 Bauds avec clk à 100 MHz
  )
  port map (
    clk                => clk, 
    reset              => reset, 
    uart_rx            => uart_rx,
    clear              => clear, 
    uart_data_avail    => uart_data_avail, 
    uart_data          => uart_data 
  );

inst_prog_compteur : prog_compteur
  generic map (
    ram_address_size => ram_address_size
    )
  port map (  
    clk        => clk,      
    init_cpt   => clear, 
    cpt_count  => uart_data_avail,   
    cpt_out    => cpt_out  
    );

inst_prog_fsm : prog_fsm
    generic map (
      ram_address_size => ram_address_size
    )
    port map (
      reset    => reset, 
      clk      => clk,   

      prog_btn => prog_btn,
      cpt_out  => cpt_out,
      
      prog_status_led => prog_status_led,
      clear           => clear,
      cpu_init        => cpu_init,
      prog_out_en     => prog_out_en
    );

inst_bus_interface : bus_interface
    generic map (
      address_size => address_size, 
      data_size    => data_size    
    )
    port map (
      en           => prog_out_en,           

      data_out     => uart_data,     
      bus_data_out => bus_data_out, 

      data_in      => open,      
      bus_data_in  => (others => '0'),  

      address      => (address_size-1 downto ram_address_size => '0') & cpt_out,      
      bus_address  => bus_address,

      bus_R_W      => bus_R_W,
      R_W          => uart_data_avail,

      bus_en_mem   => bus_en_mem,
      en_mem       => uart_data_avail
      );

end architecture;