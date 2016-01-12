#include <jni.h>
#include "Main.h"
#include <iostream>

int previous_i = 0;

JNIEXPORT jint JNICALL Java_Main_intMethod(
    JNIEnv *env, jobject obj, jint i) {
    previous_i += (int)i;
  return (i * i) + previous_i;
}

JNIEXPORT char* JNICALL Java_Main_some_char (JNIEnv *env, jobject obj) {
    std::cout << "Ahoj z C." << std::endl;
    char array[] = "Ahoj z C.";
    return array;
}