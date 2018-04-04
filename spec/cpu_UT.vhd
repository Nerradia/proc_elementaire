Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity UT is
    generic (
            op_code_size : integer := 2; -- Largeur du signal des instructions
            sel_ual_size : integer := 1; -- Taille du sélectionneur d'opération de l'UAL
            data_size    : integer := 8  -- Taille de chaque mot stocké
        );
    port (
        reset    : in  std_logic;
        clk      : in  std_logic;
        clk_en   : in  std_logic;

        data_in  : in  std_logic_vector(data_size-1 downto 0);
        data_out : out std_logic_vector(data_size-1 downto 0);

        carry    : out std_logic;

        sel_ual  : in std_logic_vector(sel_ual_size-1 downto 0);

        load_ra  : in std_logic;
        load_ff  : in std_logic;
        load_rd  : in std_logic;
        init_ff  : in std_logic;
        init_acc : in std_logic
        );

end entity;

architecture rtl of UT is 

    component reg
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
    end component;

    component UAL 
        generic (
            data_size    : integer := 8;
            sel_ual_size : integer := 1
        );
    port (
        sel_ual   : in  std_logic_vector (sel_ual_size-1 downto 0);
        data_A    : in  std_logic_vector (data_size-1 downto 0);
        data_B    : in  std_logic_vector (data_size-1 downto 0);

        data_out  : out std_logic_vector (data_size-1 downto 0);
        carry     : out std_logic
        );
    end component;


    signal reg_data_to_UAL : std_logic_vector (data_size-1 downto 0);
    signal reg_accu_to_UAL : std_logic_vector (data_size-1 downto 0);
    signal UAL_out_to_accu : std_logic_vector (data_size-1 downto 0);
    signal UAL_carry_to_ff : std_logic;
    signal ff_input : std_logic_vector(0 downto 0);

begin

inst_UAL : UAL
    generic map(
         data_size    => data_size,
         sel_ual_size => sel_ual_size
    )
    port map(
        sel_ual  => sel_ual,
        data_A   => reg_data_to_UAL,
        data_B   => reg_accu_to_UAL,

        data_out => UAL_out_to_accu,
        carry    => UAL_carry_to_ff
    );


    ff_input(0) <= UAL_carry_to_ff;

inst_ff : reg
    generic map (
        size => 1
        )
    port map (
        reset   => reset,
        clk     => clk,
        clk_en  => clk_en,

        load    => load_ff,
        init    => init_ff,

        data_in  => ff_input,
        data_out(0) => carry
        );

inst_reg_accu : reg
    generic map (
        size => data_size
        )
    port map (
        reset   => reset,
        clk     => clk,
        clk_en  => clk_en,

        load    => load_ra,
        init    => init_acc,

        data_in  => UAL_out_to_accu,
        data_out => reg_accu_to_UAL
        );

    data_out <= reg_accu_to_UAL; -- To RAM

inst_reg_data : reg
    generic map (
        size => data_size
        )
    port map (
        reset   => reset,
        clk     => clk,
        clk_en  => clk_en,

        load    => load_rd,
        init    => '0',

        data_in  => data_in,
        data_out => reg_data_to_UAL
        );


end architecture;