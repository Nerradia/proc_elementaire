#ifndef VARIABLE
#define VARIABLE

#include <string>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <cstdint>

#include <string.h>

class var
{
public:
  var();
  ~var();

public: 
  std::string name;

  uint32_t value;
  uint32_t address;
};

#endif

