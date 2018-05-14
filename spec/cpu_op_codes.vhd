Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

 -- Main Author : Julien BESSE
 -- With the kind collaboration of : Pierre JOUBERT

package op_codes is

  constant op_code_size : integer := 5;
  -- Instructions logiques
  constant OP_NOR  : std_logic_vector (op_code_size-1 downto 0) := "00000";
  constant OP_OR   : std_logic_vector (op_code_size-1 downto 0) := "00001";
  constant OP_AND  : std_logic_vector (op_code_size-1 downto 0) := "00010";
  constant OP_XOR  : std_logic_vector (op_code_size-1 downto 0) := "00011";
  
  -- Instructions mathématiques sur entiers
  constant OP_ADD  : std_logic_vector (op_code_size-1 downto 0) := "00100";
  constant OP_SUB  : std_logic_vector (op_code_size-1 downto 0) := "00101";
  constant OP_DIV  : std_logic_vector (op_code_size-1 downto 0) := "00110";
  constant OP_MUL  : std_logic_vector (op_code_size-1 downto 0) := "00111";
  constant OP_MOD  : std_logic_vector (op_code_size-1 downto 0) := "01000";

  -- Instructions mathématiques sur flottants
  constant OP_ADDF : std_logic_vector (op_code_size-1 downto 0) := "01001";
  constant OP_DIVF : std_logic_vector (op_code_size-1 downto 0) := "01010";
  constant OP_MULF : std_logic_vector (op_code_size-1 downto 0) := "01011";

  -- Conversions flottants/entiers
  constant OP_FTOI : std_logic_vector (op_code_size-1 downto 0) := "01100";
  constant OP_ITOF : std_logic_vector (op_code_size-1 downto 0) := "01101";

  -- Opérations mémoire
  constant OP_STA  : std_logic_vector (op_code_size-1 downto 0) := "10000";
  constant OP_JCC  : std_logic_vector (op_code_size-1 downto 0) := "10001";
  constant OP_JMP  : std_logic_vector (op_code_size-1 downto 0) := "10010";
  constant OP_GET  : std_logic_vector (op_code_size-1 downto 0) := "10011";

  -- Tests sur les entiers
  constant OP_TGT  : std_logic_vector (op_code_size-1 downto 0) := "10100";
  constant OP_TLT  : std_logic_vector (op_code_size-1 downto 0) := "10101";
  constant OP_TEQ  : std_logic_vector (op_code_size-1 downto 0) := "10110";

  -- Tests sur les flottants
  constant OP_TGTF : std_logic_vector (op_code_size-1 downto 0) := "10111";
  constant OP_TLTF : std_logic_vector (op_code_size-1 downto 0) := "11000";
  constant OP_TEQF : std_logic_vector (op_code_size-1 downto 0) := "11001";

  -- Pour le GPU : stocker les coordonnées
  --constant OP_STX  : std_logic_vector (op_code_size-1 downto 0) := "11001";
  --constant OP_STY  : std_logic_vector (op_code_size-1 downto 0) := "11001";
  --constant OP_STS  : std_logic_vector (op_code_size-1 downto 0) := "11001";

end package;