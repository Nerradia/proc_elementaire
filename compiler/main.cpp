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

#define MAX_RAM 8192

/* list of instructions available
  //locical operands
  LOR // logical OR
  XOR
  AND
  NOR
  //mathematical operands
  ADD
  SUB
  DIV
  MUL
  MOD //modulo
  //float operands
  FAD // addition 
  FDI //division
  FMU //multiply

  //UTILS
  STA
  JCC
  JMP //jump
  VAR //declaration of a variable

  //TESTS
  TGT //greater than
  TLT //lower than
  TEQ //equal

  //Casts
  FTI //float to int 
  ITF //int to float
*/

bool is_declared( std::string name, std::vector<var> var_v) {
  for (unsigned int i = 0; i < var_v.size(); ++i) {
    if ( var_v[i].name == name )
      return true;
  }
  return false;
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

inline bool isInteger(const std::string & s)
{
   if(s.empty() || ((!isdigit(s[0])) && (s[0] != '-') && (s[0] != '+'))) return false ;

   char * p ;
   strtol(s.c_str(), &p, 10) ;

   return (*p == 0) ;
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

std::string argument_addition_1 (std::string str) {
  unsigned first = str.find("=") + 1;
  unsigned last = str.find("+");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_addition_2 (std::string str) {
  unsigned first = str.find("+") + 1;
  unsigned last = str.find(";");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_soustraction_1 (std::string str) {
  unsigned first = str.find("=") + 1;
  unsigned last = str.find("-");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_soustraction_2 (std::string str) {
  unsigned first = str.find("-") + 1;
  unsigned last = str.find(";");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_affectation (std::string str) {
  unsigned first = str.find("=") + 1;
  unsigned last = str.find(";");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_condition1 (std::string str, std::string type) {
  unsigned first = str.find("(") + 1;
  unsigned last = str.find(type);
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_condition2 (std::string str, std::string type) {
  unsigned first = str.find(type) + 1;
  unsigned last = str.find(")");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string condition_type (std::string str) {
  if (str.find(">")  != std::string::npos)
    return ">";
  if (str.find("<")  != std::string::npos)
    return "<";
  if (str.find("==") != std::string::npos)
    return "==";

//default, should not append
  return "==";
}

int condition_to_close (std::vector<instruction*> & ins_v) {
  for ( unsigned int i = ins_v.size() - 1; i > 0; i-- ) {
    if(ins_v[i]->type == CONDITION)
      if(! ins_v[i]->is_closed) {
        ins_v[i]->is_closed = true;
        return ins_v[i]->num;
      }
  }
  return 0;
}

int loop_to_close (std::vector<instruction*> & ins_v) {
  for ( unsigned int i = ins_v.size() - 1; i > 0; i-- ) {
    if(ins_v[i]->type == TANT_QUE)
      if(! ins_v[i]->is_closed) {
        //ins_v[i]->is_closed = true;
        return ins_v[i]->num;
      }
  }
  return 0;
}

int loop_to_loop (std::vector<instruction*> & ins_v) {
  for ( unsigned int i = ins_v.size() - 1; i > 0; i-- ) {
    if(ins_v[i]->type == TANT_QUE)
      if(! ins_v[i]->is_closed) {
        ins_v[i]->is_closed = true;
        return ins_v[i]->address;
      }
  }
  return 0;
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
  instruction * ins;

  std::vector<var>            var_v;
  std::vector<instruction*>   ins_v;
  unsigned int cpt_cond = 0;
  unsigned int cpt_loop = 0;

  /*implementation of standard constants*/
    var v;
    // 0
    v.name = "0";
    v.value = 0;
    var_v.push_back(v);
    // 1
    v.name = "1";
    v.value = 1;
    var_v.push_back(v);
    // FF
    v.name = "FFFFFFF";
    v.value = 0xFFFFFFF;
    var_v.push_back(v);

  //parser
  while ( getline(in_f, line) ) {
    printf ( "%s\n", line.c_str() );
    line = ReplaceAll(line, " ", "");

    if ( line.find("entier")    != std::string::npos ) {
      v.name = find_name(line);
      v.value = 0;
      var_v.push_back(v);

    } else if ( line.find("+")  != std::string::npos ) {
      ins = new addition;
      //first, find the variable to update
      v.name = variable_to_change(line);
      ins->set_return_var( v );
      //then find the 2 arguments
      v.name = argument_addition_1(line);

      //we check if it's an undeclared constant
      if(isInteger(v.name) && ! is_declared(v.name, var_v)){
        v.value = atol(v.name.c_str());
        var_v.push_back(v);
      }
      ins->set_argument1( v );
      v.name = argument_addition_2(line);

      //we check if it's an undeclared constant
      if(isInteger(v.name) && ! is_declared(v.name, var_v)){
        v.value = atol(v.name.c_str());
        var_v.push_back(v);
      }
      ins->set_argument2( v );
      ins_v.push_back(ins);

    } else if ( line.find("-")  != std::string::npos ) {
      ins = new soustraction;
      //first, find the variable to update
      v.name = variable_to_change(line);
      ins->set_return_var( v );
      //then find the 2 arguments
      v.name = argument_soustraction_1(line);
      //we check if it's an undeclared constant
      if(isInteger(v.name) && ! is_declared(v.name, var_v)){
        v.value = atol(v.name.c_str());
        var_v.push_back(v);
      }
      ins->set_argument1( v );
      v.name = argument_soustraction_2(line);
      //we check if it's an undeclared constant
      if(isInteger(v.name) && ! is_declared(v.name, var_v)){
        v.value = atol(v.name.c_str());
        var_v.push_back(v);
      }
      ins->set_argument2( v );
      ins_v.push_back(ins);
    
    } else if ( line.find("fin_si") != std::string::npos ) {
      ins = new endif;      
      ins_v.push_back(ins);

    } else if ( line.find("si") != std::string::npos ) {
      condition *cond = new condition;
      cond->set_condition_type ( condition_type (line) );
      cond->num = cpt_cond++;
      v.name = argument_condition1 (line, cond->condition_type);
      //we check if it's an undeclared constant
      if(isInteger(v.name) && ! is_declared(v.name, var_v)){
        v.value = atol(v.name.c_str());
        var_v.push_back(v);
      }
      cond->set_argument1 ( v );

      v.name = argument_condition2 (line, cond->condition_type);
      //we check if it's an undeclared constant
      if(isInteger(v.name) && ! is_declared(v.name, var_v)){
        v.value = atol(v.name.c_str());
        var_v.push_back(v);
      }
      cond->set_argument2( v );

      ins_v.push_back(cond);

    } else if ( line.find("fin_tant_que")  != std::string::npos ) {
      ins = new endloop;
      cpt_loop--;
      ins->num = cpt_loop;
      ins_v.push_back(ins);

    } else if ( line.find("tant_que")  != std::string::npos ) {
      loop *lo = new loop;
      lo->set_condition_type ( condition_type (line) );
      lo->num = cpt_loop;
      cpt_loop++;
      v.name = argument_condition1 (line, lo->condition_type);
      //we check if it's an undeclared constant
      if(isInteger(v.name) && ! is_declared(v.name, var_v)){
        v.value = atol(v.name.c_str());
        var_v.push_back(v);
      }
      lo->set_argument1 ( v );

      v.name = argument_condition2 (line, lo->condition_type);
      //we check if it's an undeclared constant
      if(isInteger(v.name) && ! is_declared(v.name, var_v)){
        v.value = atol(v.name.c_str());
        var_v.push_back(v);
      }
      lo->set_argument2( v );

      ins_v.push_back(lo);

    } else if ( line.find("afficher")  != std::string::npos ) {
      ins = new disp_screen;
      //first, find the variable to update
      v.name = find_name(line);
      //we check if it's an undeclared constant
      if(isInteger(v.name) && ! is_declared(v.name, var_v)){
        v.value = atol(v.name.c_str());
        var_v.push_back(v);
      }
      ins->set_argument1( v );
      ins_v.push_back(ins);

    } else if ( line.find("=")  != std::string::npos ) {
      ins = new affectation;
      //first, find the variable to update
      v.name = variable_to_change(line);
      ins->set_return_var( v );
      //then find the 2 arguments
      v.name = argument_affectation(line);
      //we check if it's an undeclared constant
      if(isInteger(v.name) && ! is_declared(v.name, var_v)){
        v.value = atol(v.name.c_str());
        var_v.push_back(v);
      }
      ins->set_argument1( v );
      ins_v.push_back(ins);
    } else {
      //printf("==> autre ? \n");
    }
  }
  
  std::string whole_file = "";
  uint32_t index_ram = 0;

  //gestion des instructions
  for ( unsigned int i = 0; i < ins_v.size(); ++i ) {
    ins_v[i]->set_address(index_ram);
    whole_file += ins_v[i]->print_instruction();
    index_ram  += ins_v[i]->nb_ins;
    
    if (ins_v[i]->type == FIN_CONDITION) {
      //we are in a condition
      char temp1[30] = "";
      char temp2[30] = "";
      sprintf (temp1, ":condition(%d)", condition_to_close (ins_v));
      sprintf (temp2, "%05x", index_ram);
      whole_file = ReplaceAll (whole_file, std::string(temp1), std::string(temp2));
    }

    if (ins_v[i]->type == FIN_TANT_QUE) {
       //we are in a condition
      char temp1[30] = "";
      char temp2[30] = "";
      int toClose = loop_to_close(ins_v);
      sprintf (temp1, ":endloop(%d)", toClose);
      sprintf (temp2, "%05x", index_ram); //TODO: verify that
      whole_file = ReplaceAll (whole_file, std::string(temp1), std::string(temp2));
      sprintf (temp1, ":loop(%d)", toClose);
      sprintf (temp2, "%05x", loop_to_loop(ins_v)); //TODO: verify that
      whole_file = ReplaceAll (whole_file, std::string(temp1), std::string(temp2));
    }
  }

  //fin du programme
  char temp[30];
  sprintf(temp, "JCC %05x\n", index_ram ++);
  whole_file += temp;

  //gestion des variables
  for (unsigned int i = 0; i < var_v.size(); ++i) {
    //printf("%d VAR %x //nom: %s\n", index_ram, var_v[i].value, var_v[i].name.c_str());
    char temp[30];
    sprintf(temp, "VAR %07x\n", var_v[i].value);
    whole_file += temp;
    var_v[i].address = index_ram;
    index_ram++;
    
    //replacement of the variable name in the program with the address
    char temp1[30] = "";
    char temp2[30] = "";
    sprintf(temp1, ":addr(%s)", var_v[i].name.c_str());
    sprintf(temp2, "%05x", var_v[i].address);
    whole_file = ReplaceAll(whole_file, std::string(temp1), std::string(temp2));
  }

  printf("\n\nFinal program : \n%s\n", whole_file.c_str() );

  printf("This program has a total of %d lines = %.2f%% of the maximum\n", 
          index_ram,
          ((float)index_ram*100.f)/ (float)MAX_RAM  );
  in_f.close();
  close(out_f);

  return 0;
}

