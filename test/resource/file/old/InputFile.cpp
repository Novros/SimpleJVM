#include <jni.h>
#include "InputFile.h"
#include <iostream>
#include <string>
#include <fstream>

using namespace std;

std::ifstream inputStream;
std::string line;

JNIEXPORT void JNICALL Java_InputFile_open(JNIEnv *env, jobject obj, char* array) {
    if(array == nullptr) {
        return;
    }
	string fileName = string(array);
	if(inputStream.is_open()) {
	    inputStream.close();
	    line = nullptr;
	}
	inputStream.open(fileName);
}

JNIEXPORT void JNICALL Java_InputFile_close(JNIEnv * env, jobject obj) {
	inputStream.close();
}

JNIEXPORT jint JNICALL Java_InputFile_getLineSize (JNIEnv *, jobject) {
	if (!inputStream.eof()) {
	    std::getline(inputStream, line);
		return line.size();
	} else {
		return -1;
	}
}

JNIEXPORT jchar JNICALL Java_InputFile_readCharLine (JNIEnv *, jobject, int index) {
	return line[index];
}
