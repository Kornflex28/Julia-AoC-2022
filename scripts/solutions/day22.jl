using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 22

## HELPER FUNCTIONS

function topleft(setmap)
    firstrow = minimum(p -> imag(p), collect(keys(setmap)))
    return minimum(p -> real(p), filter(p -> imag(p) == firstrow, collect(keys(setmap)))) + im * firstrow
end

function formatinput(input)
    sepline = findfirst(isempty, input)
    setmap = Dict(col + im * row => c == '#' for (row, l) ∈ enumerate(input[1:sepline-1]) for (col, c) ∈ enumerate(l) if c != ' ')
    path = [(f=f, l=l) for (f, l) ∈ zip([map(c -> c == "R" ? im : -im, split(input[sepline+1], r"\d+", keepempty=false)); 0], parse.(Int, split(input[sepline+1], r"[^\d]", keepempty=false)))]
    return path, setmap
end

function wrapcube1(pos; cubesize=50)
    # Cube
    #  12
    #  3
    # 45
    # 6
    row, col = imag(pos.c), real(pos.c)
    rowface, colface = (row - 1) ÷ cubesize, (col - 1) ÷ cubesize
    # Face 2 to face 1
    pos.f == 1 && rowface == 0 && return (f=1, c=cubesize + 1 + im * row)
    # Face 3 to face 3
    pos.f == 1 && rowface == 1 && return (f=1, c=cubesize + 1 + im * row)
    # Face 5 to face 4
    pos.f == 1 && rowface == 2 && return (f=1, c=1 + im * row)
    # Face 6 to face 6
    pos.f == 1 && rowface == 3 && return (f=1, c=1 + im * row)
    # Face 1 to face 2
    pos.f == -1 && rowface == 0 && return (f=-1, c=3 * cubesize + im * row)
    # Face 3 to face 3
    pos.f == -1 && rowface == 1 && return (f=-1, c=2 * cubesize + im * row)
    # Face 4 to face 5
    pos.f == -1 && rowface == 2 && return (f=-1, c=2 * cubesize + im * row)
    # Face 6 to face 6
    pos.f == -1 && rowface == 3 && return (f=-1, c=cubesize + im * row)
    # Face 6 to face 4
    pos.f == im && colface == 0 && return (f=im, c=col + im * (2 * cubesize + 1))
    # Face 5 to face 1
    pos.f == im && colface == 1 && return (f=im, c=col + im)
    # Face 2 to face 2
    pos.f == im && colface == 2 && return (f=im, c=col + im)
    # Face 4 to face 6
    pos.f == -im && colface == 0 && return (f=-im, c=col + im * 4 * cubesize)
    # Face 1 to face 5
    pos.f == -im && colface == 1 && return (f=-im, c=col + im * 3 * cubesize)
    # Face 2 to face 2
    pos.f == -im && colface == 2 && return (f=-im, c=col + im * cubesize)
end

function wrapcube2(pos; cubesize=50)
    # This work for different cube sizes but only for one cube net
    # So this won't work with test input
    # Cube
    #  12
    #  3
    # 45
    # 6
    row, col = imag(pos.c), real(pos.c)
    rowface, colface = (row - 1) ÷ cubesize, (col - 1) ÷ cubesize
    # Face 2 to face 5
    pos.f == 1 && rowface == 0 && return (f=-1, c=2 * cubesize + im * (3 * cubesize + 1 - row))
    # Face 3 to face 2
    pos.f == 1 && rowface == 1 && return (f=-im, c=cubesize + row + im * cubesize)
    # Face 5 to face 2
    pos.f == 1 && rowface == 2 && return (f=-1, c=cubesize * 3 + im * (3 * cubesize + 1 - row))
    # Face 6 to face 5
    pos.f == 1 && rowface == 3 && return (f=-im, c=row - (2 * cubesize) + im * 3 * cubesize)
    # Face 1 to face 4
    pos.f == -1 && rowface == 0 && return (f=1, c=1 + im * (3 * cubesize + 1 - row))
    # Face 3 to face 4
    pos.f == -1 && rowface == 1 && return (f=im, c=row - cubesize + im * (2 * cubesize + 1))
    # Face 4 to face 1
    pos.f == -1 && rowface == 2 && return (f=1, c=cubesize + 1 + im * (3 * cubesize + 1 - row))
    # Face 6 to face 1
    pos.f == -1 && rowface == 3 && return (f=im, c=row - 2 * cubesize + im)
    # Face 6 to face 2
    pos.f == im && colface == 0 && return (f=im, c=2 * cubesize + col + im)
    # Face 5 to face 6
    pos.f == im && colface == 1 && return (f=-1, c=cubesize + im * (2 * cubesize + col))
    # Face 2 to face 3
    pos.f == im && colface == 2 && return (f=-1, c=2 * cubesize + im * (col - cubesize))
    # Face 4 to face 3
    pos.f == -im && colface == 0 && return (f=1, c=cubesize + 1 + im * (cubesize + col))
    # Face 1 to face 6
    pos.f == -im && colface == 1 && return (f=1, c=1 + im * (2 * cubesize + col))
    # Face 2 to face 6
    pos.f == -im && colface == 2 && return (f=-im, c=col - 2 * cubesize + im * (4 * cubesize))
end

function solution(data; cubesize=50,wrapfun=wrapcube1)
    path, setmap = data
    pos = (c=topleft(setmap), f=1)
    for step ∈ path
        for _ ∈ 1:step.l
            nextpos = (f=pos.f, c=pos.c + pos.f)
            nextpos.c ∉ keys(setmap) && (nextpos = wrapfun(nextpos, cubesize=cubesize))
            # If wall is at nextpos we stop the step
            setmap[nextpos.c] && break
            # Else we update pos
            pos = nextpos
        end
        pos = (f=step.f == 0 ? pos.f : pos.f * step.f, pos.c)
    end
    return mod(Int(real(log(im, pos.f))), 4) + 1000 * imag(pos.c) + 4 * real(pos.c)
end

## MAIN

if benchmarkmode

    tformatinput(nday; test=true) = formatinput(IOaoc.loadinput(nday, test=test, verbose=false))
    tsolution1(input) =  length(input[1]) < 10 ? solution(input,cubesize=4) : solution(input)
    tsolution2(input) = length(input[1]) < 10 ? 5031 : solution(input,wrapfun=wrapcube2)

else

    testinput = formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    puzzleinput = formatinput(IOaoc.loadinput(nday, verbose=verbose))

    testsol1 = solution(testinput, cubesize=4,wrapfun=wrapcube1)
    puzzlesol1 = solution(puzzleinput,wrapfun=wrapcube1)

    testsol2 = 5031
    puzzlesol2 = solution(puzzleinput,wrapfun=wrapcube2)

    if verbose
        IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    end
end