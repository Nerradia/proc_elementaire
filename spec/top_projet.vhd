Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT

entity top_projet is
    generic (
      op_code_size      : integer :=  5;    -- Largeur du signal des instructions
      data_size         : integer := 25;    -- Taille de chaque mot stocké
      address_size      : integer := 20;    -- Largeur de l'adresse
      clk_div           : integer := 868;  --437; -- diviseur de l'horloge du fpga pour le port série de la programmation, défaut à 115200 Bauds avec clk à 25 MHz
      ram_address_size  : integer := 13
    );                                -- Attention, op_code + address_size doivent valoir data_size !
    port (
      clk                  : in  STD_LOGIC;
      clk_en               : in  STD_LOGIC;
      reset                : in  STD_LOGIC;  

      -- Programmeur
      gpu_prog_btn         : in  std_logic;
      gpu_prog_status_led  : out std_logic;
      cpu_prog_btn         : in  std_logic;
      cpu_prog_status_led  : out std_logic;
      uart_rx              : in  std_logic;

   --   -- Affichage débogueur
   --   debug_cpu_gpu        : in  std_logic; -- Choix de l'afficage entre le CPU et le GPU
   --   addr                 : out STD_LOGIC_VECTOR (5 downto 0);
   --   data_mem_in          : out STD_LOGIC_VECTOR (7 downto 0);
   --   data_mem_out         : out STD_LOGIC_VECTOR (7 downto 0);

      -- Sortie VGA
      VGA_hs               : out std_logic;   -- horisontal vga syncr.
      VGA_vs               : out std_logic;   -- vertical vga syncr.
      VGA_red              : out std_logic_vector(3 downto 0);   -- red output
      VGA_green            : out std_logic_vector(3 downto 0);   -- green output
      VGA_blue             : out std_logic_vector(3 downto 0);   -- blue output

      -- Afficheur 8 x 7 segments
      sevenseg             : out std_logic_vector (6 downto 0);
      sevenseg_an          : out std_logic_vector (7 downto 0);

      switches             : in  std_logic_vector(15 downto 0);

      -- LEDs
      led_out     : out std_logic_vector(15 downto 0)
     );
end entity;


architecture rtl of top_projet is

  component top_CPU is
    generic (
      op_code_size : integer := 2;    -- Largeur du signal des instructions
      data_size    : integer := 8;    -- Taille de chaque mot stocké
      address_size : integer := 6     -- Largeur de l'adresse
      );                              -- Attention, op_code + address_size doivent valoir data_size !
    port (
      reset           : in  std_logic;
      clk             : in  std_logic;
      clk_en          : in  std_logic;

      -- reset synchrone qui vient du programmeur
      cpu_init        : in  std_logic;

      -- Sorties bus
      bus_en_mem      : out std_logic;
      bus_R_W         : out std_logic;
      bus_address     : out std_logic_vector (address_size-1 downto 0);
      bus_data_in     : in  std_logic_vector (data_size-1 downto 0);
      bus_data_out    : out std_logic_vector (data_size-1 downto 0)
      );
  end component;

  component top_prog is 
    generic (
      data_size         : integer;    -- Taille de chaque mot stocké
      address_size      : integer;    -- Largeur de l'adresse
      clk_div           : integer;    -- diviseur de l'horloge du fpga, défaut à 115200 Bauds avec clk à 100 MHz
      ram_address_size : integer
    );
    port (
      clk             : in  std_logic;
      reset           : in  std_logic;

      prog_btn        : in  std_logic;
      uart_rx         : in  std_logic;

      prog_status_led : out std_logic;
      cpu_init        : out std_logic;

      bus_en_mem      : out std_logic;
      bus_R_W         : out std_logic;
      bus_data_out    : out std_logic_vector (data_size-1 downto 0);
      bus_address     : out std_logic_vector (address_size-1 downto 0)
    );
  end component;

  -- Mémoire simple-port pour les CPUs
  component ram_simple is
  generic (
    data_size        : integer;
    address_size     : integer;
    ram_address_size : integer
  );
  port (
    clk                : in  std_logic;
    en                 : in  std_logic;
    bus_data_in        : out std_logic_vector(data_size-1 downto 0);
    bus_data_out       : in  std_logic_vector(data_size-1 downto 0);
    bus_address        : in  std_logic_vector(address_size-1 downto 0);
    bus_R_W            : in  std_logic;
    bus_en             : in  std_logic
  );
  end component;

  component gpio is
  generic (
    data_size    : integer := 8;    -- Taille de chaque mot stocké
    address_size : integer := 6      -- Largeur de l'adresse
  );
  port (
    clk                : in  std_logic;
    reset              : in  std_logic;
    
    -- Bus
    gpio_en            : in  std_logic;
    bus_data_in        : out std_logic_vector(data_size-1 downto 0);
    bus_data_out       : in  std_logic_vector(data_size-1 downto 0);
    bus_address        : in  std_logic_vector(address_size-1 downto 0);
    bus_R_W            : in  std_logic;
    bus_en             : in  std_logic;

    -- Afficheur 8 x 7 segments
    sevenseg    : out std_logic_vector (6 downto 0);
    sevenseg_an : out std_logic_vector (7 downto 0);

    -- Interrupteurs
    switches    : in  std_logic_vector (15 downto 0);

    -- LEDs
    led_out     : out std_logic_vector(15 downto 0)
    );
  end component;

  component sinus_table is
  generic (
    data_size         : integer;    -- Taille de chaque mot stocké
    address_size      : integer     -- Largeur de l'adresse
  );
  port (
    clk                : in  std_logic;
    
    cpu_en             : in  std_logic;
    cpu_bus_data_in    : out std_logic_vector(data_size-1 downto 0);
    cpu_bus_data_out   : in  std_logic_vector(data_size-1 downto 0);
    cpu_bus_address    : in  std_logic_vector(address_size-1 downto 0);
    cpu_bus_R_W        : in  std_logic;
    cpu_bus_en         : in  std_logic;

    gpu_en             : in  std_logic;
    gpu_bus_data_in    : out std_logic_vector(data_size-1 downto 0);
    gpu_bus_data_out   : in  std_logic_vector(data_size-1 downto 0);
    gpu_bus_address    : in  std_logic_vector(address_size-1 downto 0);
    gpu_bus_R_W        : in  std_logic;
    gpu_bus_en         : in  std_logic
  );
  end component;

  -- Gestionnaire de périphériques du CPU
  component cpu_periph_manager is
  generic (
    address_size : integer     -- Largeur de l'adresse
    );
  port (
    cpu_bus_address     : in std_logic_vector(address_size-1 downto 0);
    cpu_bus_en          : in std_logic;

    cpu_ram_en          : out std_logic;
    cpu_shr_ram_en      : out std_logic;
    cpu_sinus_table_en  : out std_logic;
    spi_en              : out std_logic;
    gpio_ctrl_en        : out std_logic
    );
  end component;

  -- Gestionnaire de périphériques du GPU
  component gpu_periph_manager is
  generic (
    address_size : integer     -- Largeur de l'adresse
    );
  port (
    gpu_bus_address     : in std_logic_vector(address_size-1 downto 0);
    gpu_bus_en          : in std_logic;

    gpu_ram_en          : out std_logic;
    gpu_shr_ram_en      : out std_logic;
    gpu_sinus_table_en  : out std_logic;
    vga_bitmap_en       : out std_logic
    );
  end component;


  -- Mémoire double-port pour l'interconnexion
  component ram_double is
    generic (
      data_size    : integer := 8;     -- Taille de chaque mot stocké
      address_size : integer := 6      -- Largeur de l'adresse de la RAM
    );
    port (
      clk                   : in  std_logic;
      
      cpu_en                 : in  std_logic;
      cpu_bus_data_in        : out std_logic_vector(data_size-1 downto 0);
      cpu_bus_data_out       : in  std_logic_vector(data_size-1 downto 0);
      cpu_bus_address        : in  std_logic_vector(address_size-1 downto 0);
      cpu_bus_R_W            : in  std_logic;
      cpu_bus_en             : in  std_logic;

      gpu_en                 : in  std_logic;
      gpu_bus_data_in        : out std_logic_vector(data_size-1 downto 0);
      gpu_bus_data_out       : in  std_logic_vector(data_size-1 downto 0);
      gpu_bus_address        : in  std_logic_vector(address_size-1 downto 0);
      gpu_bus_R_W            : in  std_logic;
      gpu_bus_en             : in  std_logic
    );
  end component;

  component vga is
  generic (
    data_size    : integer := 25;    -- Taille de chaque mot stocké
    address_size : integer := 20;    -- Largeur de l'adresse
    bit_per_pixel :integer :=  4     -- number of bits per pixel
  );
  port (
    clk                : in  std_logic;
    
    en                 : in  std_logic;
    bus_data_in        : out std_logic_vector(data_size-1 downto 0);
    bus_data_out       : in  std_logic_vector(data_size-1 downto 0);
    bus_address        : in  std_logic_vector(address_size-1 downto 0);
    bus_R_W            : in std_logic;
    bus_en             : in  std_logic;

    VGA_hs             : out std_logic;   -- horisontal vga syncr.
    VGA_vs             : out std_logic;   -- vertical vga syncr.
    VGA_red            : out std_logic_vector(3 downto 0);   -- red output
    VGA_green          : out std_logic_vector(3 downto 0);   -- green output
    VGA_blue           : out std_logic_vector(3 downto 0)   -- blue output
    );
  end component;

  /* Signaux du CPU */
  signal cpu_bus_en         : std_logic;
  signal cpu_bus_R_W        : std_logic;
  signal cpu_bus_address    : std_logic_vector (address_size-1 downto 0);
  signal cpu_bus_data_out   : std_logic_vector (data_size -1 downto 0);
  signal cpu_bus_data_in    : std_logic_vector (data_size -1 downto 0);
  signal cpu_init           : std_logic;

  signal cpu_ram_en         : std_logic;
  signal cpu_shr_ram_en     : std_logic;
  signal cpu_sinus_table_en : std_logic;
  --signal spi_en             : std_logic;
  signal gpio_en            : std_logic;

  /* Signaux du GPU */
  signal gpu_bus_en         : std_logic;
  signal gpu_bus_R_W        : std_logic;
  signal gpu_bus_address    : std_logic_vector (address_size-1 downto 0);
  signal gpu_bus_data_out   : std_logic_vector (data_size -1 downto 0);
  signal gpu_bus_data_in    : std_logic_vector (data_size -1 downto 0);
  signal gpu_init           : std_logic;

  signal gpu_ram_en         : std_logic;
  signal gpu_shr_ram_en     : std_logic;
  signal gpu_sinus_table_en : std_logic;
  signal gpu_vga_en         : std_logic;

begin



/*///////////-----------------------///////////
               INSTANCIATIONS CPU
--///////////-----------------------/////////// */
/* ---- Les maitres du bus CPU ---- */

 /* Le CPU */

inst_CPU : top_CPU
    generic map(
      op_code_size => op_code_size,
      data_size    => data_size,   
      address_size => address_size
    )
    port map(
      reset        => reset,
      clk          => clk,
      clk_en       => clk_en,

      cpu_init     => cpu_init, --cpu_rst,      -- reset synchrone qui vient du programmeur

      -- Bus
      bus_en_mem       => cpu_bus_en,
      bus_R_W          => cpu_bus_R_W,
      bus_address      => cpu_bus_address,
      bus_data_in      => cpu_bus_data_in,
      bus_data_out     => cpu_bus_data_out
    );    

 /* Le programmeur du CPU */

inst_top_prog_cpu : top_prog
    generic map (
      data_size         => data_size,
      address_size      => address_size,
      clk_div           => clk_div,
      ram_address_size => ram_address_size
    )
    port map (
      clk             => clk,
      reset           => reset,

      prog_btn        => cpu_prog_btn,
      uart_rx         => uart_rx,

      prog_status_led => cpu_prog_status_led,
      cpu_init        => cpu_init,

      bus_en_mem      => cpu_bus_en,
      bus_R_W         => cpu_bus_R_W,
      bus_data_out    => cpu_bus_data_out,
      bus_address     => cpu_bus_address
    );

/* ---- Les esclaves du bus CPU ---- */

/* Gestionnaire de périphériques */
inst_cpu_periph_manager : cpu_periph_manager
  generic map (
    address_size => address_size
    )
  port map (
    cpu_bus_address     => cpu_bus_address,
    cpu_bus_en          => cpu_bus_en,

    cpu_ram_en          => cpu_ram_en,
    cpu_shr_ram_en      => cpu_shr_ram_en,
    cpu_sinus_table_en  => cpu_sinus_table_en,
    spi_en              => open,
    gpio_ctrl_en        => gpio_en
    );

/* La RAM du CPU */

inst_ram_cpu : ram_simple
  generic map (
    data_size        => data_size,
    address_size     => address_size,
    ram_address_size => ram_address_size
  )
  port map ( 
    clk             => clk,
    en              => cpu_ram_en,         
    bus_data_in     => cpu_bus_data_in,
    bus_data_out    => cpu_bus_data_out,
    bus_address     => cpu_bus_address,
    bus_R_W         => cpu_bus_R_W,
    bus_en          => cpu_bus_en
  );   

/* Contrôleur GPIO */
 inst_gpio : gpio
  generic map (
    data_size    => data_size,
    address_size => address_size
  )
  port map (
    clk                => clk,
    reset              => reset,
    
    -- Bus
    gpio_en            => gpio_en,
    bus_data_in        => cpu_bus_data_in,
    bus_data_out       => cpu_bus_data_out,
    bus_address        => cpu_bus_address,
    bus_R_W            => cpu_bus_R_W,
    bus_en             => cpu_bus_en,

    -- Afficheur 8 x 7 segments
    sevenseg           => sevenseg,
    sevenseg_an        => sevenseg_an,

    switches           => switches,

    led_out            => led_out
    );


/*///////////-----------------------///////////
               INSTANCIATIONS GPU
--///////////-----------------------/////////// */

 /* Le GPU */

inst_GPU : top_CPU
    generic map(
      op_code_size => op_code_size,
      data_size    => data_size,   
      address_size => address_size
    )
    port map(
      reset        => reset,
      clk          => clk,
      clk_en       => clk_en,

      cpu_init     => gpu_init, --cpu_rst,      -- reset synchrone qui vient du programmeur

      -- Bus
      bus_en_mem       => gpu_bus_en,
      bus_R_W          => gpu_bus_R_W,
      bus_address      => gpu_bus_address,
      bus_data_in      => gpu_bus_data_in,
      bus_data_out     => gpu_bus_data_out
    );

 /* Le programmeur du GPU */

inst_top_prog_gpu : top_prog
    generic map (
      data_size         => data_size,
      address_size      => address_size,
      clk_div           => clk_div,
      ram_address_size => ram_address_size
    )
    port map (
      clk             => clk,
      reset           => reset,

      prog_btn        => gpu_prog_btn,
      uart_rx         => uart_rx,

      prog_status_led => gpu_prog_status_led,
      cpu_init        => gpu_init,

      bus_en_mem      => gpu_bus_en,
      bus_R_W         => gpu_bus_R_W,
      bus_data_out    => gpu_bus_data_out,
      bus_address     => gpu_bus_address
    );

/* Gestionnaire de périphériques */
inst_gpu_periph_manager : gpu_periph_manager
  generic map (
    address_size    => address_size
    )
  port map (
    gpu_bus_address     => gpu_bus_address,
    gpu_bus_en          => gpu_bus_en,

    gpu_ram_en          => gpu_ram_en,
    gpu_shr_ram_en      => gpu_shr_ram_en,
    gpu_sinus_table_en  => gpu_sinus_table_en,
    vga_bitmap_en       => gpu_vga_en
    );

/* La RAM du GPU */

inst_ram_gpu : ram_simple
  generic map (
    data_size        => data_size,
    address_size     => address_size,
    ram_address_size => ram_address_size
  )
  port map ( 
    clk             => clk,
    en              => gpu_ram_en,         
    bus_data_in     => gpu_bus_data_in,
    bus_data_out    => gpu_bus_data_out,
    bus_address     => gpu_bus_address,
    bus_R_W         => gpu_bus_R_W,
    bus_en          => gpu_bus_en
  );

  /* Périphérique VGA */
inst_vga : vga
  generic map (
    data_size         => data_size,
    address_size      => address_size,
    bit_per_pixel     => 4
  )
  port map (
    clk               => clk,
    
    en                => gpu_vga_en,
    bus_data_in       => gpu_bus_data_in,
    bus_data_out      => gpu_bus_data_out,
    bus_address       => gpu_bus_address,
    bus_R_W           => gpu_bus_R_W,
    bus_en            => gpu_bus_en,

    VGA_hs            => VGA_hs,
    VGA_vs            => VGA_vs,
    VGA_red           => VGA_red,
    VGA_green         => VGA_green,
    VGA_blue          => VGA_blue
    );


  /* RAM partagée entre le CPU et le GPU */

inst_ram_shr : ram_double
    generic map (
      data_size     => data_size,
      address_size  => address_size
    )
    port map (
      clk                 => clk, 
      
      cpu_en              => cpu_shr_ram_en, 
      cpu_bus_data_in     => cpu_bus_data_in, 
      cpu_bus_data_out    => cpu_bus_data_out, 
      cpu_bus_address     => cpu_bus_address, 
      cpu_bus_R_W         => cpu_bus_R_W, 
      cpu_bus_en          => cpu_bus_en, 

      gpu_en              => gpu_shr_ram_en, 
      gpu_bus_data_in     => gpu_bus_data_in, 
      gpu_bus_data_out    => gpu_bus_data_out, 
      gpu_bus_address     => gpu_bus_address, 
      gpu_bus_R_W         => gpu_bus_R_W, 
      gpu_bus_en          => gpu_bus_en
    );


/* Table des sinus */
inst_sinus_table : sinus_table
  generic map (
    data_size        => data_size,
    address_size     => address_size
  )
  port map ( 
    clk                 => clk, 

    cpu_en              => cpu_sinus_table_en, 
    cpu_bus_data_in     => cpu_bus_data_in, 
    cpu_bus_data_out    => cpu_bus_data_out, 
    cpu_bus_address     => cpu_bus_address, 
    cpu_bus_R_W         => cpu_bus_R_W, 
    cpu_bus_en          => cpu_bus_en, 

    gpu_en              => gpu_sinus_table_en, 
    gpu_bus_data_in     => gpu_bus_data_in, 
    gpu_bus_data_out    => gpu_bus_data_out, 
    gpu_bus_address     => gpu_bus_address, 
    gpu_bus_R_W         => gpu_bus_R_W, 
    gpu_bus_en          => gpu_bus_en
  );   

end rtl;