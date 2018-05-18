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
#include <math.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/file.h>


// list of instructions available
//locical operands
#define NOR 0x0
#define LOR 0x1 // logical OR
#define AND 0x2
#define XOR 0x3

//mathematical operands
#define ADD 0x4
#define SUB 0x5
#define DIV 0x6
#define MUL 0x7
#define MOD 0x8 //modulo

//float operands
#define FAD 0x9 // addition 
#define FDI 0xA //division
#define FMU 0xB //multiply

//Casts
#define FTI 0xC //float to int 
#define ITF 0xD //int to float

//UTILS
#define STA 0x10
#define JCC 0x11
#define JMP 0x12 //jump
#define GET 0x13

//TESTS
#define TGT 0x14 //greater than
#define TLT 0x15 //lower than
#define TEQ 0x16 //equal

//intern shit
#define VAR 0x69

#define INSTR_HEX_LENGTH 3
#define ADD_HEX_LENGTH 5
#define VAR_HEX_LENGTH 7

#define INSTR_BIN_LENGTH 5
#define VALUE_BIN_LENGTH 20

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
    printf("\t %s input_file target_serial_port \n", argv[0]);
    printf("\t example : %s input_file.asm outputfile.bytes \n", argv[0]);
    return -1;
  } 

  printf("Beginning of the program\n");

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
  char value [VAR_HEX_LENGTH + 2] = "";
  char temp = ' ';

  int ins = 0;
  int val = 0;

  uint32_t output = 0;
  char outputHex[5] = "";

  int n = 1;
  int counter = 0;
  char file_read[10000] = "";

  while (n > 0) {
    switch(state) {
      case INSTRUCT:
        strcpy(instruction, "");
        ins = -1;
        n = read (in_f, instruction, INSTR_HEX_LENGTH);
        ins = decode_instruction(instruction);
        sprintf(file_read, "%s%s", file_read, instruction);

        state = SPACE;
        break;
      case SPACE:
        n = read (in_f, &temp, 1);
        sprintf(file_read, "%s%c", file_read, temp);

        state = VALUE;
        break;
      case VALUE:
        strcpy( value, "");
        if(ins != VAR) {
          n = read (in_f, value, ADD_HEX_LENGTH);
          sprintf(file_read, "%s%s", file_read, value);

          //value[n] = 0;
        } else {
          n = read (in_f, value, VAR_HEX_LENGTH);
          sprintf(file_read, "%s%s", file_read, value);

          //value[n] = 0;
        }

        state = EOL;
        break;
      case EOL:
        n = read (in_f, &temp, 1);
        if( temp == '\n') {
          sprintf ( file_read, "%s\n", file_read );

          val = (int)strtol(value, NULL, 16);;

          //overflow security
          val = val & ((int)pow(2,VALUE_BIN_LENGTH + INSTR_BIN_LENGTH) - 1);

          if(ins != VAR) {
            output = ins << VALUE_BIN_LENGTH | val;
          } else {
            output = val;
          }

          printf( "instruction %d:\t %07x\t(hex)\n", 
                  counter, 
                  output );
          sprintf( outputHex, "%07x\n", output);
          write( out_f, outputHex, strlen(outputHex));
          counter ++;
          state = INSTRUCT;
        }
        break;
      default:  
      break;
    }
  }
  //printf("Fichier lu: \n%s\n", file_read);

  printf("End of program\n");

  flock(in_f, LOCK_UN);
  flock(out_f, LOCK_UN);
  close(in_f);
  close(out_f);
  
  return 0;
}