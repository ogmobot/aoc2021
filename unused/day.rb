#!/snap/bin/ruby

inputfile = File.open("input.txt", "r")
inputfile.readline # discard first line
product = 1
inputfile.each_line do |line|
    product *= (line.split(",").map { |val| val.to_i }).sum
end
puts product
