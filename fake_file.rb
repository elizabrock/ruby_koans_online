class FakeFile
  CONTENT = "this\nis\na\ntest"

  def self.gimme(x=nil, &block)
    ff = FakeFile.new
    return block.call(ff) if block
    ff
  end

  def initialize
    @lines = CONTENT.split("\n")
  end

  def gets
    @current_line_index ||= 0
    line = @lines[@current_line_index]
    @current_line_index += 1
    "#{line}\n" if line
  end

  def close;end

  def self.exist?(name)
    raise TypeError unless name.respond_to? :to_str
    name.to_str == 'example_file.txt'
  end

  def map(&block)
    @lines.map(&block)
  end

  def inspect
    "#<File:example_file.txt>"
  end
end
