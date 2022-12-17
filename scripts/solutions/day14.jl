using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 14

## HELPER FUNCTIONS
function formatinput(input)
    rocklineslist = [[map(x -> parse(Int, x), split(k, ",")) for k ∈ split(l, "->")] for l ∈ input]
    rocks = Set()
    # Parse rock lines
    for rocklines ∈ rocklineslist, k = 1:(length(rocklines)-1)
        cstart, rstart = rocklines[k]
        cend, rend = rocklines[k+1]
        if cstart == cend
            for r = rstart:sign(rend - rstart):rend
                push!(rocks, (cstart, r))
            end
        end
        if rstart == rend
            for c = cstart:sign(cend - cstart):cend
                push!(rocks, (c, rstart))
            end
        end
    end
    return rocks
end

function nextmove(rocks, sands, currentpos)
    c, r = currentpos
    down = (c, r + 1)
    downleft = (c - 1, r + 1)
    downright = (c + 1, r + 1)

    down ∉ rocks && down ∉ sands && return down
    downleft ∉ rocks && downleft ∉ sands && return downleft
    downright ∉ rocks && downright ∉ sands && return downright
    return currentpos
end

function fall(rocks, sands, start)
    maxheight = maximum(x -> x[2], rocks)
    oldpos = start
    nextpos = nextmove(rocks, sands, start)
    while nextpos[2] < maxheight && nextpos != oldpos
        oldpos = nextpos
        nextpos = nextmove(rocks, sands, oldpos)
    end
    return nextpos
end

function fall2(rocks, sands, start, maxheight)
    oldpos = start
    nextpos = nextmove(rocks, sands, start)
    while nextpos != oldpos
        oldpos = nextpos
        nextpos = nextmove(rocks, sands, oldpos)
        nc, nr = nextpos

        # If we reach ground, add rocks below
        if nr == (maxheight - 1)
            push!(rocks, (nc - 1, nr + 1))
            push!(rocks, (nc, nr + 1))
            push!(rocks, (nc + 1, nr + 1))
        end
    end
    return nextpos
end

function solution1(rocks; sandstart=(500, 0))
    sands = Set([sandstart])
    maxheight = maximum(x -> x[2], rocks)
    units = -1
    fallpos = (0, 0)
    while fallpos[2] < maxheight
        fallpos = fall(rocks, sands, sandstart)
        units += 1
        push!(sands, fallpos)
    end
    return units
end

function solution2(rocks; sandstart=(500, 0))
    maxheight = maximum(x -> x[2], rocks) + 2
    sands = Set([sandstart])
    units = 0
    fallpos = (0, 0)
    while fallpos != sandstart
        fallpos = fall2(rocks, sands, sandstart, maxheight)
        units += 1
        push!(sands, fallpos)
    end
    return units
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