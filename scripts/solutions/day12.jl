using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 12

## HELPER FUNCTIONS
formatinput(input) = Dict((r, c) => ch == 'S' ? -0.1 : ch == 'E' ? 'z' - 'a' + 0.1 : ch - 'a' for (r, l) ∈ enumerate(input) for (c, ch) ∈ enumerate(l))

## MAIN
function possible_neighbors(heightmap, rc)
    r, c = rc
    Iterators.filter(x -> (x ∈ keys(heightmap) && (heightmap[x] - heightmap[rc] < 2)), ((r + dr, c + dc) for (dr, dc) ∈ [(-1, 0) (1, 0) (0, 1) (0, -1)]))
end

function climb!(heightmap, steps, iso)
    nextmoves = Set([rcdrdc for rc ∈ last(iso) for rcdrdc ∈ possible_neighbors(heightmap, rc) if rcdrdc ∉ keys(steps)])
    merge!(steps, Dict(rc => length(iso) for rc ∈ nextmoves))
    isempty(nextmoves) || climb!(heightmap, steps, [iso nextmoves])
end

function isoheights(heightmap, rcstarts)
    steps = Dict(rc => 0 for rc ∈ rcstarts)
    climb!(heightmap, steps, [Set(rcstarts)])
    return steps
end

function solution1(heightmap)
    rcstarts = [k for (k, v) ∈ heightmap if v == -0.1]
    rcend = first([k for (k, v) ∈ heightmap if v == 'z' - 'a' + 0.1])
    steps = isoheights(heightmap, rcstarts)
    return rcend ∈ keys(steps) ? steps[rcend] : typemax(Int64)
end

function solution2(heightmap)
    rcstarts = [k for (k, v) ∈ heightmap if v <= 0]
    rcend = first([k for (k, v) ∈ heightmap if v == 'z' - 'a' + 0.1])
    steps = isoheights(heightmap, rcstarts)
    return rcend ∈ keys(steps) ? steps[rcend] : typemax(Int64)
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