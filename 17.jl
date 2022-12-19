mapby(f) = x -> map(f, x)

const C = CartesianIndex{2}

const pattern = stdin |> readchomp

const shapes = [
       [(1, 1), (2, 1), (3, 1), (4, 1)], # -
       [(2, 2), (1, 2), (3, 2), (2, 1), (2, 3)], # +
       [(1, 1), (2, 1), (3, 1), (3, 2), (3, 3)], # J
       [(1, 1), (1, 2), (1, 3), (1, 4)], # |
       [(1, 1), (1, 2), (2, 1), (2, 2)], # O
] .|> mapby(C)

const row = 1:7

mutable struct Chamber
	well::Set{C}
	shape::Vector{C}
	offset::C
	next::Int
	height::Int
	Chamber() = new(Set(C(x, 0) for x ∈ row), shapes[1], C(2, 3), 2, 0)
end

function move!(ch, dir::C)
	new = ch.offset + dir
	for pos in ch.shape .+ Ref(new)
		(pos[1] ∉ row || pos ∈ ch.well) && return false
	end
	ch.offset = new
	true
end

function down!(ch)
	move!(ch, C(0, -1)) && return true
	coords = ch.shape .+ Ref(ch.offset)
	union!(ch.well, coords)
	ch.height = max(ch.height, maximum(x -> x[2], coords))
	ch.shape = shapes[ch.next]
	ch.next = mod1(ch.next + 1, length(shapes))
	ch.offset = C(2, ch.height + 3)
	false
end

function relief(ch)
	bag = [(x, ch.height + 1) for x in row] .|> C
	dirs = [(1, 0), (-1, 0), (0, -1)] .|> C
	seen = Set(bag)
	result = Set()

	# pseudo-dfs
	while !isempty(bag)
		pos = pop!(bag)
		for npos ∈ Ref(pos) .+ dirs
			(npos[1] ∉ row || npos ∈ seen) && continue
			push!(seen, npos)
			if npos ∈ ch.well
				push!(result, npos - C(0, ch.height))
			else
				push!(bag, npos)
			end
		end
	end
	result
end

function solve(limit)
	ch = Chamber()
	seen = Dict()
	stopped = 0
	i = 0
	bonus = 0
	while stopped < limit
		i = mod1(i + 1, length(pattern))
		c = pattern[i]
		move!(ch, C(c == '<' ? -1 : +1, 0))
		down!(ch) && continue

		stopped += 1
		bonus > 0 && continue

		key = relief(ch), i, ch.next
		if !haskey(seen, key)
			seen[key] = stopped, ch.height
			continue
		end

		prev_s, prev_h = seen[key]
		diff_s = stopped - prev_s
		repeat = (limit - stopped) ÷ diff_s
		stopped += repeat * diff_s
		bonus = repeat * (ch.height - prev_h)
	end
	ch.height + bonus
end

solve(2022) |> println
solve(1000000000000) |> println
