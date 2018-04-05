/*******************************************************************************
 *  Main Author : Pierre JOUBERT
 *  With the kind collaboration of : Julien BESSE
 *  Date : 04/04/2018
 *  OS : Linux
 *                            _/_/      _/_/_/  _/      _/ 
 *                         _/    _/  _/        _/_/  _/_/  
 *                        _/_/_/_/    _/_/    _/  _/  _/   
 *                       _/    _/        _/  _/      _/    
 *                      _/    _/  _/_/_/    _/      _/     
 *
 *                           _/_/_/_/_/    _/_/  
 *                              _/      _/    _/ 
 *                             _/      _/    _/  
 *                            _/      _/    _/   
 *                           _/        _/_/      
 *
 *                      _/    _/  _/_/_/_/  _/      _/
 *                     _/    _/  _/          _/  _/   
 *                    _/_/_/_/  _/_/_/        _/      
 *                   _/    _/  _/          _/  _/     
 *                  _/    _/  _/_/_/_/  _/      _/    
 *                                                    
 *
 *    The goal of this program is to convert a program written in language 
 *  assembly to hexa, ready to put in the RAM of the processor we have created.
 * Usage: ./asm input_file.asm outputfile.bytes
 ******************************************************************************/

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <stdint.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/file.h>

//description of the language
#define NOR 0
#define ADD 1
#define STA 2
#define JCC 3
#define JMP 4
#define TGT 5
#define TLT 6
#define TEQ 7
#define VAR 8

#define VALUE_LENGTH 8
#define INSTRUCTION_LENGTH 3
//usually, VAR LENGTH = VALUE_LENGTH + INSTRUCTION_LENGTH
#define VAR_LENGTH 11 

enum FSM {
  INSTRUCT,
  SPACE,
  VALUE,
  EOL
};

int decode_instruction(char * instruction) {
  if( ! strcmp(instruction, "NOR") ) return NOR;
  if( ! strcmp(instruction, "ADD") ) return ADD;
  if( ! strcmp(instruction, "STA") ) return STA;
  if( ! strcmp(instruction, "JCC") ) return JCC;
  if( ! strcmp(instruction, "JMP") ) return JMP; //jump
  if( ! strcmp(instruction, "TGT") ) return TGT; //greater than
  if( ! strcmp(instruction, "TLT") ) return TLT; //lower than
  if( ! strcmp(instruction, "TEQ") ) return TEQ; //equal
  if( ! strcmp(instruction, "VAR") ) return VAR; //equal
  return -1;
}

int main(int argc, char const *argv[])
{
  //opening of the files
  if(argc <= 1) {
    printf("You should use this program with the following arguments :\n");
    printf("\t ./dtm input_file target_serial_port \n");
    printf("\t example : ./asm input_file.asm outputfile.bytes \n");
    return -1;
  } 

  const char * input_file = argv[1];
  int in_f = open(input_file,  O_RDONLY);

  if (in_f <= 0) {
    printf ("error %d opening %s: %s \n", errno, input_file, strerror (errno));
    return -1;
  }

  flock(in_f, LOCK_EX);  // Lock the file . . .

  const char * output_file = argv[2];
  remove(output_file);
  int out_f = open(output_file,  O_WRONLY | O_CREAT);

  if (out_f <= 0) {
    printf ("error %d opening %s: %s \n", errno, output_file, strerror (errno));
    return -1;
  }
  flock(out_f, LOCK_EX);  // Lock the file . . .

  //parser

  int state = INSTRUCT;
  char instruction [3] = "";
  char value [VAR_LENGTH] = "";
  char temp = ' ';

  int ins = 0;
  int val = 0;

  uint32_t output = 0;
  char outputHex[5] = "";

  int n = 1;

  while (n > 0) {
    switch(state) {
      case INSTRUCT:
        strcpy(instruction, "");
        ins = -1;
        n = read (in_f, instruction, INSTRUCTION_LENGTH);
        ins = decode_instruction(instruction);
        printf("Instruction : %s", instruction);

        state = SPACE;
        break;
      case SPACE:
        n = read (in_f, instruction, 1);
        printf(" ");
        state = VALUE;
        break;
      case VALUE:
        strcpy( value, "");
        if(ins != VAR) {
          n = read (in_f, value, VALUE_LENGTH);
          value[n] = 0;
        } else {
          n = read (in_f, value, VAR_LENGTH);
          value[n] = 0;
        }
        value[n] = 0;
        printf("%s \n", value);

        val = atoi (value);
        state = EOL;
        break;
      case EOL:
        n = read (in_f, &temp, 1);
        if( temp == '\n') {
          //overflow security
          val = val & (VALUE_LENGTH * VALUE_LENGTH - 1);
          if(ins != VAR) {
            output = ins << VALUE_LENGTH | val;
          } else {
            output = val;
          }

          printf("%03u = %03x\n",output, output );
          sprintf(outputHex, "%03x\n", output);
          write(out_f, outputHex, strlen(outputHex));

          state = INSTRUCT;
        }
        break;
      default:  
      break;
    }
  }
  printf("fin du programme\n");
  flock(in_f, LOCK_UN);
  flock(out_f, LOCK_UN);
  close(in_f);
  close(out_f);
  
  return 0;
}