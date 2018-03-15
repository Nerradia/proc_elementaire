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
    signal memoire : tableau_memoire(0 to 2**address_size-1) :=
        (x"11", x"15", x"52", x"54",
         x"C9", x"94", x"51", x"CD",
         x"C0", x"13", x"52", x"95",
         x"C0", x"CD", x"00", x"00",
         x"00", x"FF", x"01", x"00",
         x"28", x"18",
         others => (others => '0')); --  PGCD du prof ;

    -- (x"08", x"47", x"86", x"C4", x"C4", x"00", x"00", x"7E", x"FE", others => (others => '0'));

begin

process(clk) is
    begin
    if falling_edge(clk) then
            if clk_en = '1' then

                if R_W = '1' then
                    memoire(to_integer(unsigned(address))) <= data_in;
                    data_out <= (others => '0');

                else
                    data_out <= memoire(to_integer(unsigned(address)));

                end if;
            end if;
        end if;
    end process;

end architecture rtl;