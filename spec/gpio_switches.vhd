Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT

entity gpio_switches is
  generic (
    data_size    : integer
  );
  port (
    clk         : in  std_logic;
      
    value       : out std_logic_vector(data_size-1 downto 0);
  
    switches    : in  std_logic_vector(15 downto 0)
  );  
end entity;

architecture rtl of gpio_switches is

  signal switches_r  : std_logic_vector(15 downto 0);
  signal switches_rr : std_logic_vector(15 downto 0);

begin

  process (clk) is
  begin
    if rising_edge(clk) then

      switches_r  <= switches;
      switches_rr <= switches_r;
      value <= (data_size-1 downto 16 => '0') & switches_rr;

    end if;

  end process;

end architecture;