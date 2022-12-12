using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 6

## HELPER FUNCTIONS
function solution(input; kelem=4)
    for k = 1:(length(input)-kelem-1)
        if length(Set(input[k:(k+kelem-1)])) == kelem
            return k + kelem - 1
        end
    end
end

## MAIN

if benchmarkmode

    tformatinput(nday; test=true) = IOaoc.loadinput(nday, test=test, verbose=false)[1]
    tsolution1(input) = solution(input)
    tsolution2(input) = solution(input, kelem=14)

else

    testinput = IOaoc.loadinput(nday, test=true, verbose=verbose)[1]
    puzzleinput = IOaoc.loadinput(nday, verbose=verbose)[1]

    testsol1 = solution(testinput)
    puzzlesol1 = solution(puzzleinput)

    testsol2 = solution(testinput, kelem=14)
    puzzlesol2 = solution(puzzleinput, kelem=14)

    if verbose
        IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    end
end