#!/usr/bin/env elixir

defmodule Day15 do
    def makegrid(lines) do
        lines
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {line, y}, acc ->
            Map.merge(acc, 
                line
                |> String.graphemes()
                |> Enum.with_index()
                |> Enum.reduce(%{}, fn {c, x}, acc ->
                    tup = {x, y}
                    {val, _} = Integer.parse(c)
                    Map.merge(acc, %{ tup => val })
                end))
        end)
    end

    def gridsize(grid) do
        grid
        |> Map.keys()
        |> Enum.filter(fn {x, _} -> x == 0 end)
        |> Enum.count()
    end

    def embiggen(grid, copies) do
        size = gridsize(grid)
        (0..(copies-1)) |> Enum.map(fn x ->
            (0..(copies-1)) |> Enum.map(fn y ->
                Map.new(grid
                    |> Enum.map(fn {{oldx, oldy}, v} ->
                        {
                            {oldx + (size*x), oldy + (size*y)},
                            1 + rem(v + x + y - 1, 9)
                        }
                    end))
            end)
            |> Enum.reduce(fn a, b -> Map.merge(a, b) end)
        end)
        |> Enum.reduce(fn a, b -> Map.merge(a, b) end)
    end

    def neighbours({x, y}, size) do
        [{x+1, y}, {x-1, y}, {x, y+1}, {x, y-1}]
        |> Enum.filter(fn {i, j} ->
            i >= 0 && i < size && j >= 0 && j < size
        end)
    end

    def dijkstra(grid) do
        size = gridsize(grid)
        dijkstra grid, %{{0, 0} => 0}, {size-1, size-1}, %{{0, 0} => 0}, MapSet.new(), size
    end
    def dijkstra(grid, queue, target, best_distances, visited, size) do
        sorted = queue |> Enum.sort(fn {_, a}, {_, b} -> a < b end)
        {current, _} = hd(sorted)
        if current == target do
            best_distances[target]
        else
            new_dists = current
                |> neighbours(size)
                |> Enum.filter(fn coord -> coord not in visited end)
                |> Enum.map(fn coord ->
                    %{coord => min(
                        grid[coord] + best_distances[current],
                        Map.get(best_distances, coord, :infinity)
                    )}
                end)
                |> Enum.reduce(%{}, fn a, b -> Map.merge(a, b) end)
            dijkstra(
                grid,
                Map.new(tl(sorted))
                |> Map.merge(current
                    |> neighbours(size)
                    |> Enum.filter(fn coord ->
                        (coord not in visited && !Map.has_key?(queue, coord)) end)
                    |> Enum.map(fn coord ->
                        %{coord => best_distances[current] + grid[coord]}
                    end)
                    |> Enum.reduce(%{}, fn a, b -> Map.merge(a, b) end)),
                target,
                Map.merge(best_distances, new_dists),
                visited |> MapSet.put(current),
                size)
        end
    end
end

grid = File.read!("input15.txt")
    |> String.split("\n", trim: true)
    |> Day15.makegrid()

# part 1
IO.puts(grid |> Day15.dijkstra())

# part 2
IO.puts(grid |> Day15.embiggen(5) |> Day15.dijkstra())

# The syntax of Elixir is somewhat reminiscent of OCaml (or maybe I'm just
# overusing the |> operator). This program runs slowly on part 2 of the
# problem; I'm sure I must be messing up Dijkstra somehow (either the sorting
# key or the constant recasting of data into different types). I suspect both
# of these issues could be fixed by using a priority queue, but I couldn't find
# an implementation in the stdlib and couldn't find an easy way to download a
# package implementation.
