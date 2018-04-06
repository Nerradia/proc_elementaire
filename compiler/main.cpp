/*******************************************************************************
 *  Main Author : Pierre JOUBERT
 *  With the kind collaboration of : Julien BESSE
 *  Date : 04/04/2018
 *  OS : Linux
 *               ____ ___  __  __ ____ ___ _     _____ ____
 *              / ___| _ \|  \/  |  _ \_ _| |   | ____|  _ \
 *             | |  | | | | |\/| | |_) | || |   |  _| | |_) |
 *             | |___ |_| | |  | |  __/| || |___| |___|  _ < 
 *              \____|___/|_|  |_|_|  |___|_____|_____|_| \_\
 *
 *
 *
 *    The goal of this program is to compile a code written in language 
 *  baguette to assembly.
 * Usage: ./compiler input_file.bag outputfile.asm
 ******************************************************************************/

#include <errno.h>
#include <fcntl.h>
#include <fstream>
#include <iostream>
#include <iterator>
#include <map>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <termios.h>
#include <unistd.h>
#include <vector>

#include <sys/types.h>
#include <sys/stat.h>

#include "instruction.h"
#include "variable.h"

/* list of instructions available
  NOR
  ADD
  STA
  JCC
  JMP //jump
  TGT //greater than
  TLT //lower than
  TEQ //equal
  VAR //equal
*/

enum {
  ADD_VAR,
  ADDITION
}; //instructionType;


int readLine (int file, std::string *line, instruction ins) {

  return 0;
}

std::string ReplaceAll( std::string str, 
                        const std::string& from, 
                        const std::string& to ) {
    size_t start_pos = 0;
    while((start_pos = str.find(from, start_pos)) != std::string::npos) {
        str.replace(start_pos, from.length(), to);
        start_pos += to.length(); // Handles case where 'to' is a substring of 'from'
    }
    return str;
}

std::string find_name(std::string str) {
  unsigned first = str.find("r") + 1;
  unsigned last = str.find(";");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string variable_to_change(std::string str) {
  unsigned last = str.find("=");
  std::string strNew = str.substr (0, last);
  return strNew;
}

int main(int argc, char const *argv[])
{
  //opening of the files
  if(argc <= 1) {
    printf("You should use this program with the following arguments :\n");
    printf("\t ./dtm input_file target_serial_port \n");
    printf("\t example : ./compile input_file.bag outputfile.asm \n");
    return -1;
  } 

  const char * input_file = argv[1];
  std::ifstream in_f( input_file );

  if (!in_f.is_open()) {
    printf ("error %d opening %s: %s \n", errno, input_file, strerror (errno));
    return -1;
  }

  const char * output_file = argv[2];
  remove(output_file);
  int out_f = open(output_file,  O_WRONLY | O_CREAT);

  if (out_f < 0) {
    printf ("error %d opening %s: %s \n", errno, output_file, strerror (errno));
    return -1;
  }

  std::string line = "";
  instruction ins;

  std::vector<var> v;
  //parser
  for( std::string line; getline( in_f, line ); ) {
    printf("%s\n",line.c_str());
    line = ReplaceAll(line, " ", "");

    if ( line.find("entier") != std::string::npos ) {
      ins.type = ADD_VAR;
      printf( "=> Ajout de variable \n" );

      var var_;
      var_.name = find_name(line);
      var_.value = 0;
      v.push_back(var_);

      printf("nom de la variable : %s\n", var_.name.c_str());

    } else if ( line.find("+", 0) != std::string::npos ) {
      ins.type = ADDITION;
      //ins.setArgument1();
      printf( "=> Addition\n");
      printf("variable_to_change : %s\n", variable_to_change(line).c_str() );

    } else if ( line.find("-") != std::string::npos ) {
      printf("=> Soustraction\n");

    } else if ( line.find("=") != std::string::npos ) {
      printf("=> affectation \n");

    } else {
      printf("==> autre ? \n");
    }
  }
  uint32_t index_ram = 0;
  //gestion des instructions

  //gestion des variables
  for (unsigned int i = 0; i < v.size(); ++i) {
    printf("%d VAR %d\n", index_ram, v[i].value);
    index_ram++;
  }

  in_f.close();
  close(out_f);

  return 0;
}