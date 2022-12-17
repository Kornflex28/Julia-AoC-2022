using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 9

## HELPER FUNCTIONS
formatinput(input) = [(d, parse(Int, n)) for (d, n) ∈ map(split, input)]

function solution(steps; nknots=2)
    moves = Dict("L" => -1, "R" => 1, "U" => im, "D" => -im)
    # Reference point
    startpos = 0
    # Array of each rope parts position, 1 is head, end is tail
    rope = startpos * complex(ones(1, nknots))
    # Array of visited positions for each rope parts
    visited = [Set(pos) for pos ∈ rope]

    # Loop through all steps, Make all moves from step
    for (dir, nmoves) ∈ steps, _ = 1:nmoves
        # Move head of rope
        rope[1] += moves[dir]
        # Move remaining parts of rope one after each other
        for kpart = 2:nknots
            # Compute complex distance to the previous part of the rope
            dist = rope[kpart-1] - rope[kpart]
            if sqrt(2) < abs(dist)
                # Move part ∈ the correct direction (sign(0)=0)
                rope[kpart] += sign(real(dist)) + sign(imag(dist)) * im
            end
        end
        # Update visited positions Array
        for kpart ∈ eachindex(visited)
            union!(visited[kpart], rope[kpart])
        end
    end

    return length(visited[end])
end

## MAIN

if benchmarkmode

    tformatinput(nday; test=true) = formatinput(IOaoc.loadinput(nday, test=test, verbose=false))
    tsolution1(input) = solution(input)
    tsolution2(input) = solution(input, nknots=10)

else

    testinput = formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    puzzleinput = formatinput(IOaoc.loadinput(nday, verbose=verbose))

    testsol1 = solution(testinput)
    puzzlesol1 = solution(puzzleinput)

    testsol2 = solution(testinput, nknots=10)
    puzzlesol2 = solution(puzzleinput, nknots=10)

    if verbose
        IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    end
end