using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 8

## HELPER FUNCTIONS
formatinput(input) = reduce(hcat, [[parse(Int, c) for c in l] for l in input])'

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
    for krow = 2:(nrow-1)
        for kcol = 2:(ncol-1)
            visiblecount += isvisible(grid, krow, kcol)
        end
    end
    return visiblecount
end

function solution2(grid)
    nrow, ncol = size(grid)
    scenicgrid = zeros(nrow, ncol)
    for krow = 2:(nrow-1)
        for kcol = 2:(ncol-1)
            scenicgrid[krow, kcol] = scenicscore(grid, krow, kcol)
        end
    end
    return maximum(scenicgrid)
end

## MAIN

# precompile for timing
if benchmarkmode
    testinput = @timed formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    @timed solution1(testinput.value)
    @timed solution2(testinput.value)
end

testinput = @timed formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
puzzleinput = @timed formatinput(IOaoc.loadinput(nday, verbose=verbose))

testsol1 = @timed solution1(testinput.value)
puzzlesol1 = @timed solution1(puzzleinput.value)

testsol2 = @timed solution2(testinput.value)
puzzlesol2 = @timed solution2(puzzleinput.value)

if verbose
    IOaoc.printsol(testsol1.value, testsol2.value, puzzlesol1.value, puzzlesol2.value)
end