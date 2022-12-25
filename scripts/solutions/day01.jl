using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 1

## HELPER FUNCTIONS

function formatinput(input)
    # Split input by empty string
    splits = [firstindex(input) - 1; findall(isempty, input); lastindex(input) + 1]
    # Get index for each split
    s1, s2 = @view(splits[1:end-1]), @view(splits[2:end])
    # Get list of split
    [[parse(Int, i) for i ∈ sub] for sub ∈ [view(input, i1+1:i2-1) for (i1, i2) ∈ zip(s1, s2)]]
end

solution1(data) = maximum(sum, data, dims=1)[1]

solution2(data) = sum(sort(map(sum, data), rev=true)[1:3])

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