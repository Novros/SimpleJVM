#include "Main.h"

int Java_Main_intMethod(int i) {
  return (i * i);
}

char* Java_Main_some_char () {
    char array[] = "Ahoj z C.";
    return array;
}