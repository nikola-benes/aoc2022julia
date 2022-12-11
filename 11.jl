# vim: nomodeline

_replace_topic(var, ex) = ex ≡ :_ ? var : ex
_replace_topic(var, ex::Expr) = Expr(ex.head, _replace_topic.(var, ex.args)...)

function _ms_if(pair::Expr, s::Symbol, m::Symbol)
	@assert pair.head === :->
	regex, code = pair.args
	regex === :default && return :( if true; $code end )

	:( if ($m = match($regex, $s)) !== nothing
		$(_replace_topic(m, code))
	end )
end

macro matchswitch(input, block::Expr)
	@assert block.head === :block
	@gensym s m
	ifs = nothing
	last_if = nothing

	for arg ∈ block.args
		arg isa LineNumberNode && continue
		this_if = _ms_if(arg, s, m)
		if ifs === nothing
			ifs = this_if
		else
			this_if.head = :elseif
			push!(last_if.args, this_if)
		end
		last_if = this_if
	end

	esc(quote local $s = $input; $ifs end)
end

int(s) = parse(Int, s)
splitby(sep) = s -> split(s, sep)
move!(v) = splice!(v, firstindex(v):lastindex(v))

mutable struct Monkey
	count::Int
	items::Vector{BigInt}
	op::Function
	test::Int
	iftrue::Int
	iffalse::Int
	Monkey() = new(0)
end

function round!(monkeys, mod)
	# mod == 0 means part 1
	for m ∈ monkeys, item ∈ move!(m.items)
		m.count += 1
		item = m.op(item)
		if mod == 0
			item ÷= 3
		else
			item %= mod
		end
		next = item % m.test == 0 ? m.iftrue : m.iffalse
		push!(monkeys[next].items, item)
	end
end

function solve(monkeys, rounds, mod=0)
	monkeys = deepcopy(monkeys)
	for _ ∈ 1:rounds
		round!(monkeys, mod)
	end
	monkeys .|> (m -> m.count) |>
		(c -> partialsort(c, 1:2, rev=true)) |> prod
end

monkeys::Vector{Monkey} = []

for line ∈ stdin |> eachline
	@matchswitch line begin
		r"^Monkey" ->
			push!(monkeys, Monkey())
		r"Starting items: (.*)" ->
			monkeys[end].items = _[1] |> splitby(", ") .|> int
		r"Operation: new = (.*)" ->
			monkeys[end].op = @eval old -> $(Meta.parse(_[1]))
		r"Test: divisible by (.*)" ->
			monkeys[end].test = int(_[1])
		r"If true: throw to monkey (.*)" ->
			monkeys[end].iftrue = int(_[1]) + 1
		r"If false: throw to monkey (.*)" ->
			monkeys[end].iffalse = int(_[1]) + 1
	end
end

solve(monkeys |> deepcopy, 20) |> println

mod = reduce(lcm, monkeys .|> (m -> m.test))

solve(monkeys, 10000, mod) |> println
