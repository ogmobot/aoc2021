#!/usr/bin/julia

function adjs(n, dims)
    # returns indices that are adjacent to n
    # in a 2D grid with dimension `dims`
    height, width = dims
    result = []
    isleft = true
    isright = true
    if n % width != 1
        isleft = false
        append!(result, [n-1])
    end
    if n % width != 0
        isright = false
        append!(result, [n+1])
    end
    if n > width
        append!(result, [n-width])
        if !isleft
            append!(result, [n-width-1])
        end
        if !isright
            append!(result, [n-width+1])
        end
    end
    if n <= (height-1)*width
        append!(result, [n+width])
        if !isleft
            append!(result, [n+width-1])
        end
        if !isright
            append!(result, [n+width+1])
        end
    end
    result
end

function update(grid)
    # grid is mutable :)
    fullcharge = []
    flashed = []
    for (index, value) in enumerate(grid)
        if value == 9
            append!(fullcharge, index)
        end
        grid[index] = grid[index] + 1
    end
    while !isempty(fullcharge)
        index = pop!(fullcharge)
        for i in adjs(index, size(grid))
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
        subtotal = update(grid)
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

@time main()

#=
Julia seems like a nice language. It doesn't deserve code this ugly.
=#
