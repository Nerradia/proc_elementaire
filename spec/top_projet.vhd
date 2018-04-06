Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity top_projet is
    generic (
      op_code_size : integer := 2;    -- Largeur du signal des instructions
      sel_ual_size : integer := 1;    -- Taille du sélectionneur d'opération de l'UAL
      data_size    : integer := 8;    -- Taille de chaque mot stocké
      address_size : integer := 6;     -- Largeur de l'adresse
      clk_div      : integer := 347    -- diviseur de l'horloge du fpga pour le port série de la programmation, défaut à 115200 Bauds avec clk à 25 MHz
    );                                -- Attention, op_code + address_size doivent valoir data_size !
    port (
      clk             : in  STD_LOGIC;
      clk_en          : in  STD_LOGIC;
      reset           : in  STD_LOGIC;  

      -- Programmeur
      prog_btn         : in  std_logic;
      uart_rx          : in  std_logic;
      prog_status_led  : out std_logic;

      addr            : out  STD_LOGIC_VECTOR (5 downto 0);
      data_mem_in     : out  STD_LOGIC_VECTOR (7 downto 0);
      data_mem_out    : out  STD_LOGIC_VECTOR (7 downto 0);
    led_debug  : out std_logic
     );
end entity;


architecture rtl of top_projet is

  component top_CPU is
    generic (
      op_code_size : integer := 2;    -- Largeur du signal des instructions
      sel_ual_size : integer := 1;    -- Taille du sélectionneur d'opération de l'UAL
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

/*
  component RAM is
    generic (
      data_size    : integer := 8; -- Taille de chaque mot stocké
      address_size : integer := 6  -- Largeur du signal d'adresses
      );
    port (
      clk      : in  std_logic;
      clk_en   : in  std_logic;

      R_W      : in  std_logic;
      address  : in  std_logic_vector (address_size -1 downto 0);
      data_in  : in  std_logic_vector (data_size -1 downto 0);
      data_out : out std_logic_vector (data_size -1 downto 0)
      );
  end component;
*/

  component top_prog is 
    generic (
      data_size    : integer := 8;    -- Taille de chaque mot stocké
      address_size : integer := 6;     -- Largeur de l'adresse
      clk_div      : integer := 347        -- diviseur de l'horloge du fpga, défaut à 115200 Bauds avec clk à 100 MHz
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
      bus_address     : out std_logic_vector (address_size-1 downto 0);

      led_debug  : out std_logic
    );
  end component;


  component blk_mem_gen_0 is
    Port ( 
      clka      : in STD_LOGIC;
      ena       : in STD_LOGIC;
      wea       : in STD_LOGIC_VECTOR ( 0 to 0 );
      addra     : in STD_LOGIC_VECTOR ( 5 downto 0 );
      dina      : in STD_LOGIC_VECTOR ( 7 downto 0 );
      douta     : out STD_LOGIC_VECTOR ( 7 downto 0 )
    );
  end component;


  signal cpu_bus_en_mem     : std_logic;
  signal cpu_bus_R_W        : std_logic;
  signal cpu_bus_address    : std_logic_vector (address_size-1 downto 0);
  signal cpu_bus_data_out   : std_logic_vector (data_size -1 downto 0);
  signal cpu_bus_data_in    : std_logic_vector (data_size -1 downto 0);
  signal cpu_init           : std_logic;

begin

/*
inst_RAM : RAM
    generic map(
        data_size    => data_size,
        address_size => address_size
    )
    port map(
      clk      => clk,

      -- Bus
      clk_en   => cpu_bus_en_mem,
      R_W      => cpu_bus_R_W,
      address  => cpu_bus_address,
      data_in  => cpu_bus_data_out,  -- Ici on croise les signaux, (data out du bus = sortie du maitre, donc entrée de la RAM)
      data_out => cpu_bus_data_in
    );*/

int_ram_cpu : blk_mem_gen_0
  port map ( 
    clka     => clk,
    ena      => cpu_bus_en_mem,
    wea      => (0 => cpu_bus_R_W),
    addra    => cpu_bus_address,
    dina     => cpu_bus_data_out,
    douta    => cpu_bus_data_in
  );

inst_CPU : top_CPU
    generic map(
      op_code_size => op_code_size,
      sel_ual_size => sel_ual_size,
      data_size    => data_size,   
      address_size => address_size
    )
    port map(
      reset        => reset,
      clk          => clk,
      clk_en       => clk_en,

      cpu_init     => cpu_init, --cpu_rst,      -- reset synchrone qui vient du programmeur

      -- Bus
      bus_en_mem       => cpu_bus_en_mem,
      bus_R_W          => cpu_bus_R_W,
      bus_address      => cpu_bus_address,
      bus_data_in      => cpu_bus_data_in,
      bus_data_out     => cpu_bus_data_out
    );

inst_top_prog_cpu : top_prog
    generic map (
      data_size    => data_size,
      address_size => address_size,
      clk_div      => clk_div
    )
    port map (
      clk             => clk,
      reset           => reset,

      prog_btn        => prog_btn,
      uart_rx         => uart_rx,

      prog_status_led => prog_status_led,
      cpu_init        => cpu_init,

      bus_en_mem      => cpu_bus_en_mem,
      bus_R_W         => cpu_bus_R_W,
      bus_data_out    => cpu_bus_data_out,
      bus_address     => cpu_bus_address
    );


  addr         <= cpu_bus_address;
  data_mem_in  <= cpu_bus_data_out;
  data_mem_out <= cpu_bus_data_in;

end rtl;