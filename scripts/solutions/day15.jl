using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 15

## HELPER FUNCTIONS

function dist(xs, ys, xb, yb)
    return abs(xs - xb) + abs(ys - yb)
end

function formatinput(input)
    pos = [map(x -> parse(Int, x.match), eachmatch(r"-?\d+", l)) for l ∈ input]
    return [((xs, ys), (xb, yb), dist(xs, ys, xb, yb)) for (xs, ys, xb, yb) ∈ pos]
end

function solution1(posdist, row=2000000)
    _, beacons, _ = zip(posdist...)
    return maximum(xs - abs(row - ys) + d + 1 for ((xs, ys), (xb, yb), d) ∈ posdist) - minimum(xs + abs(row - ys) - d for ((xs, ys), (xb, yb), d) ∈ posdist) - length(Set(bx for (bx, by) ∈ beacons if by == row))
end
function intersection(xs1, ys1, d1, xs2, ys2, d2)
    return (floor(xs2 + ys2 + d2 + xs1 - ys1 - d1) / 2, floor(xs2 + ys2 + d2 - xs1 + ys1 + d1) / 2 + 1)
end

function solution2(postdist, row=4000000)
    for (X, Y) ∈ [intersection(xs1, ys1, d1, xs2, ys2, d2) for ((xs1, ys1), _, d1) ∈ postdist for ((xs2, ys2), _, d2) ∈ postdist]
        if 0 < X && X < row && 0 < Y && Y < row && all(d < dist(X, Y, xs, ys) for ((xs, ys), _, d) ∈ postdist)
            return 4000000 * X + Y
        end
    end
end

if benchmarkmode

    tformatinput(nday; test=true) = formatinput(IOaoc.loadinput(nday, test=test, verbose=false))
    tsolution1(input) = solution1(input)
    tsolution2(input) = solution2(input)

else

    testinput = formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    puzzleinput = formatinput(IOaoc.loadinput(nday, verbose=verbose))

    testsol1 = solution1(testinput, 10)
    puzzlesol1 = solution1(puzzleinput)

    testsol2 = solution2(testinput, 20)
    puzzlesol2 = solution2(puzzleinput)

    if verbose
        IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    end
end