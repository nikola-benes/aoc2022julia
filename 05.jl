int(s) = parse(Int, s)
int(m::RegexMatch) = int(m.match)
splitby(sep) = s -> split(s, sep)
eachmatchby(r) = s -> eachmatch(r, s)
mapby(f) = x -> map(f, x)
reduceby(f) = x -> reduce(f, x)
filterby(f) = x -> filter(f, x)
pushto!(v) = x -> push!(v, x)
appendto!(v) = x -> append!(v, x)

last!(v, c) = let end_ = lastindex(v); splice!(v, end_ - c + 1 : end_) end

function solve(stacks, moves, apply)
	stacks = deepcopy(stacks)
	for move ∈ moves
		apply(stacks, move)
	end
	stacks .|> last |> join
end

apply1(s, (c, from, to)) = for _ ∈ 1:c pop!(s[from]) |> pushto!(s[to]) end
apply2(s, (c, from, to)) = last!(s[from], c) |> appendto!(s[to])

# ---

init, cmds = stdin |> readchomp |> splitby("\n\n") .|> splitby("\n")

stacks = init[1:end-1] .|> (s -> s[2:4:end]) .|> collect |>
	reverse |> reduceby(hcat) |> eachrow .|> filterby(!isspace)

moves = cmds .|> eachmatchby(r"\d+") .|> mapby(int)

for apply ∈ (apply1, apply2)
	solve(stacks, moves, apply) |> println
end
