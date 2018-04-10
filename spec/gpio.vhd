Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity gpio is
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
    sevenseg_an : out std_logic_vector (7 downto 0)
  );
end entity;

architecture rtl of gpio is

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

  component gpio_7seg is
    generic (
      data_size    : integer := 25
    );
    port (
      clk         : in  std_logic;
        
      value       : in std_logic_vector(data_size-1 downto 0);
    
      sevenseg    : out std_logic_vector (6 downto 0);
      sevenseg_an : out std_logic_vector (7 downto 0)
    );
  end component;

  signal periph_data_in    : std_logic_vector(data_size-1 downto 0);
  signal periph_data_out   : std_logic_vector(data_size-1 downto 0);
  signal periph_address    : std_logic_vector(address_size-1 downto 0);
  signal periph_R_W        : std_logic;
  signal periph_en         : std_logic;
  
  signal sevenseg_value    : std_logic_vector(data_size-1 downto 0);

begin

inst_bus_interface : bus_periph_interface
  generic map (
    address_size  => address_size,
    data_size     => data_size
  )
  port map (
    en                => gpio_en,

    periph_data_in    => periph_data_in,
    periph_data_out   => periph_data_out,

    bus_data_in       => bus_data_in,
    bus_data_out      => bus_data_out,

    periph_address    => periph_address,
    bus_address       => bus_address,

    periph_R_W        => periph_R_W,
    bus_R_W           => bus_R_W,

    periph_en         => periph_en,
    bus_en            => bus_en
    );


process (clk, reset) is 
begin
  if reset = '1' then
    sevenseg_value <= 25x"1ABCDEF";

  elsif rising_edge(clk) then
    if periph_en = '1' then
      sevenseg_value <= periph_data_in;
      -- sevenseg_value <= (20 downto 0 => periph_address, others => '0');
    end if;
  end if;
end process;

inst_gpio_7seg : gpio_7seg
  generic map (
    data_size    => data_size
  )
  port map (
    clk         => clk,
      
    value       => sevenseg_value,
  
    sevenseg    => sevenseg,
    sevenseg_an => sevenseg_an
  );

end architecture;

