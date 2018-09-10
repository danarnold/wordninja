require 'zlib'

class Wordninja
  def initialize(filename)
    filename ||= './lists/wordninja_words.txt.gz'
    if filename.end_with?('gz')
      f = Zlib::GzipReader.open(filename)
    else
      f = File.open(filename)
    end
    @words = f.readlines.map(&:chomp)
    f.close

    # Build a cost dictionary, assuming Zipf's law and cost = -math.log(probability).
    @wordcost = @words.each_with_index.map do |e, i|
      [e, Math.log((i+1)*Math.log(@words.size))]
    end.to_h
    @maxword = @words.max_by { |e| e.size }.size
    @split_re = /[^a-zA-Z0-9]+/
  end

  def split(s)
    s = s.downcase
    l = s.split(@split_re).map { |e| split_part(e) }
    l
  end

  # Uses dynamic programming to infer the location of spaces in a string
  # without spaces.
  def split_part(s)
    @s = s

    # Find the best match for the i first characters, assuming cost has
    # been built for the i-1 first characters.
    # Returns a pair (match_cost, match_length).
    def best_match(i)
      max = [0, i-@maxword].max
      candidates = @cost[max...i].reverse
      candidates.each_with_index.map do |c, k|
        [c + @wordcost.fetch(@s[(i-k-1)...i], Float::INFINITY), k+1]
      end.min
    end

    # Build the cost array.
    @cost = [0]
    (1...(s.size+1)).each do |i|
      c, k = best_match(i)
      @cost << c
    end

    # Backtrack to recover the minimal-cost string.
    out = []
    i = @s.size
    while i > 0
      c, k = best_match(i)
      puts "uh-oh cost not equal to cost[i]" unless c == @cost[i]
      out << @s[(i-k)...i]
      i -= k
    end

    out.reverse
  end
end
