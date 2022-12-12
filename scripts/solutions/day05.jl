using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 5

## HELPER FUNCTIONS
function formatinput(input)
    sep_ind = findfirst(isempty, input)
    input[sep_ind+1:end]

    ncolumns = parse(Int, input[sep_ind-1][findall(r"(\d)", input[sep_ind-1])[end]])
    crate_ind = 2:4:(ncolumns*4)
    stacks = [[] for _ = 1:ncolumns]
    for kline = 1:(sep_ind-2)
        for (kcrate, crate) in enumerate(input[kline][crate_ind])
            if crate != ' '
                push!(stacks[kcrate], crate)
            end
        end
    end
    moves = [[parse(Int, m) for m in split(move, r"(move|from|to)", keepempty=false)] for move in input[(sep_ind+1):end]]
    return (stacks, moves)
end

function makemove(stacks, move; crane=0)
    if crane != 0
        stacks[move[3]] = [stacks[move[2]][1:move[1]]..., stacks[move[3]]...]
    else
        stacks[move[3]] = [reverse!(stacks[move[2]][1:move[1]])..., stacks[move[3]]...]
    end
    deleteat!(stacks[move[2]], 1:move[1])
    return stacks
end

function rearrange(stacks, moves; crane=0)
    for move in moves
        stacks = makemove(stacks, move, crane=crane)
    end
    return stacks
end

function solution1(data)
    stacks1, moves1 = deepcopy(data[1]), deepcopy(data[2])
    stacks1 = rearrange(stacks1, moves1)
    join([crates[1] for crates in stacks1])
end

function solution2(data)
    stacks2, moves2 = deepcopy(data[1]), deepcopy(data[2])
    stacks2 = rearrange(stacks2, moves2, crane=1)
    join([crates[1] for crates in stacks2])
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