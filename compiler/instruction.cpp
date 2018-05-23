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
  nb_ins = 4;
  type = ADDITION;
}

std::string addition::print_instruction() {
  std::string instructions = "";
  instructions += "NOR :addr(FFFFFFF)\n";
  instructions += "ADD :addr(" + a1.name   + ")\n";
  instructions += "ADD :addr(" + a2.name   + ")\n";
  instructions += "STA :addr(" + var_.name + ")\n";
  return instructions;
}

affectation::affectation() {
  nb_ins = 3;
  type = AFFECTATION;
}

std::string affectation::print_instruction() {
  std::string instructions = "";
  instructions += "NOR :addr(FFFFFFF)\n";
  instructions += "ADD :addr(" + a1.name   + ")\n";
  instructions += "STA :addr(" + var_.name + ")\n";
  return instructions;
}

soustraction::soustraction() {
  nb_ins = 4;
  type = SOUSTRACTION;
}

std::string soustraction::print_instruction() {
  std::string instructions = "";
  instructions += "NOR :addr(FFFFFFF)\n";
  instructions += "ADD :addr(" + a1.name   + ")\n";
  instructions += "SUB :addr(" + a2.name   + ")\n";
  instructions += "STA :addr(" + var_.name + ")\n";
  return instructions;
}

multiplication::multiplication() {
  nb_ins = 4;
  type = MULTIPLICATION;
}

std::string multiplication::print_instruction() {
  std::string instructions = "";
  instructions += "NOR :addr(FFFFFFF)\n";
  instructions += "ADD :addr(" + a1.name   + ")\n";
  instructions += "MUL :addr(" + a2.name   + ")\n";
  instructions += "STA :addr(" + var_.name + ")\n";
  return instructions;
}

condition::condition () {
  nb_ins = 4;
  type = CONDITION;
}

void condition::set_condition_type (std::string type) {
  this->condition_type = type;
}

std::string condition::print_instruction () {
  std::string instructions = "";
  instructions += "NOR :addr(FFFFFFF)\n";
  instructions += "ADD :addr(" + a1.name + ")\n";
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
  nb_ins = 4;
  type = TANT_QUE;
}

void loop::set_condition_type (std::string type) {
  this->condition_type = type;
}

std::string loop::print_instruction() {
  std::string instructions = "";
  instructions += "NOR :addr(FFFFFFF)\n";
  instructions += "ADD :addr(" + a1.name + ")\n";
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
  nb_ins = 3;
  type = AFFICHAGE_LCD;
}

std::string disp_LCD::print_instruction() {
  std::string instructions = "";
  instructions += "NOR :addr(FFFFFFF)\n";
  instructions += "ADD :addr(" + a1.name + ")\n";
  instructions += "STA 80001\n";
  return instructions;
}

write_to_shared::write_to_shared() {
  nb_ins = 4;
  type = ECRITURE_MEMOIRE;
}

std::string write_to_shared::print_instruction() {
  std::string instructions = "";
  instructions += "NOR :addr(FFFFFFF)\n";
  instructions += "ADD :addr(" + a1.name + ")\n";
  instructions += "ADD :addr(SHARED_INDEX)\n";
  instructions += "SAD :addr(" + a2.name + ")\n";
  return instructions;
}

sine::sine() {
  nb_ins = 6;
  type = SIN;
}

std::string sine::print_instruction() {
  std::string instructions = "";
  instructions += "NOR :addr(FFFFFFF)\n";
  instructions += "ADD :addr(" + a1.name + ")\n";
  instructions += "ADD :addr(SININDEX)\n";
  instructions += "STA :addr(DUMMY)\n";
  instructions += "GAD :addr(DUMMY)\n"; //get @ address
  instructions += "STA :addr(" + var_.name + ")\n"; //store in the return var
  return instructions;
}

cos::cos() {
  nb_ins = 7;
  type = COS;
}

std::string cos::print_instruction() {
  std::string instructions = "";
  instructions += "NOR :addr(FFFFFFF)\n";
  instructions += "ADD :addr(" + a1.name + ")\n";
  instructions += "ADD :addr(180)\n";
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


