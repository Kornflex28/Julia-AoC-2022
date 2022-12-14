using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 11

## HELPER FUNCTIONS
function formatinput(input)
    monkeysind = findall(l -> occursin(r"^Monkey \d+:", l), input)
    monkeys = []
    for kmonkeyind in monkeysind
        monkey = Dict("items" => [parse(Int, m.match) for m in eachmatch(r"(\d+)", input[kmonkeyind+1])], # items
            "op" => eval(Meta.parse("old -> " * match(r"old.+", input[kmonkeyind+2]).match)), # operation anonymous function with floored division by 3
            "test" => eval(Meta.parse("x -> rem(x," * match(r"(\d+)", input[kmonkeyind+3]).match * ") == 0")), # divisible test
            "divisor" => parse(Int,match(r"(\d+)", input[kmonkeyind+3]).match),
            "throws" => [parse(Int, match(r"(\d+)", input[k]).match) + 1 for k in kmonkeyind .+ (5:-1:4)]) # reverse order
        push!(monkeys, monkey)
    end
    monkeys
end

function solution(monkeys; nround=20, divide=3)
    monkeys_ = deepcopy(monkeys)
    inspections = zeros(length(monkeys_), 1)
    modulus = lcm([monkey["divisor"] for monkey in monkeys])
    # Loop through rounds
    for _ = 1:nround
        # Loop through monkeys
        for (kmonkey, monkey) in enumerate(monkeys_)
            # Update inspections count
            inspections[kmonkey] += length(monkey["items"])
            # Inspect all items
            while 0 < length(monkey["items"])
                # All worry computations are correct modulo the least common multiple of all monkey tests
                newworry = fld(monkey["op"](popfirst!(monkey["items"])), divide) % (modulus/divide)
                push!(monkeys_[monkey["throws"][Int(monkey["test"](newworry))+1]]["items"], newworry)
            end
        end
    end
    return prod(sort(inspections, rev=true, dims=1)[1:2])
end

## MAIN

if benchmarkmode

    tformatinput(nday; test=true) = formatinput(IOaoc.loadinput(nday, test=test, verbose=false))
    tsolution1(input) = solution(input)
    tsolution2(input) = solution(input, nround=10000, divide=1)

else

    testinput = formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    puzzleinput = formatinput(IOaoc.loadinput(nday, verbose=verbose))

    testsol1 = solution(testinput)
    puzzlesol1 = solution(puzzleinput)

    testsol2 = solution(testinput, nround=10000, divide=1)
    puzzlesol2 = solution(puzzleinput, nround=10000, divide=1)

    if verbose
        IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    end
end