Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity vga is
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
    bus_R_W            : in  std_logic;
    bus_en             : in  std_logic;

    VGA_hs             : out std_logic;   -- horisontal vga syncr.
    VGA_vs             : out std_logic;   -- vertical vga syncr.
    VGA_red            : out std_logic_vector(3 downto 0);   -- red output
    VGA_green          : out std_logic_vector(3 downto 0);   -- green output
    VGA_blue           : out std_logic_vector(3 downto 0)   -- blue output
    );
end entity;

architecture rtl of vga is

  component VGA_bitmap_640x480 is
  generic(bit_per_pixel : integer range 1 to 12:=4;    -- number of bits per pixel
          grayscale     : boolean := true);           -- should data be displayed in grayscale
  port(clk          : in  std_logic;
       reset        : in  std_logic;
       VGA_hs       : out std_logic;   -- horisontal vga syncr.
       VGA_vs       : out std_logic;   -- vertical vga syncr.
       VGA_red      : out std_logic_vector(3 downto 0);   -- red output
       VGA_green    : out std_logic_vector(3 downto 0);   -- green output
       VGA_blue     : out std_logic_vector(3 downto 0);   -- blue output

       ADDR         : in  std_logic_vector(18 downto 0);
       data_in      : in  std_logic_vector(bit_per_pixel - 1 downto 0);
       data_write   : in  std_logic;
       data_out     : out std_logic_vector(bit_per_pixel - 1 downto 0)
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

signal periph_address  : std_logic_vector (address_size-1 downto 0);
signal periph_data_in  : std_logic_vector (data_size-1 downto 0);
signal periph_R_W      : std_logic;
signal periph_data_out : std_logic_vector (bit_per_pixel-1 downto 0);

begin

inst_vga_bitmap : VGA_bitmap_640x480
  generic map (
    bit_per_pixel => bit_per_pixel,    -- number of bits per pixel
    grayscale     => true
    )
  port map (
    clk          => clk,
    reset        => '0', -- reset synchrone, inutile ?
    VGA_hs       => VGA_hs,
    VGA_vs       => VGA_vs,
    VGA_red      => VGA_red,
    VGA_green    => VGA_green,
    VGA_blue     => VGA_blue,

    ADDR         => periph_address(18 downto 0),
    data_in      => periph_data_in(bit_per_pixel-1 downto 0),
    data_write   => periph_R_W and en,
    data_out     => periph_data_out
  );

inst_vga_bus_interface : bus_periph_interface
  generic map (
    address_size  => address_size,
    data_size     => data_size
  )
  port map (
    en                 => en,

    periph_data_in     => periph_data_in,
    periph_data_out    => (data_size-1 downto bit_per_pixel => '0') & periph_data_out,

    bus_data_in        => bus_data_in,
    bus_data_out       => bus_data_out,

    periph_address     => periph_address,
    bus_address        => bus_address,

    bus_R_W            => bus_R_W,
    periph_R_W         => periph_R_W,

    bus_en             => bus_en,
    periph_en          => open
    );

end architecture;
