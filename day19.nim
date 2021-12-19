import std/sets
import std/sequtils
import std/strutils

#const PROBE_RANGE = 1000
const TOLERANCE = 12

type
    Point = tuple[x, y, z: int]
    Probe = HashSet[Point]

### program logic ###

#func add_points(a: Point, b: Point): Point =
    #(a[0] + b[0], a[1] + b[1], a[2] + b[2])
func sub_points(a: Point, b: Point): Point =
    (a[0] - b[0], a[1] - b[1], a[2] - b[2])
#func in_range(a: Point, b: Point): bool =
    #abs(a[0] - b[0]) <= PROBE_RANGE and abs(a[1] - b[1]) <= PROBE_RANGE and abs(a[2] - b[2]) <= PROBE_RANGE

func do_rotation(p: Point, i: int): Point =
    let (x, y, z) = p
    [
        ( x, y, z), ( x, z, -y), ( x, -y, -z), ( x, -z, y),
        (-x, z, y), (-x, y, -z), (-x, -z, -y), (-x, -y, z),
        ( y, z, x), ( y, x, -z), ( y, -z, -x), ( y, -x, z),
        (-y, x, z), (-y, z, -x), (-y, -x, -z), (-y, -z, x),
        ( z, x, y), ( z, y, -x), ( z, -y, -x), ( z, -x, y),
        (-z, y, x), (-z, x, -y), (-z, -x, -y), (-z, -y, x)
    ][i]

func do_unrotation(p: Point, i: int): Point =
    let (x, y, z) = p
    [
        ( x, y, z), ( x, -z, y), ( x, -y, -z), ( x,  z,-y),
        (-x, z, y), (-x,  y,-z), (-x, -z, -y), (-x, -y, z),
        ( z, x, y), ( y,  x,-z), (-z,  x, -y), (-y,  x, z),
        ( y,-x, z), (-z, -x, y), (-y, -x, -z), ( z, -x,-y),
        ( y, z, x), (-z,  y, x), (-z, -y,  x), (-y,  z, x),
        ( z, y,-x), ( y, -z,-x), (-y, -z, -x), ( z, -y,-x)
    ][i]

for i in countup(0, 23):
    assert do_unrotation(do_rotation((1000, 200, 30), i), i) == (1000, 200, 30)


func it_all_lines_up(probe_a: Probe, probe_b: Probe, r: int, offset: Point): bool =
    #[
    Asserts that if probe b has `offset` and rotation `r` relative to probe_a,
    there are at least 12 points in common.
    ]#
    var beacon_count = 0
    for p in probe_b:
        let new_p = sub_points(do_rotation(p, r), offset)
        # this is how the point in a *should* appear to probe b
        #if in_range((0, 0, 0), new_p):
        if (new_p in probe_a):
            beacon_count += 1
        if beacon_count >= TOLERANCE:
            return true
    #else:
    return false

func line_up_probes(probe_a: Probe, probe_b: Probe): tuple[p: Point, r: int] =
    #[
    Lines up two probes by finding TOLERANCE+ points in common.
    Returns the offset or [0, 0, 0], 0 on failure
    ]#
    for a in probe_a:
        for b in probe_b:
            for r in countup(0, 23):
                let potential_offset = sub_points(do_rotation(b, r), a)
                if it_all_lines_up(probe_a, probe_b, r, potential_offset):
                    return (potential_offset, r)
    return ((0, 0, 0), 0)

func transform_all_points(probe_b: Probe, offset: Point, r: int): Probe =
    probe_b.map(
        proc (p: Point): Point =
            sub_points(do_rotation(p, r), offset))

proc merge_probe_list(raw_probes: seq[Probe]): tuple[p: Probe, offsets: seq[Point]] =
    var probes = toSeq(raw_probes)
    var offsets: seq[Point] = @[(0, 0, 0)]
    # find matching pair
    while probes.len > 1:
        #echo probes.map(proc (x: Probe): int = x.len)
        block outer:
            #for i in countup(0, probes.len - 1):
            for i in countdown(probes.len - 1, 0): # counting from top means we see
                for j in countup(0, i - 1):        # the big sets faster
                    let trans = line_up_probes(probes[j], probes[i])
                    if trans != ((0, 0, 0), 0):
                        let (offset, r) = trans
                        echo "offset=", $offset, " r=", $r
                        offsets.add(do_unrotation(offset, r))
                        let megaprobe =
                            probes[j] + transform_all_points(probes[i], offset, r)
                        echo "Merged probes ", $i, " (len=", $probes[i].len, ") and ", $j, " (len=", $probes[j].len, ") (", $(probes.len - 1), " remaining) - megaprobe length ", megaprobe.len
                        echo "offsets=", $offsets
                        # i > j guaranteed
                        probes.delete(i) # .delete preserves order, .del doesn't
                        probes.delete(j)
                        probes.add(megaprobe)
                        break outer
            echo "Couldn't merge probes :("
            return (initHashSet[Point](), @[])
    return (probes[0], offsets)

func manhattan(a: Point, b: Point): int =
    abs(a[0] - b[0]) + abs(a[1] - b[1]) + abs(a[2] - b[2])

func greatest_manhattan(points: seq[Point]): int =
    points.map(
        proc (p: Point): int =
            points.map(proc (q: Point): int = manhattan(p, q)).foldl(if a > b: a else: b)
    ).foldl(if a > b: a else: b)

### parsing logic ###

func parse_point(s: string): Point =
    let nums = s.split(",").map(parseInt)
    (nums[0], nums[1], nums[2])

proc get_probes(filename: string): seq[Probe] =
    let f = open(filename)
    defer: f.close()

    var probes: seq[Probe] = @[]
    var accumulator: Probe = initHashSet[Point]()
    for raw_line in lines(filename):
        var line: string = raw_line
        line.stripLineEnd
        if line.startswith("---"):
            # discard probe identifier
            discard 0
        elif line.len == 0:
            # record separator
            probes.add(accumulator)
            accumulator = initHashSet[Point]()
        else:
            # data
            accumulator.incl(parse_point(line))
    probes.add(accumulator)
    return probes

### main function ###

proc main(): int {.discardable.} =
    # each probe is represented by a set of ponits (the measurements it has taken)
    let raw_probes = get_probes("input.test")
    let probes = @[raw_probes[0], raw_probes[1], raw_probes[4]]
    let (all_beacons, all_probes) =  merge_probe_list(probes)
    # part 1
    echo all_beacons.len
    # part 2
    echo "offsets=", $all_probes
    echo "\n\n", $all_beacons, "\n\n"
    echo greatest_manhattan(all_probes)
    return 0

main()
# 21446 is too high
