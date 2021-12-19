import std/sets
import std/sequtils
import std/strutils

const PROBE_RANGE = 1000
const TOLERANCE = 4

type
    Point     = tuple[x, y, z: int]
    ProbeData = tuple[loc: Point, facing: int]
    Probe     = tuple[
        beacons: HashSet[Point],
        probelocs: HashSet[Point]]

### program logic ###

func add_points(a: Point, b: Point): Point =
    (a[0] + b[0], a[1] + b[1], a[2] + b[2])
func sub_points(a: Point, b: Point): Point =
    (a[0] - b[0], a[1] - b[1], a[2] - b[2])
func in_range(a: Point, b: Point): bool =
    abs(a[0] - b[0]) <= PROBE_RANGE and abs(a[1] - b[1]) <= PROBE_RANGE and abs(a[2] - b[2]) <= PROBE_RANGE

func do_rotation(p: Point, i: int): Point =
    let (x, y, z) = p
    [
        ( x, y, z), ( x, z, -y), ( x, -y, -z), ( x, -z, y),
        (-x, z, y), (-x, y, -z), (-x, -z, -y), (-x, -y, z),
        ( y, z, x), ( y, x, -z), ( y, -z, -x), ( y, -x, z),
        (-y, x, z), (-y, z, -x), (-y, -x, -z), (-y, -z, x),
        ( z, x, y), ( z, y, -x), ( z, -x, -y), ( z, -y, x),
        (-z, y, x), (-z, x, -y), (-z, -y, -x), (-z, -x, y)
    ][i]

func do_unrotation(p: Point, i: int): Point =
    let (x, y, z) = p
    [
        ( x, y, z), ( x, -z, y), ( x, -y, -z), ( x,  z,-y),
        (-x, z, y), (-x,  y,-z), (-x, -z, -y), (-x, -y, z),
        ( z, x, y), ( y,  x,-z), (-z,  x, -y), (-y,  x, z),
        ( y,-x, z), (-z, -x, y), (-y, -x, -z), ( z, -x,-y),
        ( y, z, x), (-z,  y, x), (-y, -z,  x), ( z, -y, x),
        ( z, y,-x), ( y, -z,-x), (-z, -y, -x), (-y,  z,-x)
    ][i]

for i in countup(0, 23):
    assert do_unrotation(do_rotation((1, 2, 3), i), i) == (1, 2, 3), $i
    assert do_rotation(do_unrotation((1, 2, 3), i), i) == (1, 2, 3), $i

func it_all_lines_up(probe_a: Probe, probe_b: Probe, b_facing: int, b_loc: Point): bool =
    #[
    Asserts that if each point in probe_b is transformed, it matches probe_a.
    There must be at least TOLERANCE points in common.
    ]#
    var beacon_count = 0
    for b in probe_b.beacons:
        let new_b = do_rotation(sub_points(b, b_loc), b_facing)
        # this is how the point in b *should* appear to probe a
        if new_b in probe_a.beacons:
            beacon_count += 1
            if beacon_count >= TOLERANCE:
                return true
        else:
            for pl in probe_a.probelocs:
                if in_range(pl, new_b): return false
    return false

func line_up_probes(probe_a: Probe, probe_b: Probe): ProbeData =
    #[
    Lines up two probes by finding TOLERANCE points in common.
    Returns the offset/facing of probe_b or [0, 0, 0], 0 on failure
    ]#
    for a in probe_a.beacons:
        for b in probe_b.beacons:
            for b_facing in countup(0, 23):
                let potential_b_loc = sub_points(b, do_unrotation(a, b_facing))
                if it_all_lines_up(probe_a, probe_b, b_facing, potential_b_loc):
                    return (potential_b_loc, b_facing)
    return ((0, 0, 0), 0)

func transform_all_points(probe_b: Probe, b_loc: Point, b_facing: int): Probe =
    (probe_b.beacons.map(
        proc (b: Point): Point =
            do_rotation(sub_points(b, b_loc), b_facing)),
    probe_b.probelocs.map(
        proc (loc: Point): Point =
            do_rotation(sub_points(loc, b_loc), b_facing)))

proc merge_probe_list(raw_probes: seq[Probe]): Probe =
    var probes = toSeq(raw_probes)
    # find matching pair
    while probes.len > 1:
        block outer:
            for i in countup(0, probes.len - 1):
                for j in countup(i + 1, probes.len - 1):
                    # probes[i] is absolute position, probes[j] relative
                    let trans = line_up_probes(probes[i], probes[j])
                    if trans != ((0, 0, 0), 0):
                        let (b_loc, b_facing) = trans
                        let transformed = transform_all_points(probes[j], b_loc, b_facing)
                        let megaprobe: Probe =
                            (probes[i].beacons + transformed.beacons,
                            probes[i].probelocs + transformed.probelocs)
                        echo "Merged probes ", $i, " (len=", $probes[i].beacons.len, ") and ", $j, " (len=", $probes[j].beacons.len, ") (", $(probes.len - 1), " remaining) - megaprobe length ", megaprobe.beacons.len
                        # j > i guaranteed
                        probes.add(megaprobe)
                        probes.delete(j) # .delete preserves order
                        probes.delete(i) # .del swaps last element to index i
                        break outer
            echo "Couldn't merge probes :("
            return (initHashSet[Point](), initHashSet[Point]())
    return probes[0]

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
    var accumulator: Probe = (
        initHashSet[Point](),
        toHashSet([(0, 0, 0)]))
    for raw_line in lines(filename):
        var line: string = raw_line
        line.stripLineEnd
        if line.startswith("---"):
            # discard probe identifier
            discard 0
        elif line.len == 0:
            # record separator
            probes.add(accumulator)
            accumulator = (initHashSet[Point](), toHashSet([(0, 0, 0)]))
        else:
            # data
            accumulator.beacons.incl(parse_point(line))
    probes.add(accumulator)
    return probes

### main function ###

proc main(): int {.discardable.} =
    let probes = get_probes("input19.txt")
    let (all_beacons, all_probes) =  merge_probe_list(probes)
    # part 1
    echo all_beacons.len
    # part 2
    echo greatest_manhattan(all_probes.toseq)
    return 0

main()
