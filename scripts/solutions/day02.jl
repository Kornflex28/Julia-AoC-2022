using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 2

## HELPER FUNCTIONS
function convertRPS(l)
    if l ∈ ["A" "X"]
        return 1
    elseif l ∈ ["B" "Y"]
        return 2
    else
        return 3
    end
end

function playRPS(plays; player=2)
    # Return [play, results] of RPS of the specified player
    opponent = 3 - player
    d = abs(plays[1] - plays[2])
    if d == 0
        return [plays[player] 3]
    elseif d == 1
        return [plays[player] plays[player] > plays[opponent] ? 6 : 0]
    else
        return [plays[player] plays[player] < plays[opponent] ? 6 : 0]
    end
end

function possibleRPS(play)
    if play == 1
        return [3 1 2]
    elseif play == 2
        return [1 2 3]
    else
        return [2 3 1]
    end
end

score(results) = sum(results)

formatinput(input) = [[convertRPS(l) for l ∈ row] for row ∈ map(split, input)]

solution1(data) = sum(map(score, [playRPS(p, player=2) for p ∈ data]))

function solution2(data)
    plays1 = [plays[1] for plays ∈ data]
    plays2 = [plays[2] for plays ∈ data]
    plays = [[plays1[k], possibleRPS(plays1[k])[plays2[k]]] for k ∈ eachindex(plays1)]
    sum(map(score, [playRPS(p, player=2) for p ∈ plays]))
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