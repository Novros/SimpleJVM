#include <jni.h>
#include <stdio.h>
#include "java_io_PrintStream.h"

JNIEXPORT void JNICALL Java_java_io_PrintStream_println(JNIEnv *env, jobject obj, jstring str) {
    printf(str);
}
