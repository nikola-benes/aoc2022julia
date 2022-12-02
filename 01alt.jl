function _start_pipe(var, ex)
	if ex isa Expr && ex.head == :call && ex.args[1] in (:|>, :.|>)
		ex.args[2] = _start_pipe(var, ex.args[2])
		ex
	else
		:( $var |> $ex )
	end
end

macro |>(ex)
	@gensym start
	esc(:( $start -> $(_start_pipe(start, ex)) ))
end

int(s) = parse(Int, s)
splitby(sep) = s -> split(s, sep)

elves = stdin |> readchomp |> splitby("\n\n") .|>
	@|> splitby("\n") .|> int |> sum

println(elves |> maximum)
println(sort(elves)[end-2:end] |> sum)
