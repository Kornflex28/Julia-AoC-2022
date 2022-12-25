using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 18

## HELPER FUNCTIONS

formatinput(input) = Set((x, y, z) for (x, y, z) ∈ map(x -> parse.(Int, split(x, ",")), input))

function solution1(scans)
    neighbours = Set([(1, 0, 0) (-1, 0, 0) (0, 1, 0) (0, -1, 0) (0, 0, 1) (0, 0, -1)])
    return sum([(x + dx, y + dy, z + dz) ∉ scans for (x, y, z) ∈ scans, (dx, dy, dz) ∈ neighbours])
end

function solution2(scans)
    # Check only cubes of the outer shell
    neighbours = Set([(1, 0, 0) (-1, 0, 0) (0, 1, 0) (0, -1, 0) (0, 0, 1) (0, 0, -1)])
    minx, maxx = extrema(x for (x, _, _) ∈ scans)
    miny, maxy = extrema(y for (_, y, _) ∈ scans)
    minz, maxz = extrema(z for (_, _, z) ∈ scans)

    outershell = Set()
    nextcube = [(minx - 1, miny - 1, minz - 1)]
    while !isempty(nextcube)
        (x, y, z) = pop!(nextcube)
        push!(outershell, (x, y, z))
        for (dx, dy, dz) ∈ neighbours
            nextx, nexty, nextz = (x + dx, y + dy, z + dz)
            (minx - 1) <= nextx <= (maxx + 1) && (miny - 1) <= nexty <= (maxy + 1) && (minz - 1) <= nextz <= (maxz + 1) &&
            (nextx, nexty, nextz) ∉ outershell && (nextx, nexty, nextz) ∉ scans &&
            push!(nextcube, (nextx, nexty, nextz))
        end

    end
    return sum([(x + dx, y + dy, z + dz) ∈ outershell for (x, y, z) ∈ scans, (dx, dy, dz) ∈ neighbours])
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