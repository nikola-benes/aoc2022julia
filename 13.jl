import Base: isless, splat

isless(a::Number, b::Vector) = [a] < b
isless(a::Vector, b::Number) = a < [b]

splitby(sep) = s -> split(s, sep)

decode(s) = s |> split .|> Meta.parse .|> eval

input = stdin |> readchomp

input |> splitby("\n\n") .|> decode .|> splat(<) |> findall |> sum |> println

all = input |> decode
extra = [[[2]], [[6]]]
append!(all, extra)
sort!(all)
extra .|> (x -> findfirst(==(x), all)) |> prod |> println
