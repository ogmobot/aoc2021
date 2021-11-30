#!/snap/bin/crystal

inputfile: File = File.open("input.txt", "r")
inputfile.read_line # discard first line
product: Int32 = 1
inputfile.each_line do |line|
    product *= (line.split(",").map { |val| val.to_i }).sum
end
puts product
