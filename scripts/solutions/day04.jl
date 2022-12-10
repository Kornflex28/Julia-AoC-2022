using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 4

function formatinput(input)
    [[parse(Int,c) for c in split(pair,(',','-'))] for pair in input]
end

function fullycontains(pair)
    (pair[3] <= pair[1] && pair[1] <= pair[4] && pair[3] <= pair[2] && pair[2] <= pair[4]) ||
    (pair[1] <= pair[3] && pair[3] <= pair[2] && pair[1] <= pair[4] && pair[4] <= pair[2])
end

function overlaps(pair)
    (pair[1] <= pair[4] && pair[3] <= pair[2]) ||
    (pair[3] <= pair[2] && pair[1] <= pair[4])
end

function solution1(data)
    sum([fullycontains(pair) for pair in data])
end

function solution2(data)
    sum([overlaps(pair) for pair in data])
end

## MAIN

# precompile for timing
if benchmarkmode
    testinput = @timed formatinput(IOaoc.loadinput(nday,test=true,verbose=verbose))
    @timed solution1(testinput.value)
    @timed solution2(testinput.value)
end

testinput   = @timed formatinput(IOaoc.loadinput(nday,test=true,verbose=verbose))
puzzleinput = @timed formatinput(IOaoc.loadinput(nday,verbose=verbose))

testsol1   = @timed solution1(testinput.value)
puzzlesol1 = @timed solution1(puzzleinput.value)

testsol2   = @timed solution2(testinput.value)
puzzlesol2 = @timed solution2(puzzleinput.value)

if verbose
    IOaoc.printsol(testsol1.value,testsol2.value,puzzlesol1.value,puzzlesol2.value)
end