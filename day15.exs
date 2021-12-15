#!/usr/bin/elixir

[_ | lines] = File.read!("input.txt")
    |> String.split("\n", trim: true)
nums = lines
    |> Enum.map(fn line -> String.split(line, ",") end)
IO.puts(nums)

