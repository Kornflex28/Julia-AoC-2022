using Printf
using FromFile
@from "../utils/IOaoc.jl" import IOaoc

function convertRPS(l)
    if l in ["A" "X"]
        return 1
    elseif l in ["B" "Y"]
        return 2
    else
        return 3
    end
end

function playRPS(plays;player=2)
    # Return [play, results] of RPS of the specified player
    opponent = 3-player
    d = abs(plays[1]-plays[2])
    if d == 0
        return [plays[player] 3]
    elseif d == 1
        return [plays[player] plays[player]>plays[opponent] ? 6 : 0]
    else
        return [plays[player] plays[player]<plays[opponent] ? 6 : 0]
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

function score(results)
    sum(results)
end

function formatinput(input)
    [[convertRPS(l) for l in row] for row in map(split,input)]
end

function solution1(data)
    sum(map(score,[playRPS(p,player=2) for p in data]))
end

function solution2(data)
    plays1 = [plays[1] for plays in data]
    plays2 = [plays[2] for plays in data]
    plays = [[plays1[k],possibleRPS(plays1[k])[plays2[k]]] for k in eachindex(plays1)]
    sum(map(score,[playRPS(p,player=2) for p in plays]))
end

testinput   = @timed formatinput(IOaoc.loadinput(2,test=true))
puzzleinput = @timed formatinput(IOaoc.loadinput(2))

testsol1   = @timed solution1(testinput.value)
puzzlesol1 = @timed solution1(puzzleinput.value)

testsol2   = @timed solution2(testinput.value)
puzzlesol2 = @timed solution2(puzzleinput.value)


IOaoc.printsol(testsol1.value,testsol2.value,puzzlesol1.value,puzzlesol2.value)
