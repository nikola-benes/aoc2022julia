int(s) = parse(Int, s)

const ops = Dict("+" => +, "-" => -, "*" => *, "/" => //)

function parseexpr(line)
	lhs, rhs = split(line, ": ")
	tokens = split(rhs)
	lhs => (length(tokens) == 1 ? int(rhs) : Tuple(tokens))
end

const monkeys = stdin |> eachline .|> parseexpr |> Dict

function evalm(monkey)
	rhs = monkeys[monkey]
	rhs isa Int && return rhs
	left, op, right = rhs
	ops[op](evalm(left), evalm(right))
end

evalm("root") |> Int |> println

left, _, right = monkeys["root"]

monkeys["humn"] = 0
l0, r0 = (left, right) .|> evalm
monkeys["humn"] = 1
l1, r1 = (left, right) .|> evalm

check, h0, h1 = l0 == l1 ? (l0, r0, r1) : (r0, l0, l1)
(check - h0) // (h1 - h0) |> Int |> println
