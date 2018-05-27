#ifndef INSTRUCTION
#define INSTRUCTION

#include <string>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <cstdint>

#include <sys/types.h>
#include <sys/stat.h>

#include "variable.h"

typedef enum {
  ADDITION,
  SOUSTRACTION,
  MULTIPLICATION,
  DIVISION,
  AFFECTATION,
  CONDITION,
  FIN_CONDITION,
  TANT_QUE,
  FIN_TANT_QUE,
  AFFICHAGE_LCD,
  ECRITURE_MEMOIRE,
  SIN,
  COS,
  WRITE_AT,
  READ_AT,
  OR,
  NOR,
  AND,
  XOR,
  FTI,
  ITF
} INS_TYPE;


class instruction
{
public:
  instruction();
  ~instruction();

public:
  INS_TYPE type;
  int nb_ins;
  //only for conditions and loop
  int num;
  uint32_t address;
  bool is_closed;

//protected:
  var a1;
  var a2;
  var a3;
  var var_;

public :
  void set_argument1  (var variable);
  void set_argument2  (var variable);
  void set_return_var (var variable);

  void set_address (uint32_t address);

  virtual std::string print_instruction() = 0;
};

class addition : public instruction {
public:
  addition();
  ~addition();
  std::string print_instruction();
};

class affectation : public instruction {
public:
  affectation();
  ~affectation();
  std::string print_instruction();
};

class soustraction : public instruction {
public:
  soustraction();
  ~soustraction();
  std::string print_instruction();
};

class multiplication : public instruction {
public:
  multiplication();
  ~multiplication();
  std::string print_instruction();
};

class division : public instruction {
public:
  division();
  ~division();
  std::string print_instruction();
};

class condition : public instruction {
public:
  std::string condition_type;
  condition();
  ~condition();
  void set_condition_type(std::string type);
  std::string print_instruction();
};

class loop : public instruction {
public:
  std::string condition_type;
  loop();
  ~loop();
  void set_condition_type(std::string type);
  std::string print_instruction();
};

class endif : public instruction {
public:
  endif();
  ~endif();
  int endif_n;
  uint32_t address_close;
  std::string print_instruction();
};

class endloop : public instruction {
public:
  endloop();
  ~endloop();
  int endif_n;
  uint32_t address_close;
  std::string print_instruction();
};

class disp_LCD : public instruction {
public:
  disp_LCD();
  ~disp_LCD();
  std::string print_instruction();
};

class write_to_shared : public instruction {
public:
  write_to_shared();
  ~write_to_shared();
  std::string print_instruction();
};

class sine : public instruction {
public:
  sine();
  ~sine();
  std::string print_instruction();
};

class cos : public instruction {
public:
  cos();
  ~cos();
  std::string print_instruction();
};

class write_at : public instruction {
public:
  write_at();
  ~write_at();
  std::string print_instruction();
};

class read_at : public instruction {
public:
  read_at();
  ~read_at();
  std::string print_instruction();
};

class ins_or : public instruction {
public:
  ins_or();
  ~ins_or();
  std::string print_instruction();
};

class ins_nor : public instruction {
public:
  ins_nor();
  ~ins_nor();
  std::string print_instruction();
};

class ins_xor : public instruction {
public:
  ins_xor();
  ~ins_xor();
  std::string print_instruction();
};

class ins_and : public instruction {
public:
  ins_and();
  ~ins_and();
  std::string print_instruction();
};

class ins_fti : public instruction {
public:
  ins_fti();
  ~ins_fti();
  std::string print_instruction();
};

class ins_itf : public instruction {
public:
  ins_itf();
  ~ins_itf();
  std::string print_instruction();
};

#endif

