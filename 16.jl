int(s) = parse(Int, s)
withget(f, d, k) = let v = get(d, k, nothing); isnothing(v) || f(v) end

struct Graph
	flows::Vector{Int}
	start::Vector{Int}
	shortest::Matrix{Int}
end

function parseline(s)
	src, flow, dst = match(r"Valve (.*) has.*=(.*);.*valves? (.*)", s)
	src, int(flow), split(dst, ", ")
end

function creategraph(input)
	ids = Dict{String, Int}()
	flows = Int[]
	graph = Dict{String, Vector{String}}()

	for (src, flow, dsts) ∈ input |> eachline .|> parseline
		graph[src] = dsts
		flow == 0 && continue
		push!(flows, flow)
		ids[src] = length(flows)
	end

	function bfs(s, store)
		Q = [(0, s)]
		V = Set([s])

		while !isempty(Q)
			dist, v = popfirst!(Q)
			withget(ids, v) do id; store[id] = dist end

			for nv ∈ graph[v]
				nv ∈ V && continue
				push!(Q, (dist + 1, nv))
				push!(V, nv)
			end
		end
	end

	sz = length(flows)
	start = zeros(Int, sz)
	shortest = zeros(Int, sz, sz)

	bfs("AA", start)
	for (v, id) ∈ ids
		bfs(v, @view shortest[:, id])
	end

	Graph(flows, start, shortest)
end

const graph = open("input") |> creategraph
const count = length(graph.flows)
const interesting = BitSet(1:count)

memo::Dict{Tuple{Int, BitSet, Int}, Int} = Dict()

function solve(time, closed = interesting, pos = 0)
	key = (time, closed, pos)
	get!(memo, key) do
		pr = 0
		for nxt ∈ closed
			path = pos == 0 ?
				graph.start[nxt] :
				graph.shortest[nxt, pos]
			ntime = time - path - 1
			ntime < 0 && continue
			pr = max(pr, ntime * graph.flows[nxt] +
			             solve(ntime, setdiff(closed, nxt), nxt))
		end
		pr
	end
end

solve(30) |> println

best = 0
for i ∈ 0:(2^count - 1)
	mine = BitSet(k for k in 1:count if i & 2^(k - 1) != 0)
	global best = max(best,
		solve(26, mine) + solve(26, setdiff(interesting, mine)))
end
println(best)
