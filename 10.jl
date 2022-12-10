int(s) = parse(Int, s)
mapby(f) = x -> map(f, x)
joinby(sep) = s -> join(s, sep)

changes::Vector{Int} = [1]

for line in stdin |> eachline
	push!(changes, 0)
	tokens = line |> split
	length(tokens) == 2 && push!(changes, int(tokens[2]))
end

pop!(changes) # the last change happens *after* the 240th cycle

const reg = cumsum(changes)

(20, 60, 100, 140, 180, 220) .|> (i -> i * reg[i]) |> sum |> println

crt::BitVector = []

for (p, s) in enumerate(reg)
	pos = (p - 1) % 40
	push!(crt, abs(pos - s) ≤ 1)
end

reshape(crt, 40, :) |> eachcol .|> mapby(b -> b ? "█▉" : "  ") .|>
	join |> joinby('\n') |> println
