common(s) = (mid = length(s) ÷ 2; s[1:mid] ∩ s[mid + 1:end])
priority(c) = islowercase(c) ? c - 'a' + 1 : c - 'A' + 27

rucksacks = stdin |> readlines

println(rucksacks .|> common .|> only .|> priority |> sum)

groups = reshape(rucksacks, (3, :))
badges = mapslices(g -> ∩(g...), groups; dims=1)

println(badges .|> priority |> sum)
