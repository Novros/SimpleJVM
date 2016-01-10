require_relative 'tag_reader'

module PrimitiveReader
  def read_integer
    integer = {}
    integer[:tag] = TagReader::CONSTANT_INTEGER
    integer[:bytes] = load_bytes(4)

    # calculate integer value from bytes, care on signed value to_i(16) is only for unsigned values
    integer[:value] = [integer[:bytes].scan(/[0-9a-f]{2}/i).reverse.join].pack('H*').unpack('l')[0]
    integer
  end

  def read_float
    float = {}
    float[:tag] = TagReader::CONSTANT_FLOAT
    float[:bytes] = load_bytes(4).to_i(16)
    # calculate float value from bytes
    s = ((float[:bytes] >> 31) == 0) ? 1 : -1
    e = ((float[:bytes] >> 23) & 0xff)
    m = (e == 0) ?
          (float[:bytes] & 0x7fffff) << 1 :
          (float[:bytes] & 0x7fffff) | 0x800000

    float[:value] = (s * m * 2 ** (e - 150)).to_f
    float
  end

  def read_string
    string = {}
    string[:tag] = TagReader::CONSTANT_STRING
    string[:string_index] = load_bytes(2).to_i(16)
    string
  end

  def read_long
    long = {}
    long[:tag] = TagReader::CONSTANT_LONG
    long[:high_bytes] = load_bytes(4).to_i(16)
    long[:low_bytes] = load_bytes(4).to_i(16)

    # calculate long value from low and high bytes
    long[:value] = (long[:high_bytes] << 32) + long[:low_bytes]
    long
  end

  def read_double
    # bytes are same but in double we need to calculate value from low and high bytes
    double = read_long

    s = ((double[:value] >> 63) == 0) ? 1 : -1
    e = ((double[:value] >> 52) & 0x7ff)
    m = (e == 0) ?
           (double[:value] & 0xfffffffffffff) << 1 :
           (double[:value] & 0xfffffffffffff) | 0x10000000000000

    double[:value] = (s * m * 2 ** (e - 1075)).to_f
    double[:tag] = TagReader::CONSTANT_DOUBLE
    double
  end
end
