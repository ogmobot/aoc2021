function adjs(n)
    # returns indices that are adjacent to n
    # (in a 10 x 10 grid)
    # usually n+1, n-1, n+10, n-10
    result = []
    isleft = true
    isright = true
    istop = true
    isbottom = true
    if n % 10 != 1
        isleft = false
        append!(result, [n-1])
    end
    if n % 10 != 0
        isright = false
        append!(result, [n+1])
    end
    if n > 10
        istop = false
        append!(result, [n-10])
    end
    if n <= 90
        isbottom = false
        append!(result, [n+10])
    end
    if (!isbottom) && (!isleft)
        append!(result, [n+9]) # lower-left
    end
    if (!isbottom) && (!isright)
        append!(result, [n+11]) # lower-right
    end
    if (!istop) && (!isleft)
        append!(result, [n-11]) # upper-left
    end
    if (!istop) && (!isright)
        append!(result, [n-9]) # upper-right
    end
    result
end

function gainenergy(grid)
    # grid is mutable :)
    for (index, value) in enumerate(grid)
        grid[index] = grid[index] + 1
    end
end

function flash(grid)
    fullcharge = []
    flashed = []
    for (index, value) in enumerate(grid)
        if value == 10
            append!(fullcharge, index)
        end
    end
    while !isempty(fullcharge)
        index = pop!(fullcharge)
        for i in adjs(index)
            grid[i] += 1
            if grid[i] == 10 # don't have to worry about adding same one twice
                append!(fullcharge, i)
            end
        end
        append!(flashed, index)
    end
    for index in flashed
        grid[index] = 0
    end
    return length(flashed)
end

function main()
    lines = map(collect, readlines("input11.txt"))
    grid  = map(x->parse(Int, x), permutedims(hcat(lines...)))

    total = 0
    timer = 0
    while true
        gainenergy(grid)
        subtotal = flash(grid)
        total = total + subtotal
        timer += 1
        if timer == 100
            # part 1
            println(total)
        end
        if subtotal == 100
            # part 2
            println(timer)
            break
        end
    end
end

main()
