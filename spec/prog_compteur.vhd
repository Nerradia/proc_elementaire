Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity prog_compteur is
    generic (
            address_size : integer := 6  -- Largeur du signal d'adresses
        );
    port (
        reset       : in  std_logic;
        clk         : in  std_logic;

        init_cpt    : in  std_logic;
        cpt_count   : in  std_logic;

        cpt_out     : out std_logic_vector (address_size -1 downto 0)
        );

end entity prog_compteur;

architecture rtl of prog_compteur is 

    signal cpt : integer range 0 to 2**address_size-1;

begin

    process(clk, reset) is
    begin
        if reset = '1' then
            cpt <= 0;

        elsif rising_edge(clk) then
          if init_cpt = '1' then 
            cpt <= 0;
          
          elsif cpt_count = '1' then
            if cpt < 2**address_size-1 then
              cpt <= cpt + 1;

            end if; -- On s'arrête à la fin, normalement ce n'est pas censé aller plus loin

          end if;

        end if;
    end process;

    cpt_out <= std_logic_vector(to_unsigned(cpt, address_size));

end architecture;