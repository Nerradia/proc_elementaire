Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity reg is
    generic (
            size : integer := 8
        );
    port (
        reset    : in  std_logic;
        clk      : in  std_logic;
        clk_en   : in  std_logic;

        load     : in  std_logic;
        init     : in  std_logic;

        data_in  : in  std_logic_vector (size-1 downto 0);
        data_out : out std_logic_vector (size-1 downto 0)
        );

end entity reg;

architecture rtl of reg is 

begin

    process(clk, reset) is
    begin
        if reset = '1' then
            data_out <= (others => '0');

        elsif rising_edge(clk) then
            if clk_en = '1' then

                if init = '1' then
                    data_out <= (others => '0');

                elsif load = '1' then
                    data_out <= data_in;

                end if;
            end if; 
        end if;
    end process;

end architecture rtl;