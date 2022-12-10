using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 6

function solution(input;kelem=4)
    for k = 1:(length(input)-kelem-1)
        if length(Set(input[k:(k+kelem-1)])) == kelem
            return k+kelem-1
        end
    end
end

## MAIN

# precompile for timing
if benchmarkmode
    testinput = @timed IOaoc.loadinput(nday,test=true,verbose=verbose)[1]
    @timed solution(testinput.value)
    @timed solution(testinput.value)
end

testinput   = @timed IOaoc.loadinput(nday,test=true,verbose=verbose)[1]
puzzleinput = @timed IOaoc.loadinput(nday,verbose=verbose)[1]

testsol1   = @timed solution(testinput.value)
puzzlesol1 = @timed solution(puzzleinput.value)

testsol2   = @timed solution(testinput.value,kelem=14)
puzzlesol2 = @timed solution(puzzleinput.value,kelem=14)

if verbose
    IOaoc.printsol(testsol1.value,testsol2.value,puzzlesol1.value,puzzlesol2.value)
end