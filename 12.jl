reduceby(f) = x -> reduce(f, x)

const D = [(-1, 0), (+1, 0), (0, -1), (0, +1)] .|> CartesianIndex

function bfs(hmap, starts, goal)
	bounds = CartesianIndices(hmap)
	Q = [(0, s) for s in starts]
	V = falses(size(hmap))
	V[starts] .= true

	while !isempty(Q)
		dist, p = popfirst!(Q)
		for np in [p] .+ D
			if np ∈ bounds && !V[np] && hmap[np] - hmap[p] ≤ 1
				np == goal && return dist + 1
				push!(Q, (dist + 1, np))
				V[np] = true
			end
		end
	end
end

hmap::Matrix{Char} = stdin |> eachline .|> collect |> reduceby(hcat)
const start, goal = ('S', 'E') .|> c -> findfirst(==(c), hmap)
hmap[start] = 'a'
hmap[goal] = 'z'

bfs(hmap, [start], goal) |> println
bfs(hmap, findall(==('a'), hmap), goal) |> println
