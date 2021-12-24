#!/usr/bin/env crystal

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
            # set these anyway to help Crystal infer types
            @on = false
            @xrange = 0..0
            @yrange = 0..0
            @zrange = 0..0
        end
    end
    def valid_part1? ( )
        [ @xrange, @yrange, @zrange ].all? { |r|
            [r.begin, r.end].all? { |x| x >= -50 && x <= 50 }
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
    zvals = relevant.map &.zrange.begin + relevant.map &.zrange.end.succ
    length : Int64 = 0
    zvals.sort.each_cons_pair do |zleft, zright|
        overlap = relevant.select &.zrange.includes? zleft
        if overlap.size > 0 && overlap[-1].on
            length += (zright - zleft)
        end
    end
    length
end

def areasweep ( xval : Int32, commands : Array(Command) ) : Int64
    relevant = commands.select &.relevant? xval
    yvals = relevant.map &.yrange.begin + relevant.map &.yrange.end.succ
    area : Int64 = 0
    yvals.sort.each_cons_pair do |yleft, yright|
        length = lengthsweep( xval, yleft, relevant )
        area += (length * (yright - yleft))
    end
    area
end

def volumesweep ( commands : Array(Command) ) : Int64
    xvals = commands.map &.xrange.begin + commands.map &.xrange.end.succ
    volume : Int64 = 0
    xvals.sort.each_cons_pair do |xleft, xright|
        area = areasweep( xleft, commands )
        volume += (area * (xright - xleft))
    end
    volume
end

def main ( )
    input = File.read_lines("input22.txt").map { |line| Command.new line }
    puts volumesweep input.select &.valid_part1?
    puts volumesweep input
end

main

# The Ruby-like syntax of Crystal is comfortable to write in, although it
# sometimes makes me nervous to leave out the brackets that other languages
# would require. Static typing and `@` sigil to identify class variables are
# also nice features.
# I wonder whether I should try to generalise the "sweep" functions to minimise
# repetition. It's probably not worth it...
