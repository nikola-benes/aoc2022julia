int(s) = parse(Int, s)
splitby(sep) = s -> split(s, sep)
mapby(f) = x -> map(f, x)
reduceby(f) = x -> reduce(f, x)

const C = CartesianIndex{2}
const SD = [0, -1, +1] .|> x -> C(x, 1)

coords(s) = split(s, ",") .|> int |> Base.splat(C)
crange(x, y) = isempty(x:y) ? (y:x) : (x:y)

const rock = stdin |> eachline .|> splitby("->") .|> mapby(coords) .|>
	(t -> map(crange, t, t[2:end])) |> Iterators.flatten |> reduceby(union)

function solve(rock, part)
	start = C(500, 0)
	low = maximum(x -> x[2], rock)
	sand = Set{C}()

	fall1(p) = p ∉ rock && p ∉ sand
	fall = part == 1 ? fall1 : p -> p[2] ≤ low + 1 && fall1(p)

	run = part == 1 ? s -> s[2] ≤ low : s -> s ∉ sand

	s = start
	while run(s)
		opts = filter(fall, Ref(s) .+ SD)
		s = isempty(opts) ? (push!(sand, s); start) : first(opts)
	end

	sand |> length
end

for part ∈ (1, 2)
	solve(rock, part) |> println
end
