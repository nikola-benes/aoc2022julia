int(s) = parse(Int, s)

const c = CartesianIndex{2}

function tailmove(head, tail)
	diff = Tuple(head - tail)
	max(abs.(diff)...) ≤ 1 && return tail
	tail += diff .|> (x -> clamp(x, -1, 1)) |> c
end

const dirs = Dict(
	'U' => c(0, -1), 'D' => c(0, 1), 'L' => c(-1, 0), 'R' => c(1, 0)
)

const moves = stdin |> readlines .|> line -> (dirs[line[1]], int(line[3:end]))

function solve(len, moves)
	start = c(0, 0)
	rope = [start for _ in 1:len]
	seen = Set([start])

	for (dir, step) ∈ moves, _ ∈ 1:step
		rope[1] += dir
		for i ∈ 2:len
			rope[i] = tailmove(rope[i - 1], rope[i])
		end
		push!(seen, rope[len])
	end

	seen |> length
end

solve(2, moves) |> println
solve(10, moves) |> println
