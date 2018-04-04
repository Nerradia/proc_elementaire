Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity UC is
    generic (
            op_code_size : integer := 2;  -- Largeur du signal des instructions
            sel_ual_size : integer := 1; -- Taille du sélectionneur d'opération de l'UAL
            data_size    : integer := 8;  -- Taille de chaque mot stocké
            address_size : integer := 6
        );
    port (
        reset    : in  std_logic;
        clk      : in  std_logic;
        clk_en   : in  std_logic;

        cpu_init : in  std_logic;

        data_in     : in  std_logic_vector(data_size-1 downto 0);
        address_out : out std_logic_vector(address_size-1 downto 0);


        -- Registres de la partie UT
        init_ff  : out std_logic;
        init_acc : out std_logic;
        load_ff  : out std_logic;
        load_rd  : out std_logic;
        load_ra  : out std_logic;

        -- UAL
        sel_ual  : out std_logic_vector (sel_ual_size-1 downto 0);
        carry    : in  std_logic;

        -- RAM
        en_mem   : out std_logic;
        R_W      : out std_logic
        );

end entity;

architecture rtl of UC is 

    component mux
        generic (
                size : integer := 6
            );
        port (
            sel : in std_logic;

            data_0   : in  std_logic_vector (size-1 downto 0);
            data_1   : in  std_logic_vector (size-1 downto 0);
            data_out : out std_logic_vector (size-1 downto 0)
            );
    end component;

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

    component fsm
        generic (
            op_code_size : integer := 2;  -- Largeur du signal des instructions
            sel_ual_size : integer := 1   -- Largeur du nombre d'instructions de l'UAL
        );
    port (
        reset    : in  std_logic;
        clk      : in  std_logic;
        clk_en   : in  std_logic;

        cpu_init : in  std_logic;

        -- Compteur 
        init_cpt : out std_logic;
        en_cpt   : out std_logic;
        load_cpt : out std_logic;

        -- mux
        sel_mux  : out std_logic;

        -- Registres (et la bascule FF)
        init_ff  : out std_logic;
        init_acc : out std_logic;
        load_ff  : out std_logic;
        load_ri  : out std_logic;
        load_rd  : out std_logic;
        load_ra  : out std_logic;

        -- UAL
        sel_ual  : out std_logic_vector (sel_ual_size-1 downto 0);
        carry    : in  std_logic;

        -- RAM
        en_mem   : out std_logic;
        R_W      : out std_logic;

        op_code  : in std_logic_vector(op_code_size-1 downto 0)
        );
    end component;

    component compteur is
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
    end component;


    signal load_ri      : std_logic;
    signal sel_mux      : std_logic;
    signal init_cpt     : std_logic;
    signal en_cpt       : std_logic;
    signal load_cpt     : std_logic;
    signal reg_inst_out : std_logic_vector(data_size-1 downto 0);
    signal cpt_to_mux   : std_logic_vector(address_size-1 downto 0);

begin

inst_fsm : fsm 
    generic map(
        op_code_size => op_code_size,
        sel_ual_size => sel_ual_size
        )
    port map(
        reset    => reset,
        clk      => clk,
        clk_en   => clk_en,

        -- RAZ synchrone du programmeur
        cpu_init => cpu_init,

        -- Compteur 
        init_cpt => init_cpt,
        en_cpt   => en_cpt,
        load_cpt => load_cpt,

        -- mux
        sel_mux  => sel_mux,

        -- Registres (et la bascule FF)
        init_ff  => init_ff,
        init_acc => init_acc,
        load_ff  => load_ff,
        load_ri  => load_ri,
        load_rd  => load_rd,
        load_ra  => load_ra,

        -- UAL
        sel_ual  => sel_ual,
        carry    => carry,

        -- RAM
        en_mem   => en_mem,
        R_W      => R_W,

        op_code  => reg_inst_out(data_size - 1 downto address_size)
    );


inst_reg_inst : reg
    generic map (
        size => data_size
        )
    port map (
        reset   => reset,
        clk     => clk,
        clk_en  => clk_en,

        load    => load_ri,
        init    => '0',

        data_in  => data_in,
        data_out => reg_inst_out
        );


inst_mux : mux
    generic map (
        size => address_size
        )
    port map (
        sel => sel_mux,

        data_0   => cpt_to_mux,
        data_1   => reg_inst_out(address_size -1 downto 0),
        data_out => address_out
        );


inst_compteur : compteur
    generic map (
        address_size => address_size
        )
    port map (
        reset   => reset,
        clk     => clk,
        clk_en  => clk_en,

        init_cpt => init_cpt,
        en_cpt   => en_cpt,
        load_cpt => load_cpt,

        cpt_in   => reg_inst_out(address_size -1 downto 0),
        cpt_out  => cpt_to_mux
        );

end architecture;
