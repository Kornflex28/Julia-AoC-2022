using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 10

## HELPER FUNCTIONS
formatinput(input) = reduce(hcat, [(1 < length(l)) ? [1, parse(Int, l[2])] : [-1, 0] for l ∈ map(split, input)])'

function get_register(ops)
    addxind = findall(0 .< ops[:, 1])
    X = zeros(size(ops, 1) + 2 * length(addxind), 1)
    X[2 .+ addxind.+(0:(length(addxind)-1))] = ops[addxind, 2]
    X = cumsum(X, dims=1) .+ 1
end

function solution1(ops)
    X = get_register(ops)
    cycles = 20:40:220
    return sum((cycles) .* X[cycles])
end

function solution2(ops)
    X = get_register(ops)[1:240]
    cycles = (0:239) .% 40
    cyclesm1 = cycles .- 1
    cyclesp1 = cycles .+ 1
    crt = ['.' for _ = 1:length(cycles)]
    pixels = (X .== cycles) .|| (X .== cyclesm1) .|| (X .== cyclesp1)
    crt[pixels] .= '#'
    return join([reshape(crt, 40, 6); ['\n' '\n' '\n' '\n' '\n' '\n']])
end

## MAIN

if benchmarkmode

    tformatinput(nday; test=true) = formatinput(IOaoc.loadinput(nday, test=test, verbose=false))
    tsolution1(input) = solution1(input)
    tsolution2(input) = solution2(input)

else

    testinput = formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    puzzleinput = formatinput(IOaoc.loadinput(nday, verbose=verbose))

    testsol1 = solution1(testinput)
    puzzlesol1 = solution1(puzzleinput)

    testsol2 = solution2(testinput)
    puzzlesol2 = solution2(puzzleinput)

    if verbose
        IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    end
end