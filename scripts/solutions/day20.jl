using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 20

## HELPER FUNCTIONS

formatinput(input) = collect(enumerate([parse(Int, l) for l ∈ input]))

function solution(input; key=1, nmix=1)
    mixed = [(i, key * v) for (i, v) in input]
    N = length(input)
    for x ∈ repeat(mixed, nmix)
        ind = findfirst(isequal(x), mixed)
        popat!(mixed, ind)
        insert!(mixed, mod1(ind + x[2], N - 1), x)
    end
    mixed = last.(mixed)
    return sum(mixed[mod1.(findfirst(iszero, mixed) .+ [1000, 2000, 3000], N)])
end

if benchmarkmode

    tformatinput(nday; test=true) = formatinput(IOaoc.loadinput(nday, test=test, verbose=false))
    tsolution1(input) = solution(input)
    tsolution2(input) = solution(input,key=811589153,nmix=10)

else

    testinput = formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    puzzleinput = formatinput(IOaoc.loadinput(nday, verbose=verbose))


    testsol1 = solution(testinput)
    puzzlesol1 = solution(puzzleinput)

    testsol2 = solution(testinput,key=811589153,nmix=10)
    puzzlesol2 = solution(puzzleinput,key=811589153,nmix=10)

    if verbose
        IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    end
end