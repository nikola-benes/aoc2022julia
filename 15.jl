int(s) = parse(Int, s)
int(m::RegexMatch) = int(m.match)
eachmatchby(r) = s -> eachmatch(r, s)
mapby(f) = x -> map(f, x)
reduceby(f; args...) = x -> reduce(f, x; args...)

const C = CartesianIndex{2}

struct Sensor
	pos::C
	beacon::C
	cov::Int
end

manhattan(p, q) = p - q |> Tuple .|> abs |> sum
sensor(v) = let pos = C(v[1], v[2]); beacon = C(v[3], v[4])
	Sensor(pos, beacon, manhattan(pos, beacon))
end

function runion(rv, rng)
	isempty(rng) && return rv
	result = UnitRange{Int}[]
	for (i, r) ∈ enumerate(rv)
		if !isdisjoint(rv[i], rng)
			rng = min(first(r), first(rng)):max(last(r), last(rng))
		elseif r < rng
			if last(r) + 1 == first(rng)
				rng = first(r):last(rng)
			else
				push!(result, r)
			end
		else
			if last(rng) + 1 == first(r)
				rng = first(rng):last(r)
			else
				push!(result, rng)
				append!(result, @view rv[i:end])
				return result
			end
		end
	end
	push!(result, rng)
end

const bounds = C(0, 0):C(4000000, 4000000)

function edge(s)
	result = []
	left = right = s.pos - C(0, s.cov + 1)
	for _ ∈ 1:s.cov + 1
		left ∈ bounds && push!(result, left)
		left != right && right ∈ bounds && push!(result, right)
		left += C(-1, 1)
		right += C(1, 1)
	end
	for _ ∈ 1:s.cov + 2
		left ∈ bounds && push!(result, left)
		left != right && right ∈ bounds && push!(result, right)
		left += C(1, 1)
		right += C(-1, 1)
	end
	result
end

covy(s, y) = let x = s.pos[1], d = s.cov - abs(s.pos[2] - y); x - d:x + d end

const sensors = stdin |>
	eachline .|> eachmatchby(r"-?\d+") .|> mapby(int) .|> sensor

const Y = 2000000
const bY = Set(s.beacon for s ∈ sensors if s.beacon[2] == Y) |> length
const cY = covy.(sensors, Y) |> reduceby(runion, init = UnitRange{Int}[]) .|>
	length |> sum
println(cY - bY)

p = first(p for p ∈ sensors .|> edge |> Iterators.flatten
	    if all(manhattan(p, s.pos) > s.cov for s ∈ sensors))
println(p[1] * 4000000 + p[2])
