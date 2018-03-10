Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity UAL is
    generic (
            data_size     : integer := 8;
            sel_ual_size : integer := 1
        );
    port (
        sel_ual   : in  std_logic_vector (sel_ual_size-1 downto 0);
        data_A    : in  std_logic_vector (data_size-1 downto 0);
        data_B    : in  std_logic_vector (data_size-1 downto 0);

        data_out  : out std_logic_vector (data_size-1 downto 0);
        carry     : out std_logic
        );
 
end entity UAL;

architecture rtl of UAL is 

    signal data_out_with_carry : std_logic_vector(data_size downto 0);
begin

    process(data_A, data_B, sel_ual) is
    begin
        case to_integer(unsigned(sel_ual)) is

            when 0 => -- NOR
                data_out_with_carry <= "0" & (data_A nor data_B);

            when 1 =>
                data_out_with_carry <= std_logic_vector(signed("0" & data_A) + signed("0" & data_B));

            when others =>
                report "Unexpected sel_ual value" severity error;

        end case;
    end process;

    data_out <= data_out_with_carry(data_size-1 downto 0);
    carry    <= data_out_with_carry(data_size);

end architecture rtl;
