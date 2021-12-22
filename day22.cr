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
            raise "Error parsing line: #{s}"
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
    def relevant? ( xval )
        @xrange.includes? xval
    end
    def relevant? ( xval, yval )
        (@xrange.includes? xval) && (@yrange.includes? yval)
    end
end

def lengthsweep ( xval : Int32, yval : Int32, commands : Array(Command) ) : Int64
    relevant = commands.select &.relevant? xval, yval
    zvals = (
        (relevant.map &.zrange.begin) + relevant.map { |com| com.zrange.end + 1 }
    ).sort
    length : Int64 = 0
    zvals.each_cons_pair do |zleft, zright|
        overlap = relevant.select { |x| x.zrange.includes? zleft }
        if overlap.size > 0 && overlap[-1].on
            length += (zright - zleft)
        end
    end
    length
end

def areasweep ( xval : Int32, commands : Array(Command) ) : Int64
    relevant = commands.select &.relevant? xval
    yvals = (
        (relevant.map &.yrange.begin) + relevant.map { |com| com.yrange.end + 1 }
    ).sort
    area : Int64 = 0
    yvals.each_cons_pair do |yleft, yright|
        length = lengthsweep( xval, yleft, relevant )
        area += (length * (yright - yleft))
    end
    area
end

def volumesweep ( commands : Array(Command) ) : Int64
    xvals = (
        commands.map &.xrange.begin + commands.map { |com| com.xrange.end + 1 }
    ).sort
    volume : Int64 = 0
    xvals.each_cons_pair do |xleft, xright|
        area = areasweep( xleft, commands )
        volume += (area * (xright - xleft))
    end
    volume
end

def main ( )
    input = File.read_lines("input22.txt").map do |line|
        Command.new line
    end
    puts volumesweep input.select &.valid_part1?
    puts volumesweep input
end

main
