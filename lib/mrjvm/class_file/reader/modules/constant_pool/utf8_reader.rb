module UTF8Reader
  def read_utf8
    utf8 = {}
    utf8[:tag] = TagReader::CONSTANT_UTF8
    utf8[:length] = load_bytes(2).to_i(16)
    utf8[:bytes] = ''

    utf8[:length].times do
      utf8[:bytes] += load_bytes(1).to_i(16).chr
    end

    utf8
  end
end
