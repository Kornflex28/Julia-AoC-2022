using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 13

## HELPER FUNCTIONS

formatinput(input) = [eval(Meta.parse(l)) for (k, l) ∈ enumerate(input) if k % 3 != 0]

function compare(left, right)

    # Two integers
    if isa(left, Int) && isa(right, Int)
        left < right && return true
        left > right && return false
        return -1
    end

    # Two lists
    if isa(left, Array) && isa(right, Array)
        nleft, nright = length(left), length(right)
        for ind = 1:max(nleft, nright)
            nleft < ind && return true
            nright < ind && return false
            res = compare(left[ind], right[ind])
            res != -1 && return res
        end
        return -1
    end

    # Left is Int
    if isa(left, Int)
        return compare([left], right)
    end

    # Right is Int
    if isa(right, Int)
        return compare(left, [right])
    end
end

function solution1(data)
    lines = zip(data[1:2:end-1], data[2:2:end])
    return sum([k for (k, (left, right)) ∈ enumerate(lines) if compare(left, right)])
end

function solution2(data)
    return (sum([compare(l, [[2]]) for l ∈ data]) + 1) * (sum([compare(l, [[6]]) for l ∈ data]) + 2)

end

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