Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity gpu_periph_manager is
  generic (
    address_size : integer     -- Largeur de l'adresse
    );
  port (
    gpu_bus_address : in std_logic_vector(address_size-1 downto 0);
    gpu_bus_en      : in std_logic;

    gpu_ram_en      : out std_logic;
    gpu_shr_ram_en  : out std_logic;
    vga_bitmap_en   : out std_logic
    );

end entity gpu_periph_manager;


architecture rtl of gpu_periph_manager is

begin

  process (gpu_bus_address, gpu_bus_en) is
  begin
    gpu_ram_en      <= '0';
    gpu_shr_ram_en  <= '0';
    vga_bitmap_en   <= '0';
    
    if gpu_bus_en = '1' then
      case to_integer(unsigned(gpu_bus_address)) is
        when 16#00000# to 16#01fff# => 
          gpu_ram_en   <= '1';

        when 16#02000# to 16#02fff# =>
          gpu_shr_ram_en <= '1';

        when 16#80000# to 16#cafff# =>
          vga_bitmap_en <= '1';

        when others =>

      end case;

    end if;

  end process;

end;