using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 8

## HELPER FUNCTIONS
formatinput(input) = reduce(hcat, [[parse(Int, c) for c ∈ l] for l ∈ input])'

function isvisible(grid, krow, kcol)
    h = grid[krow, kcol]
    all(grid[krow, kcol+1:end] .< h) || all(grid[krow, 1:kcol-1] .< h) || all(grid[1:krow-1, kcol] .< h) || all(grid[krow+1:end, kcol] .< h)
end

function scenicscore(grid, krow, kcol)
    nrow, ncol = size(grid)
    h = grid[krow, kcol]

    taller(x) = h <= x

    left = findfirst(taller, grid[krow, (kcol-1):-1:1])
    left = isnothing(left) ? kcol - 1 : left

    right = findfirst(taller, grid[krow, kcol+1:end])
    right = isnothing(right) ? ncol - kcol : right

    up = findfirst(taller, grid[(krow-1):-1:1, kcol])
    up = isnothing(up) ? krow - 1 : up

    down = findfirst(taller, grid[krow+1:end, kcol])
    down = isnothing(down) ? nrow - krow : down
    return up * down * left * right
end

function solution1(grid)
    nrow, ncol = size(grid)
    visiblecount = 2 * (nrow + ncol) - 4
    for krow = 2:(nrow-1), kcol = 2:(ncol-1)
        visiblecount += isvisible(grid, krow, kcol)
    end
    return visiblecount
end

function solution2(grid)
    nrow, ncol = size(grid)
    scenicgrid = zeros(nrow, ncol)
    for krow = 2:(nrow-1), kcol = 2:(ncol-1)
        scenicgrid[krow, kcol] = scenicscore(grid, krow, kcol)
    end
    return maximum(scenicgrid)
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