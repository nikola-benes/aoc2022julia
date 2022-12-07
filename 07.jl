int(s) = parse(Int, s)
filterby(f) = x -> filter(f, x)

# assumptions:
# - cd / is called exactly once in the beginning
# - ls is called exactly once for each directory, immediately after cd
# - no directory is traversed more than once

mutable struct Dir
	size::Int
end

closedir!(stack) = let dir = pop!(stack); stack[end].size += dir.size end

stack::Vector{Dir} = []
dirs::Vector{Dir} = []

for line ∈ stdin |> eachline
	line[1:3] ∈ ("\$ l", "dir") && continue

	if line[1] != '$'
		size, _ = split(line)
		stack[end].size += int(size)
		continue
	end

	# cd
	arg = line[6:end]
	arg == ".." && (closedir!(stack); continue)

	dir = Dir(0)
	push!(stack, dir)
	push!(dirs, dir)
end

while length(stack) > 1
	closedir!(stack)
end

const sizes = map(d -> d.size, dirs)
sizes |> filterby(≤(100000)) |> sum |> println

const needed = only(stack).size - 40000000
sizes |> filterby(≥(needed)) |> minimum |> println
