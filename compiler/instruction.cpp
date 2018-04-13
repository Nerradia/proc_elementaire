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
  instructions += "ADD :addr(" + a1.name   + ")\n";
  if( condition_type == "<") {
    instructions += "TLT :addr(" + a2.name   + ")\n";
  } else if( condition_type == ">") {
    instructions += "TGT :addr(" + a2.name   + ")\n";
  } else if( condition_type ==  "==") {
    instructions += "TEQ :addr(" + a2.name   + ")\n";
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
  instructions += "ADD :addr(" + a1.name   + ")\n";
  if( condition_type == "<") {
    instructions += "TGT :addr(" + a2.name   + ")\n";
  } else if( condition_type == ">") {
    instructions += "TLT :addr(" + a2.name   + ")\n";
  } else if( condition_type ==  "!=") {
    instructions += "TEQ :addr(" + a2.name   + ")\n";
  }
  instructions += "JCC :endloop(" + std::to_string(num) + ")\n";
  return instructions;
}

endloop::endloop() {
  nb_ins = 2;
  type = FIN_TANT_QUE;
}

std::string endloop::print_instruction() {
//we print the JCC twice to be sure that we correctly jump
  std::string instructions = "";

  instructions += "JCC :loop(" + std::to_string(num) + ")\n";
  instructions += "JCC :loop(" + std::to_string(num) + ")\n";

  return instructions;
}

disp_screen::disp_screen() {
  nb_ins = 3;
}

std::string disp_screen::print_instruction() {
  std::string instructions = "";
  instructions += "NOR :addr(FFFFFFF)\n";
  instructions += "ADD :addr(" + a1.name   + ")\n";
  instructions += "STA 80001\n";
  return instructions;
}


