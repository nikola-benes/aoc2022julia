elves = map(split(readchomp(stdin), "\n\n")) do elf
	sum(parse.(Int, split(elf, "\n")))
end

println(maximum(elves))
println(sum(sort(elves)[end-2:end]))
