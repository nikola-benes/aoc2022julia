s = stdin |> readchomp

for w ∈ (4, 14)
	first(i for i ∈ w:lastindex(s) if allunique(s[i - w + 1:i])) |> println
end
