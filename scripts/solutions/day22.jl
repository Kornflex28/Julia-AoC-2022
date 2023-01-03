using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 22

## HELPER FUNCTIONS

function nextpos(setmap, pos, step)

    # Get row/column of direction to move
    if real(pos.f) != 0
        posline = sort(filter(p -> imag(p[1]) == imag(pos.c), collect(setmap)), by=p -> real(p[1]))
    else
        posline = sort(filter(p -> real(p[1]) == real(pos.c), collect(setmap)), by=p -> imag(p[1]))
    end

    # Get list of positions on the path
    indpos = mod1.(findfirst(isequal(pos.c), getindex.(posline, 1)) .+ ((0:step.l) .* (real(pos.f) - imag(pos.f))), length(posline))
    indnpos = findfirst(getindex.(posline[indpos], 2))
    isnothing(indnpos) && return (c=posline[indpos[end]][1], f=step.f == 0 ? pos.f : pos.f * step.f)
    return (c=posline[indpos[indnpos-1]][1], f=step.f == 0 ? pos.f : pos.f * step.f)

end

function topleft(setmap)
    firstrow = minimum(p -> imag(p), collect(keys(setmap)))
    return minimum(p -> real(p), filter(p -> imag(p) == firstrow, collect(keys(setmap)))) + im * firstrow
end

function formatinput(input)
    sepline = findfirst(isempty, input)
    setmap = Dict(col + im * row => c == '#' for (row, l) ∈ enumerate(input[1:sepline-1]) for (col, c) ∈ enumerate(l) if c != ' ')
    path = [(f=f, l=l) for (f, l) ∈ zip([map(c -> c == "R" ? -im : im, split(input[sepline+1], r"\d+", keepempty=false)); 0], parse.(Int, split(input[sepline+1], r"[^\d]", keepempty=false)))]
    return path, setmap
end

function solution1(data)
    path, setmap = data
    pos = (c=topleft(setmap), f=1)
    for step ∈ path
        pos = nextpos(setmap, pos, step)
    end
    # println(path)
    return mod(Int(real(log(im, conj(pos.f)))), 4) + 1000 * imag(pos.c) + 4 * real(pos.c)
end

function wrapcube(pos; cubesize=50)
    # Cube
    #  12
    #  3
    # 45
    # 6
    row, col = imag(pos.c), real(pos.c)
    rowface, colface = (row - 1) ÷ cubesize, (col - 1) ÷ cubesize
    # Face 2 to face 5
    pos.f == 1 && rowface == 0 && (println(1);return (f=-1, c=2 * cubesize + im * (3 * cubesize + 1 - row)))
    # Face 3 to face 2
    pos.f == 1 && rowface == 1 && (println(2);return (f=im, c=cubesize + row + im * cubesize))
    # Face 5 to face 2
    pos.f == 1 && rowface == 2 && (println(3);return (f=-1, c=cubesize * 3 + im * (3 * cubesize + 1 - row)))
    # Face 6 to face 5
    pos.f == 1 && rowface == 3 && (println(4);return (f=im, c=row - (2 * cubesize) + im * 3 * cubesize))
    # Face 1 to face 4
    pos.f == -1 && rowface == 0 && (println(5);return (f=1, c=1 + im * (3 * cubesize + 1 - row)))
    # Face 3 to face 4
    pos.f == -1 && rowface == 1 && (println(6);return (f=-im, c=row - cubesize + im * (2 * cubesize + 1)))
    # Face 4 to face 1
    pos.f == -1 && rowface == 2 && (println(7);return (f=1, c=cubesize + 1 + im * (3 * cubesize + 1 - row)))
    # Face 6 to face 1
    pos.f == -1 && rowface == 3 && (println(8);return (f=-im, c=row - 2 * cubesize + im))
    # Face 6 to face 2
    pos.f == -im && colface == 0 && (println(9);return (f=-im, c=2 * cubesize + col + im))
    # Face 5 to face 6
    pos.f == -im && colface == 1 && (println(10);return (f=-1, c=cubesize + im * (2 * cubesize + col)))
    # Face 2 to face 3
    pos.f == -im && colface == 2 && (println(11);return (f=-1, c=2 * cubesize + im * (col - cubesize)))
    # Face 4 to face 3
    pos.f == im && colface == 0 && (println(12);return (f=1, c=2 * cubesize + im * (cubesize + col)))
    # Face 1 to face 6
    pos.f == im && colface == 1 && (println(13);return (f=1, c=1 + im * (2 * cubesize + col)))
    # Face 2 to face 6
    pos.f == im && colface == 2 && (println(14);return (f=im, c=col - 2 * cubesize + im * (4 * cubesize)))
end

function solution2(data;cubesize=4)
    path, setmap = data
    pos = (c=topleft(setmap), f=1)
    for step ∈ path
        for _ ∈ 1:step.l
            nextpos = (f=pos.f, c=pos.c + pos.f)
            # println(nextpos)
            nextpos.c ∉ keys(setmap) && (nextpos = wrapcube(nextpos,cubesize=cubesize))
            setmap[nextpos.c] && (nextpos = pos; break)
            pos = nextpos
        end
        pos = (f=step.f == 0 ? pos.f : pos.f * step.f, pos.c)
    end
    # println(pos)
    return mod(Int(real(log(im, conj(pos.f)))), 4) + 1000 * imag(pos.c) + 4 * real(pos.c)
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
    puzzlesol2 = solution2(puzzleinput,cubesize=50)

    # if verbose
    #     IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    # end
end