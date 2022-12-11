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
    [[parse(Int, i) for i in sub] for sub in [view(input, i1+1:i2-1) for (i1, i2) in zip(s1, s2)]]
end

solution1(data) = maximum(sum, data, dims=1)[1]

solution2(data) = sum(sort(map(sum, data), rev=true)[1:3])

## MAIN

# precompile for timing
if benchmarkmode
    testinput = @timed formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    @timed solution1(testinput.value)
    @timed solution2(testinput.value)
end

testinput = @timed formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
puzzleinput = @timed formatinput(IOaoc.loadinput(nday, verbose=verbose))

testsol1 = @timed solution1(testinput.value)
puzzlesol1 = @timed solution1(puzzleinput.value)

testsol2 = @timed solution2(testinput.value)
puzzlesol2 = @timed solution2(puzzleinput.value)

if verbose
    IOaoc.printsol(testsol1.value, testsol2.value, puzzlesol1.value, puzzlesol2.value)
end