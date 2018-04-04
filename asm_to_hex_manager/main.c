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


#define RAM_SIZE 64

int main(int argc, char const *argv[])
{

  if(argc <= 1) {
    printf("You should use this program with the following arguments :\n");
    printf("\t ./dtm input_file target_serial_port \n");
    printf("\t example : ./asm input_file.asm outputfile.bytes \n");
    return -1;
  } 

  const char * input_file = argv[1];
  int in_f = open(input_file,  O_RDWR);

  if (in_f < 0) {
    printf ("error %d opening %s: %s \n", errno, input_file, strerror (errno));
    return -1;
  }

  const char * output_file = argv[2];
  int fd = open(output_file,  O_RDWR);

  if (fd < 0) {
    printf ("error %d opening %s: %s \n", errno, output_file, strerror (errno));
    return -1;
  }

  return 0;
}