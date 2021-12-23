const std = @import("std");
const print = std.debug.print;
const StateQueue = std.PriorityQueue(State, void, spent_less_than);
const StateSet = std.AutoHashMap([@enumToInt(Space.NUM_SPACES)]u8, bool);

const input = @embedFile("input23.txt");

const Space = enum {
    HALLWAY_0,
    HALLWAY_1,
    HALLWAY_2, // not allowed part 1
    HALLWAY_3,
    HALLWAY_4, // not allowed part 1
    HALLWAY_5,
    HALLWAY_6, // not allowed part 1
    HALLWAY_7,
    HALLWAY_8, // not allowed part 1
    HALLWAY_9,
    HALLWAY_10,
    HOME_A0,
    HOME_A1, // A0 is bottom, A1 is top
    HOME_B0,
    HOME_B1,
    HOME_C0,
    HOME_C1,
    HOME_D0,
    HOME_D1,
    NUM_SPACES,

    fn is_hallway(self: Space) bool {
        return switch (self) {
            .HALLWAY_0, .HALLWAY_1, .HALLWAY_2, .HALLWAY_3, .HALLWAY_4, .HALLWAY_5, .HALLWAY_6, .HALLWAY_7, .HALLWAY_8, .HALLWAY_9, .HALLWAY_10 => true,
            else => false,
        };
    }
    fn is_home(self: Space) bool {
        return switch (self) {
            .HOME_A0, .HOME_A1, .HOME_B0, .HOME_B1, .HOME_C0, .HOME_C1, .HOME_D0, .HOME_D1 => true,
            else => false,
        };
    }
    fn blocks_doorway(self: Space) bool {
        return self == Space.HALLWAY_2 or self == Space.HALLWAY_4 or self == Space.HALLWAY_6 or self == Space.HALLWAY_8;
    }
};

const State = struct {
    spaces: [@enumToInt(Space.NUM_SPACES)]u8,
    spent: u32,
    fn stringrep(self: State) []u8 {
        return self.spaces[0..];
    }
};

fn get_initial_state(s: []const u8) State {
    var result: State = undefined;
    var index = @enumToInt(Space.HALLWAY_0);
    while (index <= @enumToInt(Space.HALLWAY_10)) {
        result.spaces[index] = '.';
        index += 1;
    }
    result.spaces[@enumToInt(Space.HOME_A0)] = s[45];
    result.spaces[@enumToInt(Space.HOME_B0)] = s[47];
    result.spaces[@enumToInt(Space.HOME_C0)] = s[49];
    result.spaces[@enumToInt(Space.HOME_D0)] = s[51];
    result.spaces[@enumToInt(Space.HOME_A1)] = s[31];
    result.spaces[@enumToInt(Space.HOME_B1)] = s[33];
    result.spaces[@enumToInt(Space.HOME_C1)] = s[35];
    result.spaces[@enumToInt(Space.HOME_D1)] = s[37];
    result.spent = 0;
    return result;
}

// bfs the state space

fn connected(a: Space, b: Space) bool {
    return switch (a) {
        .HALLWAY_0 => (b == .HALLWAY_1),
        .HALLWAY_1 => ((b == .HALLWAY_0) or (b == .HALLWAY_2)),
        .HALLWAY_2 => ((b == .HALLWAY_1) or (b == .HALLWAY_3) or (b == .HOME_A1)),
        .HALLWAY_3 => ((b == .HALLWAY_2) or (b == .HALLWAY_4)),
        .HALLWAY_4 => ((b == .HALLWAY_3) or (b == .HALLWAY_5) or (b == .HOME_B1)),
        .HALLWAY_5 => ((b == .HALLWAY_4) or (b == .HALLWAY_6)),
        .HALLWAY_6 => ((b == .HALLWAY_5) or (b == .HALLWAY_7) or (b == .HOME_C1)),
        .HALLWAY_7 => ((b == .HALLWAY_6) or (b == .HALLWAY_8)),
        .HALLWAY_8 => ((b == .HALLWAY_7) or (b == .HALLWAY_9) or (b == .HOME_D1)),
        .HALLWAY_9 => ((b == .HALLWAY_8) or (b == .HALLWAY_10)),
        .HALLWAY_10 => (b == .HALLWAY_9),
        .HOME_A1 => ((b == .HALLWAY_2) or (b == .HOME_A0)),
        .HOME_A0 => (b == .HOME_A1),
        .HOME_B1 => ((b == .HALLWAY_4) or (b == .HOME_B0)),
        .HOME_B0 => (b == .HOME_B1),
        .HOME_C1 => ((b == .HALLWAY_6) or (b == .HOME_C0)),
        .HOME_C0 => (b == .HOME_C1),
        .HOME_D1 => ((b == .HALLWAY_8) or (b == .HOME_D0)),
        .HOME_D0 => (b == .HOME_D1),
        else => false,
    };
}

fn cost(identity: u8, distance: i32) u32 {
    const res = switch (identity) {
        'A' => distance,
        'B' => 10 * distance,
        'C' => 100 * distance,
        'D' => 1000 * distance,
        else => 0,
    };
    return @bitCast(u32, res);
}

fn distance_to(from: Space, to: Space, state: State, visited: u64) i32 {
    // returns -1 if impossible
    // for this scenario, bfs == dfs
    if (from == to) return 0;
    if (state.spaces[@enumToInt(to)] != '.') return -1;
    var index = @enumToInt(Space.HALLWAY_0);
    while (index < @enumToInt(Space.NUM_SPACES)) {
        if (connected(@intToEnum(Space, index), from)) {
            if (0 == (visited & (@as(u64, 1) << index))) {
                const tmp = distance_to(@intToEnum(Space, index), to, state, (visited | (@as(u64, 1) << @enumToInt(from))));
                if (tmp != -1) return (tmp + 1);
            }
        }
        index += 1;
    }
    return -1;
}

fn allowed_move(from: Space, to: Space, state: State) bool {
    // amphipods won't stop outside doors
    // amphipods in the hallway can only move into their own room
    // amphipods can't move into a room containing a foreign amphipod
    if (from == to) return false;
    const identity: u8 = state.spaces[@enumToInt(from)];
    if (from.is_hallway()) {
        switch (to) {
            .HOME_A0 => return identity == 'A',
            .HOME_A1 => return identity == 'A' and state.spaces[@enumToInt(Space.HOME_A0)] != 0,
            .HOME_B0 => return identity == 'B',
            .HOME_B1 => return identity == 'B' and state.spaces[@enumToInt(Space.HOME_B0)] != 0,
            .HOME_C0 => return identity == 'C',
            .HOME_C1 => return identity == 'C' and state.spaces[@enumToInt(Space.HOME_C0)] != 0,
            .HOME_D0 => return identity == 'D',
            .HOME_D1 => return identity == 'D' and state.spaces[@enumToInt(Space.HOME_D0)] != 0,
            else => return false,
        }
    } else if (from.is_home()) {
        return (!to.blocks_doorway());
    } else {
        return false;
    }
}

fn next_moves(possible_moves: *StateQueue, seen_states: *StateSet) !void {
    // pulls the front state from the queue and finds next possible moves,
    // adding them to the queue.
    const current = possible_moves.remove();
    var index: u8 = 0;
    while (index < @enumToInt(Space.NUM_SPACES)) { // from
        if (current.spaces[index] == '.') {
            index += 1;
            continue;
        }
        var subindex: u8 = 0;
        while (subindex < @enumToInt(Space.NUM_SPACES)) { // to
            if (current.spaces[subindex] != '.') {
                subindex += 1;
                continue;
            }
            if (allowed_move(@intToEnum(Space, index), @intToEnum(Space, subindex), current)) {
                const distance = distance_to(@intToEnum(Space, index), @intToEnum(Space, subindex), current, 0);
                if (distance != -1) {
                    var new_state = current;
                    new_state.spent += cost(new_state.spaces[index], distance);
                    new_state.spaces[subindex] = new_state.spaces[index];
                    new_state.spaces[index] = '.';
                    if (seen_states.get(new_state.spaces)) |val| {
                        _ = val;
                    } else {
                        try seen_states.put(new_state.spaces, true);
                        try possible_moves.add(new_state);
                    }
                }
            }
            subindex += 1;
        }
        index += 1;
    }
    return;
}

fn winning_state(state: State) bool {
    if (state.spaces[@enumToInt(Space.HOME_A0)] == 'A' and state.spaces[@enumToInt(Space.HOME_A1)] == 'A') {
        if (state.spaces[@enumToInt(Space.HOME_B0)] == 'B' and state.spaces[@enumToInt(Space.HOME_B1)] == 'B') {
            if (state.spaces[@enumToInt(Space.HOME_C0)] == 'C' and state.spaces[@enumToInt(Space.HOME_C1)] == 'C') {
                if (state.spaces[@enumToInt(Space.HOME_D0)] == 'D' and state.spaces[@enumToInt(Space.HOME_D1)] == 'D') {
                    return true;
                }
            }
        }
    }
    return false;
}

fn spent_less_than(context: void, a: State, b: State) std.math.Order {
    _ = context;
    return std.math.order(a.spent, b.spent);
}

pub fn main() !void {
    const initial_state = get_initial_state(input);

    var allocator = std.heap.page_allocator;
    var possible_moves = StateQueue.init(allocator, {});
    try possible_moves.add(initial_state);

    // part 1
    var seen_states = StateSet.init(allocator);
    var counter: u32 = 0;
    while (possible_moves.peek()) |state| {
        if (winning_state(state)) {
            print("{any}\n", .{state.spent});
            return;
        } else {
            //print("{any}\n", .{state.spent});
            counter += 1;
            if (counter % 10000 == 0) {
                print("Step {any}\n", .{counter});
                print("  (spent up to {any})\n", .{state.spent});
            }
            try next_moves(&possible_moves, &seen_states);
        }
    }
    print("No solution found!\n", .{});
    return;
}

// 25233 is not the right answer
