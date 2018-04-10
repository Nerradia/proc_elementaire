Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity cpu_periph_manager is
  generic (
    address_size : integer     -- Largeur de l'adresse
    );
  port (
    cpu_bus_address : in std_logic_vector(address_size-1 downto 0);
    cpu_bus_en      : in std_logic;

    cpu_ram_en      : out std_logic;
    cpu_shr_ram_en  : out std_logic;
    spi_en          : out std_logic;
    gpio_ctrl_en    : out std_logic
    );

end entity cpu_periph_manager;


architecture rtl of cpu_periph_manager is

begin

  process (cpu_bus_address, cpu_bus_en) is
  begin
    cpu_ram_en       <= '0';
    cpu_shr_ram_en   <= '0';
    spi_en           <= '0';
    gpio_ctrl_en     <= '0';
    
    if cpu_bus_en = '1' then
      case to_integer(unsigned(cpu_bus_address)) is
        when 16#00000# to 16#01fff# => 
          cpu_ram_en    <= '1';

        when 16#02000# to 16#02fff# =>
          cpu_shr_ram_en   <= '1';

        when 16#80000# =>
          spi_en       <= '1';

        when 16#80001# =>
          gpio_ctrl_en <= '1';

        when others =>
          
      end case;

    end if;

  end process;

end;