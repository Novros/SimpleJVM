# TODO
- byte code
    - Check missing operations in byte code execution_core
    - Add support for long values into execution_core
    - Add support of operations for double, float, long (sub, add, div, mul)
    - Add support for array into execution_core and object_heap
    - Add support for bitwise operations
    - Add support for conversions
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

My own implementation of jvm.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mrjvm'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mrjvm 

## Usage

Just build and install mrjvm. Then type mrjvm [file]
