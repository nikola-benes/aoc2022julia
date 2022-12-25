const FROM = Dict('2' => 2, '1' => 1, '0' => 0, '-' => -1, '=' => -2)
const TO = FROM |> collect .|> reverse |> Dict

function from_snafu(digits)
	num = 0
	for char in digits
		num = 5 * num + FROM[char]
	end
	num
end

function to_snafu(num)
	digits = []
	while num != 0
		last = mod(num, -2:2)
		num = (num - last) ÷ 5
		push!(digits, TO[last])
	end
	digits |> reverse! |> join
end

stdin |> eachline .|> from_snafu |> sum |> to_snafu |> println
