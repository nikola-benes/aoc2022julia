int(m::RegexMatch) = parse(Int, m.match)
mapby(f) = x -> map(f, x)
eachmatchby(r) = s -> eachmatch(r, s)

contain(a, b) = a ⊆ b || b ⊆ a

ranges = stdin |> eachline .|> eachmatchby(r"\d+") .|> mapby(int) |>
	mapby(v -> (v[1]:v[2], v[3]:v[4]))

for check in (contain, !isdisjoint)
	println(ranges .|> Base.splat(check) |> sum)
end
