Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity top_projet is
    generic (
      op_code_size : integer := 2;    -- Largeur du signal des instructions
      sel_ual_size : integer := 1;    -- Taille du sélectionneur d'opération de l'UAL
      data_size    : integer := 8;    -- Taille de chaque mot stocké
      address_size : integer := 6     -- Largeur de l'adresse
    );                                -- Attention, op_code + address_size doivent valoir data_size !
    port (
      clk             : in  STD_LOGIC;
      clk_en          : in  STD_LOGIC;
      reset           : in  STD_LOGIC;  

      addr            : out  STD_LOGIC_VECTOR (5 downto 0);
      data_mem_in     : out  STD_LOGIC_VECTOR (7 downto 0);
      data_mem_out    : out  STD_LOGIC_VECTOR (7 downto 0)
     );
end entity;


architecture rtl of top_projet is

  component top_CPU is
    generic (
      op_code_size  : integer; 
      sel_ual_size  : integer; 
      data_size     : integer; 
      address_size  : integer
    );           
    port (
      reset           : in  std_logic;
      clk             : in  std_logic;
      clk_en          : in  std_logic;

      cpu_rst         : in  std_logic;  -- reset synchrone qui vient du programmeur
      cpu_out_en      : in  std_logic;  -- désactivation des sorties pour laisser le programmeur écrire

      en_mem          : out std_logic;
      R_W             : out std_logic;
      address         : out std_logic_vector (address_size-1 downto 0);
      data_in         : in  std_logic_vector (data_size-1 downto 0);
      data_out        : out std_logic_vector (data_size-1 downto 0)
    );

  end component;

  component RAM is
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
  end component;

  signal bus_clk_enable : std_logic;
  signal bus_R_W        : std_logic;
  signal bus_address    : std_logic_vector (address_size-1 downto 0);
  signal bus_data_out   : std_logic_vector (data_size -1 downto 0);
  signal bus_data_in    : std_logic_vector (data_size -1 downto 0);

begin

inst_RAM : RAM
    generic map(
        data_size    => data_size,
        address_size => address_size
    )
    port map(
      clk      => clk,

      -- Bus
      clk_en   => bus_clk_enable,
      R_W      => bus_R_W,
      address  => bus_address,
      data_in  => bus_data_out,  -- Ici on croise les signaux, (data out du bus = sortie du maitre, donc entrée de la RAM)
      data_out => bus_data_in
    );

inst_CPU : top_CPU
    generic map(
      op_code_size => op_code_size,
      sel_ual_size => sel_ual_size,
      data_size    => data_size,   
      address_size => address_size
    )
    port map(
      reset        => reset,
      clk          => clk,
      clk_en       => clk_en,

      cpu_rst      => '0', --cpu_rst,      -- reset synchrone qui vient 
      cpu_out_en   => '0', --cpu_out_en,   -- désactivation des sorties 

      -- Bus
      en_mem       => bus_clk_enable,
      R_W          => bus_R_W,
      address      => bus_address,
      data_in      => bus_data_in,
      data_out     => bus_data_out
    );


  addr         <= bus_address;
  data_mem_in  <= bus_data_out;
  data_mem_out <= bus_data_in;

end rtl;