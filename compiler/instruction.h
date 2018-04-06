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

class instruction
{
public:
  instruction();
  ~instruction();

public:
  int type;

private:
  uint32_t argument1; 
  uint32_t argument2; 

public:
  void set_argument1(int entier);
  void set_argument1(var variable);
  void set_argument2(int entier);
  void set_argument2(var variable);
  void ser_return_value(var variable);

public:
  std::string print_instruction();
};

#endif

