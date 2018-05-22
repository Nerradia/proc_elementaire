Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT

entity sinus_table is
  generic (
    data_size         : integer;    -- Taille de chaque mot stocké
    address_size      : integer    -- Largeur de l'adresse
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

architecture rtl of sinus_table is

  component rom_sin is
    Port ( 
      clka  : in STD_LOGIC;
      ena   : in STD_LOGIC;
      addra : in STD_LOGIC_VECTOR ( 8 downto 0 );
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

inst_rom_sin : rom_sin
  port map ( 
    clka     => clk,
    ena      => periph_en,
    addra    => periph_address(8 downto 0),
    douta    => periph_data_out
  );

end architecture;