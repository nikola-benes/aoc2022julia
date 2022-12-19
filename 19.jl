int(s) = parse(Int, s)

const materials = Dict("ore" => 1, "clay" => 2, "obsidian" => 3, "geode"=> 4)

function parsebp(line)
	bp = [[0, 0, 0, 0] for _ in 1:4]
	for (kind, cost) ∈ eachmatch(r"Each (\w*) robot costs ([^.]*)\.", line)
		robot = materials[kind]
		for src in split(cost, " and ")
			count, kind = split(src, " ")
			bp[robot][materials[kind]] = int(count)
		end
	end
	bp
end

function timetobuild(reqs, robots, ore)
	time::Float64 = 0
	for i ∈ 1:4
		reqs[i] ≤ ore[i] && continue
		robots[i] == 0 && return Inf
		time = max(time, 1, ceil((reqs[i] - ore[i]) / robots[i]))
	end
	time + 1
end

function quality(bp, time)::Int
	maxcost = reduce((x, y) -> max.(x, y), bp)
	memo = Dict{Tuple{Float64, Vector{Float64}, Vector{Float64}}, Float64}()

	function solve(time, robots, ore)
		for r ∈ 1:3
			if robots[r] * time + ore[r] ≥ maxcost[r] * time
				robots[r] = Inf
			end
		end

		get!(memo, (time, robots, ore)) do
			# what if we do nothing
			best = ore[4] + time * robots[4]

			# what robot do we build next
			for r ∈ 1:4
				robots[r] == Inf && continue
				t = timetobuild(bp[r], robots, ore)
				t > time && continue

				ntime = time - t
				nrobots = copy(robots)
				nrobots[r] += 1
				nore = ore + t * robots - bp[r]

				best = max(best, solve(ntime, nrobots, nore))
			end
			best
		end
	end

	# using floats to take advantage of Inf
	solve(float(time), Float64[1, 0, 0, 0], Float64[0, 0, 0, 0])
end

const bps = stdin |> eachline .|> parsebp

quality.(bps, 24) |> enumerate .|> Base.splat(*) |> sum |> println
quality.(bps[1:3], 32) |> prod |> println
