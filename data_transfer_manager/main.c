/*******************************************************************************
 *
 *
 *
 *
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

int set_interface_attribs (int fd, int speed, int parity) {
  struct termios tty;
  memset (&tty, 0, sizeof tty);
  if (tcgetattr (fd, &tty) != 0) {
    printf ("error %d from tcgetattr \n", errno);
    return -1;
  }

  cfsetospeed (&tty, speed);
  cfsetispeed (&tty, speed);

  tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
  // disable IGNBRK for mismatched speed tests; otherwise receive break
  // as \000 chars
  tty.c_iflag &= ~IGNBRK;         // disable break processing
  tty.c_lflag = 0;                // no signaling chars, no echo,
                                  // no canonical processing
  tty.c_oflag = 0;                // no remapping, no delays
  tty.c_cc[VMIN]  = 0;            // read doesn't block
  tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

  tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

  tty.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
                                  // enable reading
  tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
  tty.c_cflag |= parity;
  tty.c_cflag &= ~CSTOPB;
  tty.c_cflag &= ~CRTSCTS;

  if (tcsetattr (fd, TCSANOW, &tty) != 0) {
    printf ("error %d from tcsetattr\n", errno);
    return -1;
  }
  return 0;
}

void set_blocking (int fd, int should_block) {
  struct termios tty;
  memset (&tty, 0, sizeof tty);
  if (tcgetattr (fd, &tty) != 0) {
    printf ("error %d from tggetattr\n", errno);
    return;
  }

  tty.c_cc[VMIN]  = should_block ? 1 : 0;
  tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

  if (tcsetattr (fd, TCSANOW, &tty) != 0)
    printf ("error %d setting term attributes\n", errno);
}

int main(int argc, char const *argv[])
{

  int32_t data [RAM_SIZE] = {0};

  if(argc <= 1) {
    printf("You should use this program with the following arguments :\n");
    printf("\t ./dtm input_file target_serial_port \n");
    printf("\t example : ./dtm my_program.bytes /dev/ttyUSB0 \n");
    return -1;
  } 

  const char * comm_port = argv[2];
  int fd = open(comm_port,  O_RDWR | O_NOCTTY | O_SYNC);

  if (fd < 0) {
    printf ("error %d opening %s: %s \n", errno, comm_port, strerror (errno));
    return -1;
  }

  const char * input_file = argv[1];
  int in_f = open(input_file,  O_RDWR);

  if (in_f < 0) {
    printf ("error %d opening %s: %s \n", errno, input_file, strerror (errno));
    return -1;
  }

  set_interface_attribs (fd, B115200, 0);  // set speed to 115,200 bps, 8n1 (no parity)
  set_blocking (fd, 0);                    // set no blocking
  
  char temp = ' ';
  int32_t value = 0;
  unsigned int i = 0;
  int n = 1;
  char buffer[5] = "";
  strcpy(buffer, "0x");

  printf("Reading data from the file ...\n");

  while(n > 0) { 
    n = read (in_f, &temp, sizeof temp);
    switch(temp) {
      case '\n':
        value = (uint32_t)strtol(buffer, NULL, 0);
        if(value > 0) {
          data[i++] = value;
        }
        strcpy(buffer,  "0x");
        break;
      default:
        sprintf(buffer, "%s%c", buffer, temp);
        break;
    }
  }
  
  printf("Sending data to the target ...\n");
  write (fd, data, sizeof(int32_t) * RAM_SIZE);
  printf("Done ...\n");

  /*
  DEBUG PART - when the target is in broadcast
  n = read (fd, data, sizeof(int32_t) * RAM_SIZE);  // read up to 100 characters if ready to read
  for(int i = 0; i < RAM_SIZE; ++i) {
    printf("%d\n", data[i] );
  } */
  
  return 0;
}

