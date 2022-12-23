const C = CartesianIndex{2}
const AROUND = [
	C(-1, -1), C(0, -1), C(1, -1),
	C(-1,  0),           C(1,  0),
	C(-1,  1), C(0,  1), C(1,  1),
]
const DIRS = [
	[C(-1, -1), C(0, -1), C(1, -1)],
	[C(-1,  1), C(0,  1), C(1,  1)],
	[C(-1, -1), C(-1, 0), C(-1, 1)],
	[C( 1, -1), C( 1, 0), C( 1, 1)],
]

function round!(elves, which)
	proposed = Dict{C, Vector{C}}()
	propose(elf, dir) = push!(get!(proposed, elf + dir, []), elf)

	for elf ∈ elves
		all(elf + d ∉ elves for d ∈ AROUND) && continue
		for i ∈ 0:3
			dirs = DIRS[mod1(i + which, 4)]
			if all(elf + d ∉ elves for d ∈ dirs)
				propose(elf, dirs[2])
				break
			end
		end
	end

	moved = false

	for (target, source) ∈ proposed
		length(source) > 1 && continue
		delete!(elves, source[1])
		push!(elves, target)
		moved = true
	end

	moved
end

elves = Set(C(x, y) for (y, row) in stdin |> eachline |> enumerate
                    for (x, tile) in row |> enumerate
                    if tile == '#')

for r in 1:10
	round!(elves, r)
end

length(range(extrema(elves)...)) - length(elves) |> println

r = 11
while round!(elves, r)
	global r += 1
end

println(r)
