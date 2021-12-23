const std = @import("std");
const print = std.debug.warn;

const input = @embedFile("input.txt");

pub fn main() void {
    var lines = std.mem.tokenize(input, "\n");
    _ = lines.next(); // discard first line
    var product: u32 = 1;
    while (lines.next()) |line| {
        var sum: u32 = 0;
        var words = std.mem.tokenize(line, ", ");
        while (words.next()) |s| {
            if (std.fmt.parseInt(u32, s, 10)) |val| {
                sum += val;
            } else |err| {
                // do nothing
            }
        }
        product *= sum;
    }
    print("{}\n", .{product});
    return;
}
