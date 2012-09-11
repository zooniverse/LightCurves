##
 # Franc Paul
 #
 # convert a ruby hash to coffescript object
 ##

module HashToCS

=begin
usage:
proc = Proc.new do |output|
coffee_script_file.puts output
end

HashToCs.convert(ruby_hash, 2, proc)
=end
  
  defaultProc = Proc.new do |output|
    print output
  end

  #input is a Ruby hash
  #spaces is an integer count of spaces to be used as a prefix string for whitespace significance
  #proc acts on the output
  def HashToCS.convert(input, spaces=0, proc=defaultProc)
    spaces = " " * spaces
    case input
    when String
      q = if input =~ /\n/
        '"""'
      else
        '"'
      end
      proc.call spaces + q + input + q + "\n"
    when Array
      proc.call spaces + "[\n"
      input.each do |a|
        convert(a, spaces.size + 2, proc)
      end
      proc.call spaces + "]\n"
    when Hash
      proc.call spaces + "{\n"
      input.each do |k, v|
        proc.call spaces + " #{k}:\n"
        convert(v, spaces.size + 4, proc)
      end
      proc.call spaces + "}\n"
    else
      proc.call spaces + input.to_s + "\n"
    end
  end

end

