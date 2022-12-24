const C = CartesianIndex{2}
const dirs = Dict('<' => C(-1, 0), '>' => C(1, 0),
                  '^' => C(0, -1), 'v' => C(0, 1))
const steps = push!(dirs |> values |> collect, C(0, 0))

const lines = stdin |> readlines
const rows, cols = length(lines), length(lines[1])
at(p) = let (x, y) = Tuple(p); lines[y][x] end

const bounds = C(2, 2):C(cols - 1, rows - 1)
const start = C(findfirst(==('.'), lines[1]), 1)
const goal = C(findfirst(==('.'), lines[end]), rows)
const blizzards = [(p, dirs[at(p)]) for p ∈ bounds if at(p) != '.']

function bfs(start, goal, blizzards, bounds, extratrips = 0)
	Q = [(start, 1, 0)]  # position, time, which trip
	V = Set(Q)

	bnext((pos, dir)) = (mod.(Tuple(pos + dir), bounds.indices) |> C, dir)
	inbounds(p) = p ∈ bounds || p ∈ (start, goal)
	ntrip(p, trip) = (p == goal && trip % 2 == 0) ||
	                 (p == start && trip % 2 == 1) ? trip + 1 : trip

	last = 0
	bad = Set{C}()  # state at time 0 is irrelevant

	while !isempty(Q)
		pos, time, trip = popfirst!(Q)
		if time > last
			blizzards = blizzards .|> bnext
			bad = Set(p for (p, _) ∈ blizzards)
			last = time
		end

		for npos ∈ Ref(pos) .+ steps
			(!inbounds(npos) || npos ∈ bad) && continue
			npos == goal && trip == extratrips && return time

			new = (npos, time + 1, ntrip(npos, trip))
			new ∈ V && continue

			push!(Q, new)
			push!(V, new)
		end

	end
end

bfs(start, goal, blizzards, bounds) |> println
bfs(start, goal, blizzards, bounds, 2) |> println
