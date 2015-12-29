require_relative 'tag_reader'

module PrimitiveReader
  def read_integer
    integer = {}
    integer[:tag] = TagReader::CONSTANT_INTEGER
    integer[:bytes] = load_bytes(4).to_i(16)
    integer
  end

  # TODO: PREVOD FLOAT Z BYTOV NA CISLO PODLA REFERENCIE
  def read_float
    integer = {}
    integer[:tag] = TagReader::CONSTANT_FLOAT
    integer[:bytes] = load_bytes(4)
    integer
  end

  def read_string
    string = {}
    string[:tag] = TagReader::CONSTANT_STRING
    string[:string_index] = load_bytes(2).to_i(16)
    string
  end

  # TODO: PREVOD LONG Z BYTOV NA CISLO PODLA REFERENCIE
  def read_long
    long = {}
    long[:tag] = TagReader::CONSTANT_LONG
    long[:high_bytes] = load_bytes(4).to_i(16)
    long[:low_bytes] = load_bytes(4).to_i(16)
    long
  end

  # TODO: PREVOD DOUBLE Z BYTOV NA CISLO PODLA REFERENCIE
  def read_double
    double = read_long
    double[:tag] = TagReader::CONSTANT_DOUBLE
    double
  end
end
