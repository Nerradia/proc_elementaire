Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity RAM is
    generic (
            data_size    : integer := 8; -- Taille de chaque mot stocké
            address_size : integer := 6  -- Largeur du signal d'adresses
        );
    port (
        reset    : in  std_logic;
        clk      : in  std_logic;
        clk_en   : in  std_logic;

        R_W      : in  std_logic;
        address  : in  std_logic_vector (address_size -1 downto 0);

        data_in  : in  std_logic_vector (data_size -1 downto 0);
        data_out : out std_logic_vector (data_size -1 downto 0)
        );

end entity RAM;

architecture rtl of RAM is 

    type tableau_memoire is array (integer range <>) of std_logic_vector(data_size -1 downto 0);
    signal memoire : tableau_memoire(0 to 2**address_size-1);

begin

    process(clk, reset) is
    begin
        if reset = '1' then
            memoire <= (x"08", x"47", x"86", x"C4", x"C4", x"00", x"00", x"7E", x"FE", others => (others => '0'));
            data_out <= (others => '0');

        elsif falling_edge(clk) and clk_en = '1' then

            if R_W = '1' then
                memoire(to_integer(unsigned(address))) <= data_in;
                data_out <= (others => '0');

            else
                data_out <= memoire(to_integer(unsigned(address)));

            end if;
            
        end if;
    end process;

end architecture rtl;