using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 9

## HELPER FUNCTIONS
formatinput(input) = [(d, parse(Int, n)) for (d, n) in map(split, input)]

function solution(steps; nknots=2)
    moves = Dict("L" => -1, "R" => 1, "U" => im, "D" => -im)
    # Reference point
    startpos = 0
    # Array of each rope parts position, 1 is head, end is tail
    rope = startpos * complex(ones(1, nknots))
    # Array of visited positions for each rope parts
    visited = [Set(pos) for pos in rope]

    # Loop through all steps
    for (dir, nmoves) in steps
        # Make all moves from step
        for _ = 1:nmoves
            # Move head of rope
            rope[1] += moves[dir]
            # Move remaining parts of rope one after each other
            for kpart = 2:nknots
                # Compute complex distance to the previous part of the rope
                dist = rope[kpart-1] - rope[kpart]
                if sqrt(2) < abs(dist)
                    # Move part in the correct direction (sign(0)=0)
                    rope[kpart] += sign(real(dist)) + sign(imag(dist)) * im
                end
            end
            # Update visited positions Array
            for kpart in eachindex(visited)
                union!(visited[kpart], rope[kpart])
            end
        end
    end

    return length(visited[end])
end

## MAIN

# precompile for timing
if benchmarkmode
    testinput = @timed formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    @timed solution(testinput.value)
    @timed solution(testinput.value,nknots=10)
end

testinput = @timed formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
puzzleinput = @timed formatinput(IOaoc.loadinput(nday, verbose=verbose))

testsol1 = @timed solution(testinput.value)
puzzlesol1 = @timed solution(puzzleinput.value)

testsol2 = @timed solution(testinput.value,nknots=10)
puzzlesol2 = @timed solution(puzzleinput.value,nknots=10)

if verbose
    IOaoc.printsol(testsol1.value, testsol2.value, puzzlesol1.value, puzzlesol2.value)
end