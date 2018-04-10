Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT

entity bus_periph_interface is
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
end entity;

architecture rtl of bus_periph_interface is
begin

  -- Bus vers périphérique
  periph_data_in  <= bus_data_out;  -- when en = '1' else (others => '0');
  periph_address  <= bus_address;  -- when en = '1' else (others => '0');
  periph_R_W      <= bus_R_W   when en = '1' else '0';
  periph_en       <= bus_en    when en = '1' else '0';

  -- Périphérique vers bus
  bus_data_in     <= periph_data_out when en = '1' else (others => 'Z');

end;