int(s) = parse(Int, s)
mapby(f) = x -> map(f, x)
reduceby(f) = x -> reduce(f, x)

mutable struct Tree
	const height::Int
	visible::Bool
	score::Int
	Tree(height) = new(height, false, 1)
end

const trees = (
	stdin |> eachline .|> collect .|> mapby(Tree ∘ int) |> reduceby(hcat)
)

for d ∈ 1:2, s ∈ eachslice(trees, dims=d), line ∈ (s, Iterators.reverse(s))
	stack = @NamedTuple{height::Int, smaller::Int}[]
	for tree ∈ line
		smaller = 0
		while !isempty(stack) && stack[end].height < tree.height
			smaller += pop!(stack).smaller + 1
		end
		tree.score *= smaller + !isempty(stack)
		tree.visible |= isempty(stack)
		push!(stack, (height = tree.height, smaller))
	end
end

trees .|> (t -> t.visible) |> sum |> println
trees .|> (t -> t.score) |> maximum |> println
