Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT

entity top_CPU is
    generic (
        op_code_size : integer := 2;    -- Largeur du signal des instructions
        data_size    : integer := 8;    -- Taille de chaque mot stocké
        address_size : integer := 6     -- Largeur de l'adresse
        );                              -- Attention, op_code + address_size doivent valoir data_size !
    port (
        reset           : in  std_logic;
        clk             : in  std_logic;
        clk_en          : in  std_logic;

        -- reset synchrone qui vient du programmeur
        cpu_init        : in  std_logic;

        -- Sorties bus
        bus_en_mem          : out std_logic;
        bus_R_W             : out std_logic;
        bus_address         : out std_logic_vector (address_size-1 downto 0);
        bus_data_in         : in  std_logic_vector (data_size-1 downto 0);
        bus_data_out        : out std_logic_vector (data_size-1 downto 0)
        );

end entity;


architecture rtl of top_CPU is

    component UT is
    generic (
        op_code_size : integer; -- Largeur du signal des instructions
        data_size    : integer  -- Taille de chaque mot stocké
        );
    port (
        reset    : in  std_logic;
        clk      : in  std_logic;
        clk_en   : in  std_logic;

        data_in  : in  std_logic_vector(data_size-1 downto 0);
        data_out : out std_logic_vector(data_size-1 downto 0);

        carry    : out std_logic;

        sel_ual  : in std_logic_vector(op_code_size-1 downto 0);

        load_ra  : in std_logic;
        load_ff  : in std_logic;
        load_rd  : in std_logic;
        init_ff  : in std_logic;
        init_acc : in std_logic
        );

    end component;

    component UC is
    generic (
        op_code_size : integer;  -- Largeur du signal des instructions
        data_size    : integer;  -- Taille de chaque mot stocké
        address_size : integer
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
      sel_ual  : out std_logic_vector (op_code_size-1 downto 0);
      carry    : in  std_logic;

      -- RAM
      en_mem   : out std_logic;
      R_W      : out std_logic
      );

    end component;


  component bus_interface is
    generic (
      address_size  : integer := 6;  -- Largeur du signal d'adresses
      data_size     : integer := 8
    );
    port (
      en            : in  std_logic;

      data_out      : in  std_logic_vector(data_size-1 downto 0);
      bus_data_out  : out std_logic_vector(data_size-1 downto 0);

      data_in       : out std_logic_vector(data_size-1 downto 0);
      bus_data_in   : in  std_logic_vector(data_size-1 downto 0);

      address       : in  std_logic_vector(address_size-1 downto 0);
      bus_address   : out std_logic_vector(address_size-1 downto 0);

      bus_R_W       : out std_logic;
      R_W           : in  std_logic;

      bus_en_mem    : out std_logic;
      en_mem        : in  std_logic
      );
  end component;

  --signal address      : std_logic_vector(address_size-1 downto 0);
  signal data_RAM_out : std_logic_vector(data_size-1 downto 0);
  signal data_RAM_in  : std_logic_vector(data_size-1 downto 0);

  -- Registres de la partie UT
  signal init_ff      : std_logic;
  signal init_acc     : std_logic;
  signal load_ff      : std_logic;
  signal load_rd      : std_logic;
  signal load_ra      : std_logic;

  -- UAL
  signal sel_ual      : std_logic_vector (op_code_size-1 downto 0);
  signal carry        : std_logic;

  signal en_mem       : std_logic;
  signal R_W          : std_logic;
  signal address      : std_logic_vector (address_size-1 downto 0);
  signal data_in      : std_logic_vector (data_size-1 downto 0);
  signal data_out     : std_logic_vector (data_size-1 downto 0);

begin


inst_ut : UT
  generic map(
    op_code_size => op_code_size,
    data_size    => data_size
    )
  port map(
    reset    => reset,
    clk      => clk,
    clk_en   => clk_en,

    data_in  => data_in,
    data_out => data_out,

    carry    => carry,

    sel_ual  => sel_ual,

    load_ra  => load_ra,
    load_ff  => load_ff,
    load_rd  => load_rd,
    init_ff  => init_ff,
    init_acc => init_acc
    );

inst_uc :  UC
  generic map(
    op_code_size => op_code_size,
    data_size    => data_size,
    address_size => address_size
    )
  port map(
    reset    => reset,
    clk      => clk,
    clk_en   => clk_en,

    cpu_init => cpu_init,

    data_in     => data_in,
    address_out => address,

    -- Registres de la partie UT
    init_ff  => init_ff,
    init_acc => init_acc,
    load_ff  => load_ff,
    load_rd  => load_rd,
    load_ra  => load_ra,

    -- UAL
    sel_ual  => sel_ual,
    carry    => carry,

    -- RAM
    en_mem   => en_mem,
    R_W      => R_W
    );

inst_bus_interface : bus_interface
  generic map (
    address_size => address_size, 
    data_size    => data_size    
  )
  port map (
    en           => not(cpu_init),           

    data_out     => data_out,
    bus_data_out => bus_data_out,

    data_in      => data_in,
    bus_data_in  => bus_data_in,

    address      => address,
    bus_address  => bus_address,

    bus_R_W      => bus_R_W,
    R_W          => R_W,

    bus_en_mem   => bus_en_mem,
    en_mem       => en_mem
    );



end architecture;