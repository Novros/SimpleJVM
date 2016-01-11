#include <jni.h>
#include "java_nio_file_InputFile.h"
#include <iostream>
#include <string>
#include <fstream>
#include <cstdio>

using namespace std;

std::ifstream inputStream = null;

/*
 * Class:     java_nio_file_InputFile
 * Method:    open
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_java_nio_file_InputFile_open(JNIEnv *env, jobject obj, jcharArray array) {
	char fileNamechar[] = (char[]) array;
	string fileName = string(fileNamechar);
	inputStream.open(fileName);
}

/*
 * Class:     java_nio_file_InputFile
 * Method:    close
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_java_nio_file_InputFile_close(JNIEnv * env, jobject obj) {
	inpuStream.close();
}

/*
 * Class:     java_nio_file_InputFile
 * Method:    readLine
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jcharArray JNICALL Java_java_nio_file_InputFile_readLine (JNIEnv *en, jobject obj) {
	string line = "";
	if (inputStream.is_open()) {
		getline(inputStream, line);
	}
	return (jcharArray)line;
}

/*
 * Class:     java_nio_file_InputFile
 * Method:    readFile
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jcharArray JNICALL Java_java_nio_file_InputFile_readFile (JNIEnv *env, jobject obj) {
	string file = "";
	string line;
	if(inputStream.is_opne()) {
		while(getline(inputStream, line) ) {
			file += file + "\n";
		}
	}
	return (jcharArray)file;
}
