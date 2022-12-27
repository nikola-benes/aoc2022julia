int(s) = parse(Int, s)
splitby(sep) = s -> split(s, sep)

const C = Complex{Int}
xy(c) = (c.re, c.im)

function board(desc, wrap)
	board = Dict{C, Dict{C, Tuple{C, C}}}()
	walls = Set{C}()

	for (y, row) ∈ desc |> splitby("\n") |> enumerate,
	    (x, tile) ∈ row |> enumerate
		pos = C(x, y)
		tile == ' ' && continue
		tile == '#' && push!(walls, pos)
		board[pos] = Dict()
	end

	for (pos, ds) ∈ board
		pos ∈ walls && continue
		dir = C(1, 0)
		for _ ∈ 1:4
			dir *= 1im
			npos = pos + dir
			ndir = dir
			if !haskey(board, npos)
				npos, ndir = wrap(board, pos, dir)
			end
			npos ∈ walls && continue
			ds[dir] = npos, ndir
		end
	end

	board
end

function wrap1(board, pos, dir)
	while haskey(board, pos - dir)
		pos -= dir
	end
	pos, dir
end

# assume the unfolded cube is like this:
#  AB
#  C
# DE
# F

const sA = (1, 0)
const sB = (2, 0)
const sC = (1, 1)
const sD = (0, 2)
const sE = (1, 2)
const sF = (0, 3)
const NORTH =  0 - 1im
const SOUTH =  0 + 1im
const WEST  = -1 + 0im
const EAST  =  1 + 0im

const ROT = Dict(
	(sA, NORTH) => (sF, EAST),
	(sA, WEST)  => (sD, EAST),
	(sB, NORTH) => (sF, NORTH),
	(sB, EAST)  => (sE, WEST),
	(sB, SOUTH) => (sC, WEST),
	(sC, WEST)  => (sD, SOUTH),
	(sC, EAST)  => (sB, NORTH),
	(sD, NORTH) => (sC, EAST),
	(sD, WEST)  => (sA, EAST),
	(sE, EAST)  => (sB, WEST),
	(sE, SOUTH) => (sF, WEST),
	(sF, EAST)  => (sE, NORTH),
	(sF, SOUTH) => (sB, SOUTH),
	(sF, WEST)  => (sA, SOUTH),
)

cmod(c, m) = Complex(mod.(xy(c), m)...)
cmod1(c, m) = Complex(mod1.(xy(c), m)...)

function wrap2(_board, pos, dir)
	side = xy(pos - 1 - im) .÷ 50
	rel = cmod1(pos, 50)

	nside, ndir = ROT[side, dir]
	rot = C(ndir / dir)

	nrel = cmod1(cmod(rel * rot, 51) + ndir, 50)
	50 * C(nside...) + nrel, ndir
end

function walk(board, path)
	pos = C(minimum(x for (x, y) ∈ keys(board) .|> xy if y == 1), 1)
	dir = C(1, 0)

	for cmd ∈ path
		if cmd ∈ ("R", "L")
			dir *= cmd == "R" ? 1im : -1im
			continue
		end
		steps = int(cmd)
		for _ ∈ 1:steps
			next = board[pos]
			!haskey(next, dir) && break
			pos, dir = next[dir]
		end
	end
	pos, dir
end

const dirscore = Dict(EAST => 0, SOUTH => 1, WEST => 2, NORTH => 3)

const b, p = stdin |> readchomp |> splitby("\n\n")
const path = split(p, r"(?=[RL])|(?<=[RL])")

for wrap ∈ (wrap1, wrap2)
	pos, dir = walk(board(b, wrap), path)
	x, y = xy(pos)
	println(1000 * y + 4 * x + dirscore[dir])
end
