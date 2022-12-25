using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 25

## HELPER FUNCTIONS

function decodeSNAFU(snafustr)
    isempty(snafustr) && return 0
    return findfirst(snafustr[end], "=-012") - 3 + 5 * decodeSNAFU(snafustr[1:end-1])
end

# 28 = 2*ceil(log(5,2^32))
function encodeSNAFU(n; ndigits=28)
    return chopprefix(map(x -> "=-012"[x-'0'+1], string(n + (5^ndigits - 1) >> 1, base=5)),r"0+")
end

solution1(input) = encodeSNAFU(sum(decodeSNAFU,input))

## MAIN

if benchmarkmode

    tformatinput(nday; test=true) = IOaoc.loadinput(nday, test=test, verbose=false)
    tsolution1(input) = solution1(input)
    tsolution2(input) = nothing

else

    testinput = IOaoc.loadinput(nday, test=true, verbose=verbose)
    puzzleinput = IOaoc.loadinput(nday, verbose=verbose)


    testsol1 = solution1(testinput)
    puzzlesol1 = solution1(puzzleinput)

    testsol2 = nothing
    puzzlesol2 = nothing

    if verbose
        IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    end
end