using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 4

## HELPER FUNCTIONS

formatinput(input) = [[parse(Int, c) for c ∈ split(pair, (',', '-'))] for pair ∈ input]

fullycontains(pair) = (pair[3] <= pair[1] <= pair[4] && pair[3] <= pair[2] <= pair[4]) || (pair[1] <= pair[3] <= pair[2] && pair[1] <= pair[4] <= pair[2])

overlaps(pair) = (pair[1] <= pair[4] && pair[3] <= pair[2]) || (pair[3] <= pair[2] && pair[1] <= pair[4])

solution1(data) = sum([fullycontains(pair) for pair ∈ data])

solution2(data) = sum([overlaps(pair) for pair ∈ data])

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