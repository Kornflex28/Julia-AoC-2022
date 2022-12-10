using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 5

function formatinput(input)
    sep_ind = findfirst(isempty,input)
    input[sep_ind+1:end]

    ncolumns = parse(Int,input[sep_ind-1][findall(r"(\d)",input[sep_ind-1])[end]])
    crate_ind = 2:4:(ncolumns*4)
    stacks = [[] for _=1:ncolumns]
    for kline = 1:(sep_ind-2)
        for (kcrate,crate) in enumerate(input[kline][crate_ind])
            if crate != ' '
                push!(stacks[kcrate],crate)
            end
        end
    end
    moves = [[parse(Int,m) for m in split(move,r"(move|from|to)",keepempty=false)] for move in input[(sep_ind+1):end]]
    return (stacks,moves)
end

function makemove(stacks,move;crane=0)
    if crane != 0
        stacks[move[3]] = [stacks[move[2]][1:move[1]]..., stacks[move[3]]...]
    else
        stacks[move[3]] = [reverse!(stacks[move[2]][1:move[1]])..., stacks[move[3]]...]
    end
    deleteat!(stacks[move[2]],1:move[1])
    return stacks
end

function rearrange(stacks,moves;crane=0)
    for move in moves
        stacks = makemove(stacks,move,crane=crane)
    end
    return stacks
end

function solution1(data)
    stacks1, moves1 = deepcopy(data[1]),deepcopy(data[2])
    stacks1 = rearrange(stacks1,moves1)
    join([crates[1] for crates in stacks1])
end

function solution2(data)
    stacks2, moves2 = deepcopy(data[1]),deepcopy(data[2])
    stacks2 = rearrange(stacks2,moves2,crane=1)
    join([crates[1] for crates in stacks2])
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