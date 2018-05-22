Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT

entity mux is
    generic (
            size : integer
        );
    port (
        sel       : in std_logic_vector(1 downto 0);

        data_0    : in  std_logic_vector (size-1 downto 0);
        data_1    : in  std_logic_vector (size-1 downto 0);
        data_2    : in  std_logic_vector (size-1 downto 0);
        
        data_out  : out std_logic_vector (size-1 downto 0)
        );

end entity mux;

architecture rtl of mux is 

begin

    with sel select 
    data_out <= 
      data_0 when "00",
      data_1 when "01",
      data_2 when "10",
      data_0 when others;

end;