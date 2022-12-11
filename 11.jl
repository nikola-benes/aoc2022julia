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

function solve(monkeys, rounds, mod=0)
	monkeys = deepcopy(monkeys)
	relieve = mod == 0 ? x -> x ÷ 3 : x -> x % mod

	for _ ∈ 1:rounds, m ∈ monkeys, item ∈ move!(m.items)
		m.count += 1
		item = item |> m.op |> relieve
		next = item % m.test == 0 ? m.iftrue : m.iffalse
		push!(monkeys[next].items, item)
	end

	monkeys .|> (m -> m.count) |>
		c -> partialsort(c, 1:2, rev=true) |> prod
end

m::Monkey = Monkey()
monkeys::Vector{Monkey} = [m]

for line ∈ stdin |> eachline
	@matchswitch line begin
		r"^Monkey [1-9]" ->
			push!(monkeys, global m = Monkey())
		r"Starting items: (.*)" ->
			m.items = _[1] |> splitby(", ") .|> int
		r"Operation: new = (.*)" ->
			m.op = @eval old -> $(Meta.parse(_[1]))
		r"Test: divisible by (.*)" ->
			m.test = int(_[1])
		r"If true: throw to monkey (.*)" ->
			m.iftrue = int(_[1]) + 1
		r"If false: throw to monkey (.*)" ->
			m.iffalse = int(_[1]) + 1
	end
end

solve(monkeys, 20) |> println

const mod = reduce(lcm, monkeys .|> m -> m.test)

solve(monkeys, 10000, mod) |> println
