# TODO
- byte_code
    - static methods
    - interface methods
    - dynamic methods
- basic objects
    - Implement java/lang/Object
    - Implement java/lang/String
    - Implement java/lang/StringBuilder
- Add native method support
- Add garbage collection
- Add exception support
- Add cli support (in/out)
- Add fio support
- Add thread support

# MRjvm

Our implementation of jvm.

## Installation

To install MR.JVM type rake install.

## Structure of codes

MR.JVM will start codes from class Main and static method main. All other source codes must be in this folder or in other subfolders.

## Usage

Type mrjvm [path-to-main-file]
