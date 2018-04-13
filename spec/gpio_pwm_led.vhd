Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT

entity gpio_pwm_led is
  generic (
    data_size    : integer
  );
  port (
    clk        : in  std_logic;
      
    value      : in  std_logic_vector(data_size-1 downto 0);
  
    led_out    : out std_logic
  );
end entity;

architecture rtl of gpio_pwm_led is
  constant top : integer := 255;
  signal cpt   : integer range 0 to top := 0;
begin
  process(clk) is
  begin
    if rising_edge(clk) then
      if cpt < top then
        cpt <= cpt + 1;

      else
        cpt <= 0;

      end if;

      if cpt > to_integer(unsigned(value)) then
        led_out <= '0';

      else 
        led_out <= '1';

      end if;
    end if;
  end process;

end architecture;