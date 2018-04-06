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
    printf("\t ./dtm input_file target_serial_port \n");
    printf("\t example : ./asm input_file.asm outputfile.bytes \n");
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
  char file_readed[10000] = "";

  while (n > 0) {
    switch(state) {
      case INSTRUCT:
        strcpy(instruction, "");
        ins = -1;
        n = read (in_f, instruction, INSTR_HEX_LENGTH);
        ins = decode_instruction(instruction);
        sprintf(file_readed, "%s%s", file_readed, instruction);

        state = SPACE;
        break;
      case SPACE:
        n = read (in_f, &temp, 1);
        sprintf(file_readed, "%s%c", file_readed, temp);

        state = VALUE;
        break;
      case VALUE:
        strcpy( value, "");
        if(ins != VAR) {
          n = read (in_f, value, ADD_HEX_LENGTH);
          sprintf(file_readed, "%s%s", file_readed, value);

          //value[n] = 0;
        } else {
          n = read (in_f, value, VAR_HEX_LENGTH);
          sprintf(file_readed, "%s%s", file_readed, value);

          //value[n] = 0;
        }

        state = EOL;
        break;
      case EOL:
        n = read (in_f, &temp, 1);
        if( temp == '\n') {
          sprintf ( file_readed, "%s\n", file_readed );

          val = (int)strtol(value, NULL, 16);;

          //overflow security
          val = val & ((int)pow(2,VALUE_BIN_LENGTH) - 1);

          if(ins != VAR) {
            output = ins << VALUE_BIN_LENGTH | val;
          } else {
            output = val;
          }

          printf( "instruction %d:\t %06x\t(hex)\n", 
                  counter, 
                  output );
          sprintf( outputHex, "%06u\n", output);
          write( out_f, outputHex, strlen(outputHex));
          counter ++;
          state = INSTRUCT;
        }
        break;
      default:  
      break;
    }
  }
  //printf("Fichier lu: \n%s\n", file_readed);

  printf("End of program\n");

  flock(in_f, LOCK_UN);
  flock(out_f, LOCK_UN);
  close(in_f);
  close(out_f);
  
  return 0;
}