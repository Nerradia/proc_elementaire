#ifndef VARIABLE
#define VARIABLE

#include <string>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <cstdint>

#include <string.h>

typedef enum {
  INTEGER,
  REAL
} varType;

class var
{
public:
  var();
  ~var();

public: 
  std::string name;
  varType type;
  int32_t value;
  uint32_t address;
};

#endif

