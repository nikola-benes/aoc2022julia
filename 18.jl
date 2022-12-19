int(s) = parse(Int, s)
splitby(sep) = s -> split(s, sep)
mapby(f) = x -> map(f, x)

const C = CartesianIndex{3}

const D = [(1, 0, 0), (-1, 0, 0),
           (0, 1, 0), (0, -1, 0),
           (0, 0, 1), (0, 0, -1)] .|> C

countsides(f, cubes) =
	Iterators.product(cubes, D) .|> Base.splat(+) .|> f |> sum

const cubes = stdin |>
	readlines .|> splitby(",") .|> mapby(int) .|> Base.splat(C)

const cubeset = Set(cubes)

countsides(∉(cubeset), cubes) |> println

const bounds = range(extrema(cubes)...)
const outer = union([selectdim(bounds, d, f(bounds, d)) |> Set
                     for f in (firstindex, lastindex) for d in 1:3]...)

seen::Set{C} = setdiff(outer, cubeset)
bag::Vector{C} = seen |> collect

# pseudo-dfs
while !isempty(bag)
	pos = pop!(bag)
	for npos ∈ Ref(pos) .+ D
		if npos ∈ bounds && npos ∉ cubeset && npos ∉ seen
			push!(bag, npos)
			push!(seen, npos)
		end
	end
end

countsides(cubes) do x; x ∉ bounds || x ∈ seen end |> println
