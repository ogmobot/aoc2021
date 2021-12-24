const std = @import("std");
const print = std.debug.print;
const StateQueue = std.PriorityQueue(State, void, spent_less_than);
const StateSet = std.AutoHashMap(SimpleState, bool);

const input = @embedFile("input23.txt");

const Amphipod = struct {
    letter: u8,
    fn home(self: Amphipod) u8 {
        return switch (self.letter) {
            'A' => 2,
            'B' => 4,
            'C' => 6,
            'D' => 8,
            else => 255,
        };
    }
};

const SimpleState = struct {
    hallway: [11]?Amphipod,
    slots: [4][4]?Amphipod,
};

const State = struct {
    hallway: [11]?Amphipod,
    slots: [4][4]?Amphipod,
    slot_depth: u8,
    spent: usize,
    num_moves: usize,
    fn solved(self: State) bool {
        for ([_]usize{ 0, 1, 2, 3 }) |slot_index| {
            var depth_index: usize = 0;
            while (depth_index < self.slot_depth) {
                if (self.slots[slot_index][depth_index]) |a| {
                    if (a.letter != 'A' + slot_index) {
                        return false;
                    }
                } else {
                    return false;
                }
                depth_index += 1;
            }
        }
        return true;
    }
    fn get_amphi(self: State, index: usize) ?Amphipod {
        if (blocks_door(index)) { // inside room
            const slot_index = (index / 2) - 1;
            var depth_index: usize = 0;
            while (depth_index < self.slot_depth) {
                if (self.slots[slot_index][depth_index]) |tmp| {
                    return tmp;
                }
                depth_index += 1;
            }
            return null;
        } else { // coming from hallway
            return self.hallway[index];
        }
    }
};

fn spent_less_than(context: void, a: State, b: State) std.math.Order {
    _ = context;
    return std.math.order(a.spent, b.spent);
}

fn move_cost(a: Amphipod, from_loc: usize, to_loc: usize) usize {
    const multiplier: usize = switch (a.letter) {
        'A' => 1,
        'B' => 10,
        'C' => 100,
        'D' => 1000,
        else => 0,
    };
    return multiplier * (if (from_loc > to_loc)
        from_loc - to_loc
    else
        to_loc - from_loc); // can't use std.math.absInt with unsigned ints
}

fn clear_path(from: usize, to: usize, state: State) bool {
    var current = from;
    while (current != to) {
        if (current < to) {
            current += 1;
        } else {
            current -= 1;
        }
        if (state.hallway[current] != null) return false;
    }
    return true;
}

fn blocks_door(index: usize) bool {
    switch (index) {
        2, 4, 6, 8 => return true,
        else => return false,
    }
}

fn move_options(from_loc: usize, state: State) [11]bool {
    var result = [_]bool{false} ** 11;
    const tmp = state.get_amphi(from_loc);
    if (tmp == null) {
        return result;
    }
    const a = tmp.?;
    if (blocks_door(from_loc)) { // currently in a room
        // can only move if not at home or there's a foreign amphi beneath this one
        var foreign = false;
        const slot_index = (a.home() / 2) - 1;
        for (state.slots[slot_index]) |item| {
            if (item != null and item.?.letter != a.letter) {
                foreign = true;
                break;
            }
        }
        if (foreign or slot_index != from_loc) {
            for ([_]usize{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }) |space| {
                if ((!blocks_door(space)) and clear_path(from_loc, space, state))
                    result[space] = true;
            }
        }
        return result;
    } else { // currently in hallway
        // check there's a way back to the door
        if (clear_path(from_loc, a.home(), state)) {
            // check we're allowed to go there
            var depth_index = state.slot_depth;
            while (depth_index > 0) {
                depth_index -= 1;
                const tmp_a = state.slots[(a.home() / 2) - 1][depth_index];
                if (tmp_a == null) {
                    result[a.home()] = true;
                    break;
                } else if (tmp_a.?.letter != a.letter) {
                    result[a.home()] = false;
                    break;
                }
            }
        }
        return result;
    }
    unreachable;
}

fn solve(possible_moves: *StateQueue, seen_states: *StateSet) !usize {
    while (true) {
        const popped = possible_moves.removeOrNull();
        if (popped == null) {
            print("No solution found (exhausted queue).\n", .{});
            return 0;
        }
        const current = popped.?;
        if (current.solved()) return current.spent;
        // skip if already seen
        if (seen_states.get(.{ .hallway = current.hallway, .slots = current.slots }) == null) {
            try seen_states.put(.{ .hallway = current.hallway, .slots = current.slots }, true);
        } else {
            continue;
        }
        // try all possible moves
        var from_loc: usize = 0;
        while (from_loc <= 10) {
            const opts = move_options(from_loc, current);
            for (opts) |can_move, to_loc| {
                if (can_move) {
                    const a = current.get_amphi(from_loc).?;
                    var new_state = current;
                    var new_a = a;
                    if (blocks_door(to_loc)) {
                        // push into slot
                        var depth_index = new_state.slot_depth - 1;
                        while (new_state.slots[(new_a.home() / 2) - 1][depth_index] != null) {
                            depth_index -= 1;
                        }
                        new_state.slots[(new_a.home() / 2) - 1][depth_index] = new_a;
                        new_state.hallway[from_loc] = null;
                        new_state.spent += move_cost(a, 0, depth_index + 1);
                    } else {
                        // move into hallway
                        new_state.hallway[to_loc] = new_a;
                        var depth_index: usize = 0;
                        const slot_index = (from_loc / 2) - 1;
                        while (new_state.slots[slot_index][depth_index] == null) {
                            depth_index += 1;
                        }
                        new_state.slots[slot_index][depth_index] = null;
                        new_state.spent += move_cost(a, 0, depth_index + 1);
                    }
                    new_state.spent += move_cost(a, from_loc, to_loc);
                    new_state.num_moves += 1;
                    try possible_moves.add(new_state);
                }
            }
            from_loc += 1;
        }
    }
    unreachable;
}

fn get_initial_state(s: []const u8) State {
    var result: State = undefined;
    result.slot_depth = 2;
    const magic_numbers = [8]usize{ 31, 33, 35, 37, 45, 47, 49, 51 };
    for (magic_numbers) |val, i| {
        result.slots[i % 4][i / 4] = .{ .letter = s[val] };
    }
    result.hallway = [_]?Amphipod{null} ** 11;
    result.spent = 0;
    result.num_moves = 0;
    return result;
}

fn part2ify(orig: State) State {
    var result = orig;
    result.slot_depth = 4;
    for ([_]u8{ 0, 1, 2, 3 }) |i| {
        result.slots[i][3] = result.slots[i][1];
    }
    for ("DCBA") |c, i| {
        result.slots[i][1] = .{ .letter = c };
    }
    for ("DBAC") |c, i| {
        result.slots[i][2] = .{ .letter = c };
    }
    return result;
}

pub fn main() !void {
    // part 1
    const initial_state = get_initial_state(input);

    var allocator = std.heap.page_allocator;
    var possible_moves = StateQueue.init(allocator, {});
    defer possible_moves.deinit();
    var seen_states = StateSet.init(allocator);
    defer seen_states.deinit();

    try possible_moves.add(initial_state);
    const result = solve(&possible_moves, &seen_states) catch |err| return err;
    print("{any}\n", .{result});

    // part 2
    var part2_state = part2ify(get_initial_state(input));
    while (possible_moves.len > 0) _ = possible_moves.remove();
    seen_states.clearRetainingCapacity();

    try possible_moves.add(part2_state);
    const result_2 = solve(&possible_moves, &seen_states) catch |err| return err;
    print("{any}\n", .{result_2});
    return;
}

// Tough puzzle. I struggled finding a good way to represent the data.
// (Would it have been easier to store the whole thing as a list of strings?)
// Zig feels very C-like. It makes it very easy to solve problems in the same
// way as you could in C, but with nice features like error unions, easier
// memory management, optional types and a nice big standard library.
// (That said, I don't think my solution to this problem is terribly elegant.
// It's basically Dijkstra-ing the space of all possible moves, using an
// annoying implementation of state.)
