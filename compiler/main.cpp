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

//description of the language
#define NOR 0
#define ADD 1
#define STA 2
#define JCC 3
#define JMP 4
#define TGT 5
#define TLT 6
#define TEQ 7

#define VALUE_LENGTH 8

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
  int in_f = open(input_file,  O_RDONLY);

  if (in_f < 0) {
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

  //parser

  int state = INSTRUCT;
  char instruction [3] = "";
  char value [VALUE_LENGTH];
  char temp;

  int ins = 0;
  int val = 0;

  int output = 0;
  char outputHex[5] = "";

  int n = 1;
  while (n > 0) {
    switch(state) {
      case INSTRUCT:
        n = read (in_f, instruction, 3);
        ins = decode_instruction(instruction);
        state = SPACE;
        break;
      case SPACE:
        n = read (in_f, instruction, 1);
        state = VALUE;
        break;
      case VALUE:
        n = read (in_f, &value, VALUE_LENGTH);
        val = atoi(value);
        state = EOL;
        break;
      case EOL:
        n = read (in_f, &temp, 1);
        if( temp == '\n') {
          //overflow security
          val = val & (VALUE_LENGTH * VALUE_LENGTH - 1);

          output = ins << VALUE_LENGTH | val;
          printf("%03x\n", output );
          sprintf(outputHex, "%03x\n", output);
          write(out_f, outputHex, strlen(outputHex));

          state = INSTRUCT;
        }
        break;
      default:  
      break;
    }
  }

  close(in_f);
  close(out_f);

  return 0;
}