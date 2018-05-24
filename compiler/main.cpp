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
#include <stack>

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
  if(s.find(".") != std::string::npos) {
    return false;
  }
  char * p ;
  strtol(s.c_str(), &p, 10) ;

  return (*p == 0) ;
}

bool isReal (const std::string & s) {
  if ( s.find(".") != std::string::npos ) {
    std::string t1 = s;
    t1 = ReplaceAll (t1, ".", "");
    return isInteger(t1);
  } else {
    return false;
  }
}

std::string find_name(std::string str) {
  unsigned first = 0;
  if(str.find("entier")  != std::string::npos) {
    first = str.find("r") + 1;
  } else if(str.find("reel")  != std::string::npos) {
    first = str.find("l") + 1;
  }

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

std::string argument_multiplication_1 (std::string str) {
  unsigned first = str.find("=") + 1;
  unsigned last = str.find("*");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_multiplication_2 (std::string str) {
  unsigned first = str.find("*") + 1;
  unsigned last = str.find(";");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_ou_1 (std::string str) {
  unsigned first = str.find("=") + 1;
  unsigned last = str.find("|");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_ou_2 (std::string str) {
  unsigned first = str.find("|") + 1;
  unsigned last = str.find(";");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_et_1 (std::string str) {
  unsigned first = str.find("=") + 1;
  unsigned last = str.find("&");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_et_2 (std::string str) {
  unsigned first = str.find("&") + 1;
  unsigned last = str.find(";");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_xor_1 (std::string str) {
  unsigned first = str.find("=") + 1;
  unsigned last = str.find("^");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_xor_2 (std::string str) {
  unsigned first = str.find("^") + 1;
  unsigned last = str.find(";");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_nor_1 (std::string str) {
  unsigned first = str.find("=") + 1;
  unsigned last = str.find("~|");
  std::string strNew = str.substr (first, last-first);
  return strNew;
}

std::string argument_nor_2 (std::string str) {
  unsigned first = str.find("~|") + 2;
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
  unsigned first;
  if (type == "==")
    first = str.find(type) + 2;
  else
    first = str.find(type) + 1;

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

int loop_to_loop (std::vector<instruction*> & ins_v, int toClose) {
  for ( unsigned int i = ins_v.size() - 1; i > 0; i-- ) {
    if(ins_v[i]->type == TANT_QUE)
      if(ins_v[i]->num == toClose) {
        printf("looping %d at address %d\n",ins_v[i]->num, ins_v[i]->address );
        ins_v[i]->is_closed = true;
        return ins_v[i]->address;
      }
  }
  return 0;
}

var variable ( std::string name, std::vector<var> &var_v ) {
  var v;
  v.name = name;
  if ( isInteger(name) && ! is_declared(name, var_v)){
    v.value = atol(v.name.c_str());
    v.type = INTEGER;
    var_v.push_back(v);
    return v;
  }
  if ( isReal(v.name) && ! is_declared(v.name, var_v) ) {
    v.value = atof(v.name.c_str())*256;
    v.type = REAL;
    var_v.push_back(v);
    return v;
  }
  for (unsigned int i = 0; i < var_v.size(); ++i) {
    if ( var_v[i].name == name )
      return var_v[i];
  }
  return v;
}

int main(int argc, char const *argv[])
{
  //opening of the files
  if(argc <= 1) {
    printf("You should use this program with the following arguments :\n");
    printf("\t ./compiler input_file target_serial_port \n");
    printf("\t example : ./compiler input_file.bag outputfile.asm \n");
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

  std::stack<int> conditions;
  std::stack<int> loops;

  int id_cond = 0;
  int id_loop = 0;

  /*implementation of standard constants*/
    var v;
    // 0
    v.name = "0";
    v.value = 0;
    v.type = INTEGER;
    var_v.push_back(v);
    v.name = "0.";
    v.value = 0;
    v.type = REAL;
    var_v.push_back(v);
    // 1
    v.name = "1";
    v.value = 1;
    v.type = INTEGER;
    var_v.push_back(v);
    // 1
    v.name = "180";
    v.value = 0xB4;
    v.type = INTEGER;
    var_v.push_back(v);
    // FF
    v.name = "FFFFFFF";
    v.value = 0xFFFFFFF;
    v.type = INTEGER;
    var_v.push_back(v);
    // sine index
    v.name = "SININDEX";
    v.value = 0x0003000;
    v.type = INTEGER;
    var_v.push_back(v);
    
    // sine index
    v.name = "SHARED_INDEX";
    v.value = 0x0002000;
    var_v.push_back(v);
    
    // dummy index
    v.name = "DUMMY";
    v.value = 0x0000000;
    var_v.push_back(v);

  //parser
  while ( getline(in_f, line) ) {
    printf ( "%s\n", line.c_str() );
    line = ReplaceAll(line, " ", "");

    if ( line.at(0) == '/' && line.at(1) == '/' ) {
      //to nothing, it's a comment

    } else if ( line.find("entier")    != std::string::npos ) {
      v.name = find_name(line);
      v.type = INTEGER;
      v.value = 0;
      var_v.push_back(v);

    } else if ( line.find("reel")    != std::string::npos ) {
      v.name = find_name(line);
      v.type = REAL;
      v.value = 0;
      var_v.push_back(v);

    } else if ( line.find("+")  != std::string::npos ) {
      ins = new addition;

      //first, find the variable to update
      v.name = variable_to_change(line);
      v = variable( v.name, var_v );
      ins->set_return_var( v );

      //Argument 1
      v.name = argument_addition_1 ( line );
      v = variable( v.name, var_v );
      ins->set_argument1( v );

      //Argument 2
      v.name = argument_addition_2(line);
      v = variable( v.name, var_v );
      ins->set_argument2( v );

      ins_v.push_back(ins);

    } else if ( line.find("|")  != std::string::npos ) {
      ins = new ins_or;

      //first, find the variable to update
      v.name = variable_to_change(line);
      v = variable( v.name, var_v );
      ins->set_return_var( v );

      //Argument 1
      v.name = argument_ou_1 ( line );
      v = variable( v.name, var_v );
      ins->set_argument1( v );

      //Argument 2
      v.name = argument_ou_2 ( line );
      v = variable( v.name, var_v );
      ins->set_argument2( v );

      ins_v.push_back(ins);

    }  else if ( line.find("&")  != std::string::npos ) {
      ins = new ins_and;

      //first, find the variable to update
      v.name = variable_to_change(line);
      v = variable( v.name, var_v );
      ins->set_return_var( v );

      //Argument 1
      v.name = argument_et_1 ( line );
      v = variable( v.name, var_v );
      ins->set_argument1( v );

      //Argument 2
      v.name = argument_et_2 ( line );
      v = variable( v.name, var_v );
      ins->set_argument2( v );

      ins_v.push_back(ins);

    } else if ( line.find("^")  != std::string::npos ) {
      ins = new ins_xor;

      //first, find the variable to update
      v.name = variable_to_change(line);
      v = variable( v.name, var_v );
      ins->set_return_var( v );

      //Argument 1
      v.name = argument_xor_1 ( line );
      v = variable( v.name, var_v );
      ins->set_argument1( v );

      //Argument 2
      v.name = argument_xor_2 ( line );
      v = variable( v.name, var_v );
      ins->set_argument2( v );

      ins_v.push_back(ins);

    } else if ( line.find("~|")  != std::string::npos ) {
      ins = new ins_nor;

      //first, find the variable to update
      v.name = variable_to_change(line);
      v = variable( v.name, var_v );
      ins->set_return_var( v );

      //Argument 1
      v.name = argument_nor_1 ( line );
      v = variable( v.name, var_v );
      ins->set_argument1( v );

      //Argument 2
      v.name = argument_nor_2 ( line );
      v = variable( v.name, var_v );
      ins->set_argument2( v );

      ins_v.push_back(ins);

    } else if (    line.find("-")  != std::string::npos 
                && line.find("=-") == std::string::npos) {
      ins = new soustraction;

      v.name = variable_to_change(line);
      v = variable( v.name, var_v );
      ins->set_return_var( v );

      //Argument 1
      v.name = argument_soustraction_1(line);
      v = variable( v.name, var_v );
      ins->set_argument1( v );

      //Argument 2
      v.name = argument_soustraction_2(line);
      v = variable( v.name, var_v );
      ins->set_argument2( v );

      ins_v.push_back(ins);
    
    } else if ( line.find("*")  != std::string::npos) {

      ins = new multiplication;

      v.name = variable_to_change(line);
      v = variable( v.name, var_v );
      ins->set_return_var( v );

      v.name = argument_multiplication_1(line);
      v = variable( v.name, var_v );
      ins->set_argument1( v );

      v.name = argument_multiplication_2(line);
      v = variable( v.name, var_v );
      ins->set_argument2( v );

      ins_v.push_back(ins);
    
    } else if ( line.find("fin_si") != std::string::npos ) {
      ins = new endif;
      ins->num = conditions.top();
      conditions.pop();
      ins_v.push_back(ins);

    } else if (    line.find("si")  != std::string::npos 
                && line.find("sin") == std::string::npos) {

      condition *cond = new condition;
      cond->set_condition_type ( condition_type (line) );
      cond->num = id_cond;
      conditions.push(id_cond);
      id_cond++;

      v.name = argument_condition1 (line, cond->condition_type);
      v = variable( v.name, var_v );
      cond->set_argument1 ( v );

      v.name = argument_condition2 (line, cond->condition_type);
      v = variable( v.name, var_v );
      cond->set_argument2( v );

      ins_v.push_back(cond);

    } else if ( line.find("sin(")  != std::string::npos ) {
      sine *cond = new sine;

      v.name = argument_condition1(line,")");
      v = variable( v.name, var_v );
      cond->set_argument1 ( v );

      v.name = variable_to_change(line);
      v = variable( v.name, var_v );
      cond->set_return_var( v );

      ins_v.push_back(cond);

    } else if ( line.find("cos(")  != std::string::npos ) {
      cos *cond = new cos;

      v.name = argument_condition1(line,")");
      v = variable( v.name, var_v );
      cond->set_argument1 ( v );
      
      v.name = variable_to_change(line);
      v = variable( v.name, var_v );
      cond->set_return_var( v );
      
      ins_v.push_back(cond);

    } else if ( line.find("fin_tant_que")  != std::string::npos ) {
      ins = new endloop;

      ins->num = loops.top();
      loops.pop();
      ins_v.push_back(ins);

    } else if ( line.find("tant_que")  != std::string::npos ) {
      loop *lo = new loop;

      lo->set_condition_type ( condition_type (line) );
      lo->num = id_loop;
      loops.push(id_loop);
      id_loop++;

      v.name = argument_condition1 (line, lo->condition_type);
      v = variable( v.name, var_v );
      lo->set_argument1 ( v );

      v.name = argument_condition2 (line, lo->condition_type);
      v = variable( v.name, var_v );
      lo->set_argument2( v );

      ins_v.push_back(lo);

    } else if ( line.find("afficher_LCD")  != std::string::npos ) {
      ins = new disp_LCD;

      v.name = argument_condition1(line,")");
      v = variable( v.name, var_v );
      ins->set_argument1( v );

      ins_v.push_back(ins);

    } else if ( line.find("ecrire_mem_part")  != std::string::npos ) {
      ins = new write_to_shared;

      v.name = argument_condition1(line,",");
      v = variable( v.name, var_v );
      ins->set_argument1( v );

      v.name = argument_condition2(line,",");
      v = variable( v.name, var_v );
      ins->set_argument2( v );

      ins_v.push_back(ins);

    } else if ( line.find("ecrire_a")  != std::string::npos ) {
      ins = new write_at;

      v.name = argument_condition1(line,",");
      v = variable( v.name, var_v );
      ins->set_argument1( v );

      v.name = argument_condition2(line,",");
      v = variable( v.name, var_v );
      ins->set_argument2( v );

      ins_v.push_back(ins);

    } else if ( line.find("lire_a")  != std::string::npos ) {
      ins = new read_at;

      v.name = variable_to_change(line);
      v = variable( v.name, var_v );
      ins->set_return_var( v );

      v.name = argument_condition1(line,")");
      v = variable( v.name, var_v );
      ins->set_argument1( v );

      ins_v.push_back(ins);

    } else if ( line.find("=")  != std::string::npos ) {
      ins = new affectation;
 
      v.name = variable_to_change(line);
      v = variable( v.name, var_v );
      ins->set_return_var( v );

      v.name = argument_affectation(line);
      v = variable( v.name, var_v );
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
      sprintf (temp1, ":condition(%d)", ins_v[i]->num);
      sprintf (temp2, "%05x", index_ram);
      printf("replacing: %s by %s .\n", temp1, temp2 );
      whole_file = ReplaceAll (whole_file, std::string(temp1), std::string(temp2));
    }

    if (ins_v[i]->type == FIN_TANT_QUE) {
       //we are in a condition
      char temp1[30] = "";
      char temp2[30] = "";
      printf(" numéro de l'instruction: %d\n", ins_v[i]->num );
      int toClose = ins_v[i]->num;
      sprintf (temp1, ":endloop(%d)", toClose);
      sprintf (temp2, "%05x", index_ram); //TODO: verify that
      printf("replacing: %s by %s .\n", temp1, temp2 );
      whole_file = ReplaceAll (whole_file, std::string(temp1), std::string(temp2));
      sprintf (temp1, ":loop(%d)", toClose);
      sprintf (temp2, "%05x", loop_to_loop(ins_v,toClose)); //TODO: verify that
      printf("replacing: %s by %s .\n", temp1, temp2 );
      whole_file = ReplaceAll (whole_file, std::string(temp1), std::string(temp2));
    }
  }

  //fin du programme
  char temp[30];
  sprintf(temp, "JMP %05x\n", index_ram ++);
  whole_file += temp;

  //gestion des variables
  for (unsigned int i = 0; i < var_v.size(); ++i) {
    //printf("%d VAR %x //nom: %s // type %d\n", index_ram, var_v[i].value, var_v[i].name.c_str(), var_v[i].type);
    char temp[30];
    sprintf(temp, "VAR %07x\n", var_v[i].value & 0x1ffffff);
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

  //printf("\n\nFinal program : \n%s\n", whole_file.c_str() );
  //whole_file = whole_file + "\n\n";
  write( out_f, whole_file.c_str(), strlen(whole_file.c_str()));

  if ( conditions.size() < 0)
    std::cerr << "\033[1;31mError: " << loops.size() * -1 << " more loop closed than open\033[0m" << std::endl;
  if ( conditions.size() > 0)
    std::cerr << "\033[1;31mError: " << loops.size() << " loop(s) has not been closed\033[0m" << std::endl;

  if ( conditions.size() < 0)
    std::cerr << "\033[1;31mError: " << conditions.size() * -1 << " more condition(s) closed than open\033[0m" << std::endl;
  if ( conditions.size() > 0)
    std::cerr << "\033[1;31mError: " << conditions.size() << " condition(s) has not been closed\033[0m" << std::endl;

  printf("This program has a total of %d lines = %.2f%% of the maximum\n", 
          index_ram,
          ((float)index_ram*100.f)/ (float)MAX_RAM  );
  in_f.close();
  close(out_f);

  return 0;
}

