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
	Q = [(start, 1)]  # position, time
	# We only need to track the visited status of such (position, time)
	# pairs where the time is exactly one step ahead of current time.
	# Thus, we only keep the positions in V and flush it with every tick.
	V = Set{C}()

	bnext((pos, dir)) = (mod.(Tuple(pos + dir), bounds.indices) |> C, dir)
	inbounds(p) = p ∈ bounds || p ∈ (start, goal)

	trip = 0
	target = goal
	current = 0
	bad = Set{C}()  # state at time 0 is irrelevant

	while !isempty(Q)
		pos, time = popfirst!(Q)
		if time > current
			blizzards = blizzards .|> bnext
			bad = Set(p for (p, _) ∈ blizzards)
			current = time
			empty!(V)
		end

		for npos ∈ Ref(pos) .+ steps
			(!inbounds(npos) || npos ∈ bad || npos ∈ V) && continue

			if npos == target
				trip == extratrips && return time
				trip += 1
				# restart the search
				empty!(Q)
				empty!(V)
				target = target == goal ? start : goal
			end

			push!(Q, (npos, time + 1))
			push!(V, npos)
		end

	end
end

bfs(start, goal, blizzards, bounds) |> println
bfs(start, goal, blizzards, bounds, 2) |> println
