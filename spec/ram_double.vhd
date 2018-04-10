Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT

entity ram_double is
  generic (
    data_size    : integer := 8;    -- Taille de chaque mot stocké
    address_size : integer := 6      -- Largeur de l'adresse du bus
  );
  port (
    clk                : in  std_logic;
    
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
end entity;

architecture rtl of ram_double is

  constant ram_address_size : integer := 12;

  component blk_mem_gen_1 is
    Port ( 
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 11 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 24 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 24 downto 0 );
    clkb : in STD_LOGIC;
    enb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 0 to 0 );
    addrb : in STD_LOGIC_VECTOR ( 11 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 24 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 24 downto 0 )
    );
  end component;

  component bus_periph_interface is
  generic (
    address_size  : integer := 6;  -- Largeur du signal d'adresses
    data_size     : integer := 8
  );
  port (
    en                 : in  std_logic;

    periph_data_in     : out std_logic_vector(data_size-1 downto 0);
    periph_data_out    : in  std_logic_vector(data_size-1 downto 0);

    bus_data_in        : out std_logic_vector(data_size-1 downto 0);
    bus_data_out       : in  std_logic_vector(data_size-1 downto 0);

    periph_address     : out std_logic_vector(address_size-1 downto 0);
    bus_address        : in  std_logic_vector(address_size-1 downto 0);

    periph_R_W         : out std_logic;
    bus_R_W            : in  std_logic;

    periph_en          : out std_logic;
    bus_en             : in  std_logic
    );
  end component;

  signal cpu_periph_data_in    : std_logic_vector(data_size-1 downto 0);
  signal cpu_periph_data_out   : std_logic_vector(data_size-1 downto 0);
  signal cpu_periph_address    : std_logic_vector(address_size-1 downto 0);
  signal cpu_periph_R_W        : std_logic;
  signal cpu_periph_en         : std_logic;

  signal gpu_periph_data_in    : std_logic_vector(data_size-1 downto 0);
  signal gpu_periph_data_out   : std_logic_vector(data_size-1 downto 0);
  signal gpu_periph_address    : std_logic_vector(address_size-1 downto 0);
  signal gpu_periph_R_W        : std_logic;
  signal gpu_periph_en         : std_logic;

begin

inst_cpu_bus_interface : bus_periph_interface
  generic map (
    address_size  => address_size,
    data_size     => data_size
  )
  port map (
    en                => cpu_en,

    periph_data_in    => cpu_periph_data_in,
    periph_data_out   => cpu_periph_data_out,

    bus_data_in       => cpu_bus_data_in,
    bus_data_out      => cpu_bus_data_out,

    periph_address    => cpu_periph_address,
    bus_address       => cpu_bus_address,

    bus_R_W           => cpu_bus_R_W,
    periph_R_W        => cpu_periph_R_W,

    bus_en            => cpu_bus_en,
    periph_en         => cpu_periph_en
    );

inst_gpu_bus_interface : bus_periph_interface
  generic map (
    address_size  => address_size,
    data_size     => data_size
  )
  port map (
    en                => gpu_en,

    periph_data_in    => gpu_periph_data_in,
    periph_data_out   => gpu_periph_data_out,

    bus_data_in       => gpu_bus_data_in,
    bus_data_out      => gpu_bus_data_out,

    periph_address    => gpu_periph_address,
    bus_address       => gpu_bus_address,

    bus_R_W           => gpu_bus_R_W,
    periph_R_W        => gpu_periph_R_W,

    bus_en            => gpu_bus_en,
    periph_en         => gpu_periph_en
    );

inst_ram_shr: blk_mem_gen_1
  port map ( 
    clka      => clk,
    ena       => cpu_en,
    wea(0)    => cpu_bus_R_W,
    addra     => cpu_periph_address (ram_address_size-1 downto 0),
    dina      => cpu_periph_data_in,
    douta     => cpu_periph_data_out,
    clkb      => clk,
    enb       => gpu_en,
    web(0)    => gpu_bus_R_W,
    addrb     => gpu_periph_address (ram_address_size-1 downto 0),
    dinb      => gpu_periph_data_in,
    doutb     => gpu_periph_data_out
  );

end architecture;