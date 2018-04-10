Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity gpio_7seg is
  generic (
    data_size    : integer := 25
  );
  port (
    clk         : in  std_logic;
      
    value       : in std_logic_vector(data_size-1 downto 0);
  
    sevenseg    : out std_logic_vector (6 downto 0);
    sevenseg_an : out std_logic_vector (7 downto 0)
  );  
end entity;

architecture rtl of gpio_7seg is

  constant clk_div_top  : integer := 50000;
  signal   cpt_clk_gen  : integer range 0 to clk_div_top;

  signal val_digit : std_logic_vector(3 downto 0);
  signal n_digit   : integer range 0 to 7;

begin

clk_gen : process(clk) is 
  variable clk_en : std_logic;
  begin
    if rising_edge(clk) then
      if cpt_clk_gen = clk_div_top then
        cpt_clk_gen <= 0;
        clk_en      := '1';

      else
        cpt_clk_gen <= cpt_clk_gen + 1;
        clk_en      := '0';

      end if;

      if clk_en = '1' then
        if n_digit = 7 then
          n_digit <= 0;
        else 
          n_digit <= n_digit + 1;

        end if;
      end if;
    end if;
  end process clk_gen;

 /* Cathodes des segements */
with val_digit select
  sevenseg <= 
  "1000000" when x"0",
  "1111001" when x"1",
  "0100100" when x"2",
  "0110000" when x"3",
  "0011001" when x"4",
  "0010010" when x"5",
  "0000010" when x"6",
  "1111000" when x"7",
  "0000000" when x"8",
  "0010000" when x"9",
  "0001000" when x"A",
  "0000011" when x"B",
  "1000110" when x"C",
  "0100001" when x"D",
  "0000110" when x"E",
  "0001110" when x"F",
  "1111111" when others;

/* Anodes communes de chaque afficheur */
with n_digit select
  sevenseg_an  <= 
  "11111110" when 7,
  "11111101" when 6,
  "11111011" when 5,
  "11110111" when 4,
  "11101111" when 3,
  "11011111" when 2,
  "10111111" when 1,
  "01111111" when 0;

with n_digit select
  val_digit <=
    value (3  downto 0)  when 0,
    value (7  downto 4)  when 1,
    value (11 downto 8)  when 2,
    value (15 downto 12) when 3,
    value (19 downto 16) when 4,
    value (23 downto 20) when 5,
    "000" & value (24 downto 24) when 6, -- Pas très propre...
    "0000"               when 7;

end architecture;