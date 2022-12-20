int(s) = parse(Int, s)

mutable struct Node
	value::Int
	next::Node
	prev::Node
	Node(value) = new(value)
end

function buildclist(values)
	@assert length(values) > 0
	nodes = values .|> Node
	for i ∈ 1:length(values) - 1
		nodes[i].next = nodes[i + 1]
		nodes[i + 1].prev = nodes[i]
	end
	nodes[end].next = nodes[1]
	nodes[1].prev = nodes[end]
	nodes
end

function swapnext!(node)
	other = node.next

	node.next = other.next
	node.next.prev = node

	other.prev = node.prev
	other.prev.next = other

	node.prev = other
	other.next = node
end

function solve(input, it = 1)
	nodes = buildclist(input)

	mix!(node) = let m = length(nodes) - 1
		for _ ∈ 1:mod(node.value, m)
			swapnext!(node)
		end
	end

	for _ ∈ 1:it
		foreach(mix!, nodes)
	end

	node = nodes[findfirst(n -> n.value == 0, nodes)]
	values = Int[]
	for _ ∈ 1:length(nodes)
		node = node.next
		push!(values, node.value)
	end

	[1000, 2000, 3000] .|> (i -> values[mod1(i, length(values))]) |> sum
end

const input = stdin |> eachline .|> int

solve(input) |> println
solve(input * 811589153, 10) |> println
