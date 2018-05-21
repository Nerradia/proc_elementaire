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
  AFFECTATION,
  CONDITION,
  FIN_CONDITION,
  TANT_QUE,
  FIN_TANT_QUE,
  AFFICHAGE_LCD,
  ECRITURE_MEMOIRE,
  SIN,
  COS,
  WRITE_AT
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

protected:
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

#endif

