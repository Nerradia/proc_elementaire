Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity compteur is
    generic (
            address_size : integer := 6  -- Largeur du signal d'adresses
        );
    port (
        reset    : in  std_logic;
        clk      : in  std_logic;
        clk_en   : in  std_logic;

        init_cpt : in  std_logic;
        en_cpt   : in  std_logic;
        load_cpt : in  std_logic;

        cpt_in   : in  std_logic_vector (address_size -1 downto 0);
        cpt_out  : out std_logic_vector (address_size -1 downto 0)
        );

end entity compteur;

architecture rtl of compteur is 

    signal cpt : integer range 0 to 2**address_size-1;

begin

    process(clk, reset) is
    begin
        if reset = '1' then
            cpt <= 0;

        elsif rising_edge(clk) and clk_en = '1' then

            if init_cpt = '1' then 
                cpt <= 0;

            elsif load_cpt = '1' then
                cpt <= to_integer(unsigned(cpt_in));
            
            elsif en_cpt = '1' then
                if cpt < 2**address_size-1 then
                    cpt <= cpt + 1;
                
                else
                    cpt <= 0;

                end if;
            end if;
        end if;
    end process;

    cpt_out <= std_logic_vector(to_unsigned(cpt, address_size));

end architecture;