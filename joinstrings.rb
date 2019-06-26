def jsol(array, length)
  output = []
  builder = ""
  array.each do |e|
    if e.size <= length
      builder += e
    else
      output << builder if builder.size > 0
      output << e
      builder = ""
    end
  end
  output << builder if builder.size > 0
  output
end
