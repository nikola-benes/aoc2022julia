mapby(f) = x -> map(f, x)

d = Dict("A" => 1, "B" => 2, "C" => 3, "X" => 1, "Y" => 2, "Z" => 3)
rounds = stdin |> eachline .|> split .|> mapby(x -> d[x])

s1(a, b) = b + (a == b ? 3 : mod1(a + 1, 3) == b ? 6 : 0)
s2(a, b) = (mod1(a - 1, 3), a + 3, mod1(a + 1, 3) + 6)[b]

for score in (s1, s2)
	println(map(x -> score(x...), rounds) |> sum)
end
