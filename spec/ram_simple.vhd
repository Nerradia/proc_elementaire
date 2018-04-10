Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity ram_simple is
  generic (
    data_size         : integer;    -- Taille de chaque mot stocké
    address_size      : integer;    -- Largeur de l'adresse
    ram_address_size  : integer
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
end entity;

architecture rtl of ram_simple is

  component blk_mem_gen_0 is
    Port ( 
      clka : in STD_LOGIC;
      ena : in STD_LOGIC;
      wea : in STD_LOGIC_VECTOR ( 0 to 0 );
      addra : in STD_LOGIC_VECTOR ( 12 downto 0 );
      dina : in STD_LOGIC_VECTOR ( 24 downto 0 );
      douta : out STD_LOGIC_VECTOR ( 24 downto 0 )
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

  signal periph_data_in    : std_logic_vector(data_size-1 downto 0);
  signal periph_data_out   : std_logic_vector(data_size-1 downto 0);
  signal periph_address    : std_logic_vector(address_size-1 downto 0);
  signal periph_R_W        : std_logic;
  signal periph_en         : std_logic;

begin

inst_bus_interface : bus_periph_interface
  generic map (
    address_size  => address_size,
    data_size     => data_size
  )
  port map (
    en                => en,

    periph_data_in    => periph_data_in,
    periph_data_out   => periph_data_out,

    bus_data_in       => bus_data_in,
    bus_data_out      => bus_data_out,

    periph_address    => periph_address,
    bus_address       => bus_address,

    bus_R_W           => bus_R_W,
    periph_R_W        => periph_R_W,

    bus_en            => bus_en,
    periph_en         => periph_en
    );

inst_ram_cpu : blk_mem_gen_0
  port map ( 
    clka     => clk,
    ena      => periph_en,
    wea      => (0 => periph_R_W),
    addra    => periph_address(ram_address_size-1 downto 0),
    dina     => periph_data_in,
    douta    => periph_data_out
  );

end architecture;