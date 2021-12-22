#!/snap/bin/crystal

class Command
    property on, xrange, yrange, zrange
    def initialize ( s )
        if m = /(?<onoff>on|off) x=(?<xmin>.+)\.\.(?<xmax>.+),y=(?<ymin>.+)\.\.(?<ymax>.+),z=(?<zmin>.+)\.\.(?<zmax>.+)/.match s
            @on = (m.["onoff"] == "on")
            @xrange = (m.["xmin"].to_i)..(m.["xmax"].to_i)
            @yrange = (m.["ymin"].to_i)..(m.["ymax"].to_i)
            @zrange = (m.["zmin"].to_i)..(m.["zmax"].to_i)
        else
            @on = false
            @xrange = 0..0
            @yrange = 0..0
            @zrange = 0..0
        end
    end
    def valid_part1? ()
        [@xrange.begin, @yrange.begin, @zrange.begin,
        @xrange.end, @yrange.end, @zrange.end].all? { |x|
            (x >= -50) && (x <= 50)
        }
    end
end

def part1( commands : Array(Command) ) : Int32
    # naive algo: dump everything into a hash map
    reactor = Hash(Tuple(Int32, Int32, Int32), Bool).new { false }
    (commands.select { |x| x.valid_part1? }).each do |command|
        command.xrange.each do |x|
            command.yrange.each do |y|
                command.zrange.each do |z|
                    reactor[{x, y, z}] = command.on
                end
            end
        end
    end
    reactor.values.count { |x| x }
end

def lengthsweep ( xval : Int32, yval : Int32, commands : Array(Command) ) : Int64
    relevant = commands.select { |x|
        (x.xrange.includes? xval) && (x.yrange.includes? yval) }
    zvals = (
        relevant.map { |x| x.zrange.begin } + commands.map { |x| x.zrange.end + 1 }
    ).sort
    length : Int64 = 0
    zvals.each_cons_pair do |zleft, zright|
        overlap = relevant.select { |x| x.zrange.includes? zleft }
        if overlap.size > 0 && overlap[-1].on
            length += (zright - zleft)
        end
    end
    #puts "length=", length
    length
end

def areasweep( xval : Int32, commands : Array(Command) ) : Int64
    relevant = commands.select { |x| x.xrange.includes? xval }
    yvals = (
        relevant.map { |x| x.yrange.begin } + commands.map { |x| x.yrange.end + 1 }
    ).sort
    area : Int64 = 0
    yvals.each_cons_pair do |yleft, yright|
        length = lengthsweep( xval, yleft, commands )
        area += (length * (yright - yleft))
    end
    #puts "area=", area
    area
end

def volumesweep( commands : Array(Command) ) : Int64
    xvals = (
        commands.map { |x| x.xrange.begin } + commands.map { |x| x.xrange.end + 1}
    ).sort
    volume : Int64 = 0
    xvals.each_cons_pair do |xleft, xright|
        area = areasweep( xleft, commands )
        volume += (area * (xright - xleft))
    end
    volume
end

def main()
    input = File.read_lines("input22.txt").map do |line|
        Command.new line
    end
    #puts part1 input
    puts volumesweep input
end

main()
