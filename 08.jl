int(s) = parse(Int, s)
mapby(f) = x -> map(f, x)
reduceby(f) = x -> reduce(f, x)

mutable struct Tree
	const height::Int
	visible::Bool
	Tree(height) = new(height, false)
end

const trees = (
	stdin |> eachline .|> collect .|> mapby(Tree ∘ int) |> reduceby(hcat)
)

for d ∈ 1:2, s ∈ eachslice(trees, dims=d), array ∈ (s, Iterators.reverse(s))
	last = -1
	for tree ∈ array
		tree.height ≤ last && continue
		tree.visible = true
		last = tree.height
	end
end

trees .|> (t -> t.visible) |> sum |> println

const indices = CartesianIndices(trees)
const dirs = [(1, 0), (0, 1), (-1, 0), (0, -1)] .|> CartesianIndex

best = 0
for pos ∈ indices
	t = trees[pos]
	limit = t.height
	score = 1
	for d ∈ dirs
		cur = pos
		dist = 0
		while (cur + d) ∈ indices
			cur += d
			dist += 1
			trees[cur].height ≥ limit && break
		end
		score *= dist
	end
	global best = max(score, best)
end
println(best)
