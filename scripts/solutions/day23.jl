using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 23

## HELPER FUNCTIONS

formatinput(input) = Set((1 - row, col) for (row, l) ∈ enumerate(input) for (col, c) ∈ enumerate(l) if c == '#')


function neighbours(pos)
    # Array order: [SW,S,SE,W,E,NW,N,NE]
    y, x = pos
    return setdiff([(y + dy, x + dx) for (dx, dy) ∈ Iterators.product(-1:1, -1:1)], [pos])
end

function elfmove(setmap, e, moveset)
    # Index in neighbours(e) array to check for the moves, movemap[1][1] is the 
    # next move if possible
    ne = neighbours(e)
    # Loop through moves in order, stop when possible
    for movecheck ∈ eachrow(moveset)
        isdisjoint(ne[movecheck], setmap) && return ne[movecheck[1]]
    end
    return nothing
end

function step!(setmap_, moveset)
    # Get all possible moving elves
    movingelves = [e for e ∈ setmap_ if !isdisjoint(neighbours(e), setmap_)]
    # Get all planned moves
    setmap__ = copy(setmap_)
    moved = 0
    for e ∈ movingelves
        y, x = e
        ne = elfmove(setmap__, e, moveset)
        isnothing(ne) && continue
        ny, nx = ne
        # If elf already in nextpos, it means we already moved one elf to this pos, we must move it back
        if ne ∈ setmap_
            delete!(setmap_, ne)
            push!(setmap_, (2 * ny - y, 2 * nx - x))
            moved -= 2
        else # no elf in position, update position
            delete!(setmap_, e)
            push!(setmap_, ne)
            moved += 1
        end
    end
    return moved > 0
end

function solution1(setmap; nsteps=10)
    setmap_ = copy(setmap)
    moveset = [[7 6 8]; [2 3 1]; [4 6 1]; [5 8 3]]
    # Loop through steps
    for k ∈ 0:(nsteps-1)
        step!(setmap_, circshift(moveset, -mod(k, 4)))
    end
    # Return number of empty tiles in smallest rectangle containing elves
    return (abs(-(extrema(x -> x[1], setmap_)...)) + 1) * (abs(-(extrema(x -> x[2], setmap_)...)) + 1) - length(setmap_)
end

function solution2(setmap)
    setmap_ = copy(setmap)
    moveset = [[7 6 8]; [2 3 1]; [4 6 1]; [5 8 3]]
    # Loop until no one moves
    k = 0
    moved = true
    while moved
        moved = step!(setmap_, circshift(moveset, -mod(k, 4)))
        k += 1
    end
    return k
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
    for k in 1:10
        @timed puzzlesol2 = solution2(puzzleinput)
    end
    if verbose
        IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    end
end