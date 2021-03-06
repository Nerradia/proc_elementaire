#include "instruction.h"

instruction::instruction() {
}

instruction::~instruction() {
}

void instruction::set_argument1 ( var variable ) {
  this->a1 = variable;
}

void instruction::set_argument2 ( var variable ) {
  this->a2 = variable;
}

void instruction::set_return_var ( var variable ) {
  this->var_ = variable;
}

void instruction::set_address ( uint32_t address ) {
  this->address = address;
}

addition::addition() {
  nb_ins = 3;
  type = ADDITION;
}

std::string addition::print_instruction() {
  std::string instructions = "";
  if(a1.type == INTEGER && a2.type == INTEGER) {
    instructions += "GET :addr(" + a1.name   + ")\n";
    instructions += "ADD :addr(" + a2.name   + ")\n";
    instructions += "STA :addr(" + var_.name + ")\n";
  } else if (a1.type == REAL && a2.type == REAL) {
    instructions += "GET :addr(" + a1.name   + ")\n";
    instructions += "FAD :addr(" + a2.name   + ")\n";
    instructions += "STA :addr(" + var_.name + ")\n";
  } else {
    fprintf(stderr, "\033[1;31m==> %s + %s \033[0m\n", a1.name.c_str(), a2.name.c_str());
    fprintf(stderr, "\033[1;31mYou can only add variable with the same type\033[0m\n");
  }
  return instructions;
}

division::division() {
  nb_ins = 3;
  type = DIVISION;
}

std::string division::print_instruction() {
  std::string instructions = "";
  if(a1.type == INTEGER && a2.type == INTEGER) {
    instructions += "GET :addr(" + a1.name   + ")\n";
    instructions += "DIV :addr(" + a2.name   + ")\n";
    instructions += "STA :addr(" + var_.name + ")\n";
  } else if (a1.type == REAL && a2.type == REAL) {
    instructions += "GET :addr(" + a1.name   + ")\n";
    instructions += "FDI :addr(" + a2.name   + ")\n";
    instructions += "STA :addr(" + var_.name + ")\n";
  } else {
    fprintf(stderr, "\033[1;31m==> %s + %s \033[0m\n", a1.name.c_str(), a2.name.c_str());
    fprintf(stderr, "\033[1;31mYou can only add variable with the same type\033[0m\n");
  }
  return instructions;
}

affectation::affectation() {
  nb_ins = 2;
  type = AFFECTATION;
}

std::string affectation::print_instruction() {
  std::string instructions = "";
  instructions += "GET :addr(" + a1.name   + ")\n";
  instructions += "STA :addr(" + var_.name + ")\n";
  return instructions;
}

soustraction::soustraction() {
  nb_ins = 3;
  type = SOUSTRACTION;
}

std::string soustraction::print_instruction() {
  std::string instructions = "";
  if(a1.type == INTEGER && a2.type == INTEGER) {
    instructions += "GET :addr(" + a1.name   + ")\n";
    instructions += "SUB :addr(" + a2.name   + ")\n";
    instructions += "STA :addr(" + var_.name + ")\n";
  } else if (a1.type == REAL && a2.type == REAL) {
    instructions += "GET :addr(" + a1.name   + ")\n";
    instructions += "SUB :addr(" + a2.name   + ")\n";
    instructions += "STA :addr(" + var_.name + ")\n";
  } else {
    fprintf(stderr, "\033[1;31m==> %s - %s \033[0m\n", a1.name.c_str(), a2.name.c_str());
    fprintf(stderr, "\033[1;31mYou can only substract variable with the same type\033[0m\n");
  }
  return instructions;
}

multiplication::multiplication() {
  nb_ins = 3;
  type = MULTIPLICATION;
}

std::string multiplication::print_instruction() {
  std::string instructions = "";
  if(a1.type == INTEGER && a2.type == INTEGER) {
    instructions += "GET :addr(" + a1.name   + ")\n";
    instructions += "MUL :addr(" + a2.name   + ")\n";
    instructions += "STA :addr(" + var_.name + ")\n";
  } else if (a1.type == REAL && a2.type == REAL) {
    instructions += "GET :addr(" + a1.name   + ")\n";
    instructions += "FMU :addr(" + a2.name   + ")\n";
    instructions += "STA :addr(" + var_.name + ")\n";
  } else {
    fprintf(stderr, "\033[1;31m==> %s * %s \033[0m\n", a1.name.c_str(), a2.name.c_str());
    fprintf(stderr, "\033[1;31mYou can only multiply variable with the same type\033[0m\n");
  }
  return instructions;
}

condition::condition () {
  nb_ins = 3;
  type = CONDITION;
}

void condition::set_condition_type (std::string type) {
  this->condition_type = type;
}

std::string condition::print_instruction () {
  std::string instructions = "";
  instructions += "GET :addr(" + a1.name + ")\n";
  if( condition_type == "<") {
    instructions += "TLT :addr(" + a2.name + ")\n";
  } else if( condition_type == ">") {
    instructions += "TGT :addr(" + a2.name + ")\n";
  } else if( condition_type ==  "==") {
    instructions += "TEQ :addr(" + a2.name + ")\n";
  } 
  instructions += "JCC :condition(" + std::to_string(num) + ")\n";
  return instructions;
}

endif::endif() {
  nb_ins = 0;
  type = FIN_CONDITION;
}

std::string endif::print_instruction() {

  return "";
}

loop::loop() {
  nb_ins = 3;
  type = TANT_QUE;
}

void loop::set_condition_type (std::string type) {
  this->condition_type = type;
}

std::string loop::print_instruction() {
  std::string instructions = "";
  instructions += "GET :addr(" + a1.name + ")\n";
  if( condition_type == ">") {
    instructions += "TGT :addr(" + a2.name + ")\n";
  } else if( condition_type == "<") {
    instructions += "TLT :addr(" + a2.name + ")\n";
  } else if( condition_type ==  "==") {
    instructions += "TEQ :addr(" + a2.name + ")\n";
  }
  instructions += "JCC :endloop(" + std::to_string(num) + ")\n";
  return instructions;
}

endloop::endloop() {
  nb_ins = 1;
  type = FIN_TANT_QUE;
}

std::string endloop::print_instruction() {
//we print the JCC twice to be sure that we correctly jump
  std::string instructions = "";

  instructions += "JMP :loop(" + std::to_string(num) + ")\n";

  return instructions;
}

disp_LCD::disp_LCD() {
  nb_ins = 2;
  type = AFFICHAGE_LCD;
}

std::string disp_LCD::print_instruction() {
  std::string instructions = "";
  instructions += "GET :addr(" + a1.name + ")\n";
  instructions += "STA 80001\n";
  return instructions;
}

write_to_shared::write_to_shared() {
  nb_ins = 3;
  type = ECRITURE_MEMOIRE;
}

std::string write_to_shared::print_instruction() {
  std::string instructions = "";
  instructions += "GET :addr(" + a1.name + ")\n";
  instructions += "ADD :addr(SHARED_INDEX)\n";
  instructions += "SAD :addr(" + a2.name + ")\n";
  return instructions;
}

sine::sine() {
  nb_ins = 5;
  type = SIN;
}

std::string sine::print_instruction() {
  std::string instructions = "";
  instructions += "GET :addr(" + a1.name + ")\n";
  instructions += "ADD :addr(SININDEX)\n";
  instructions += "STA :addr(DUMMY)\n";
  instructions += "GAD :addr(DUMMY)\n"; //get @ address
  instructions += "STA :addr(" + var_.name + ")\n"; //store in the return var
  return instructions;
}

cos::cos() {
  nb_ins = 6;
  type = COS;
}

std::string cos::print_instruction() {
  std::string instructions = "";
  instructions += "GET :addr(" + a1.name + ")\n";
  instructions += "ADD :addr(90)\n";
  instructions += "ADD :addr(SININDEX)\n";
  instructions += "STA :addr(DUMMY)\n";
  instructions += "GAD :addr(DUMMY)\n"; //get @ address
  instructions += "STA :addr(" + var_.name + ")\n"; //store in the return var
  return instructions;
}

write_at::write_at() {
  nb_ins = 2;
  type = WRITE_AT;
}

std::string write_at::print_instruction() {
  std::string instructions = "";
  instructions += "GET :addr(" + a1.name + ")\n";
  instructions += "SAD :addr(" + a2.name + ")\n"; //set @ address
  return instructions;
}

read_at::read_at() {
  nb_ins = 2;
  type = READ_AT;
}

std::string read_at::print_instruction() {
  std::string instructions = "";
  instructions += "GAD :addr(" + a1.name + ")\n"; //get @ address
  instructions += "STA :addr(" + var_.name + ")\n"; //store in the return var
  return instructions;
}

ins_or::ins_or() {
  nb_ins = 3;
  type = OR;
}

std::string ins_or::print_instruction() {
  std::string instructions = "";
  instructions += "GET :addr(" + a1.name   + ")\n";
  instructions += "LOR :addr(" + a2.name   + ")\n";
  instructions += "STA :addr(" + var_.name + ")\n";
  return instructions;
}

ins_nor::ins_nor() {
  nb_ins = 3;
  type = OR;
}

std::string ins_nor::print_instruction() {
  std::string instructions = "";
  instructions += "GET :addr(" + a1.name   + ")\n";
  instructions += "NOR :addr(" + a2.name   + ")\n";
  instructions += "STA :addr(" + var_.name + ")\n";
  return instructions;
}

ins_xor::ins_xor() {
  nb_ins = 3;
  type = OR;
}

std::string ins_xor::print_instruction() {
  std::string instructions = "";
  instructions += "GET :addr(" + a1.name   + ")\n";
  instructions += "XOR :addr(" + a2.name   + ")\n";
  instructions += "STA :addr(" + var_.name + ")\n";
  return instructions;
}

ins_and::ins_and() {
  nb_ins = 3;
  type = OR;
}

std::string ins_and::print_instruction() {
  std::string instructions = "";
  instructions += "GET :addr(" + a1.name   + ")\n";
  instructions += "AND :addr(" + a2.name   + ")\n";
  instructions += "STA :addr(" + var_.name + ")\n";
  return instructions;
}


ins_fti::ins_fti() {
  nb_ins = 2;
  type = FTI;
}

std::string ins_fti::print_instruction() {
  std::string instructions = "";
  instructions += "FTI :addr(" + a1.name   + ")\n";
  instructions += "STA :addr(" + var_.name + ")\n";
  return instructions;
}

ins_itf::ins_itf() {
  nb_ins = 2;
  type = ITF;
}

std::string ins_itf::print_instruction() {
  std::string instructions = "";
  instructions += "ITF :addr(" + a1.name   + ")\n";
  instructions += "STA :addr(" + var_.name + ")\n";
  return instructions;
}


