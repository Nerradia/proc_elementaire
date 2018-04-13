Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT

entity bus_interface is
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
end entity;

architecture trl of bus_interface is
begin

  bus_data_out  <= data_out   when en = '1' else (others => 'Z');
  bus_address   <= address    when en = '1' else (others => 'Z');
  bus_en_mem    <= en_mem     when en = '1' else 'Z';
  bus_R_W       <= R_W        when en = '1' else 'Z';

  data_in       <= bus_data_in;

end;