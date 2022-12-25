using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 17

## HELPER FUNCTIONS

formatinput(input) = input[1]

function getrocks()
    # Rocks on 32 bits (AoC order)
    return [0x0000001e 0x00081c08 0x0004041c 0x10101010 0x00001818]
end

printtower(tower) = println(join(replace.(bitstring.(reverse(tower)), "0" => ".", "1" => "#"), '\n'))

intersects(obj1, obj2) = obj1 & obj2 != 0

function jetpush(rock, winddir, towermask)
    # Collision check is a bitwise and
    # Move rock is bitwise shift left or right
    leftwall = 0x40404040
    rightwall = 0x01010101
    winddir == '<' && !intersects(rock, leftwall) && !intersects((rock << 1), towermask) && return rock << 1
    winddir == '>' && !intersects(rock, rightwall) && !intersects((rock >> 1), towermask) && return rock >> 1
    return rock
end

function gettowermask(towerbytes, atheight)
    # Get 32 bit mask of tower starting at atheight
    length(towerbytes) < atheight && return 0
    return foldl((x, y) -> (x << 8) | y, reverse(towerbytes[atheight:min(atheight + 4, end)]); init=UInt32(0))
end

function rockfall!(tower, rock, wind, indwind)
    # Simulate rock falling (remember all heights are incremented by 1)

    nwind = length(wind)
    # Set rock at correct height above tower
    height = length(tower) + 4

    # Rock fall
    isfalling = true
    while isfalling

        # Get current wind direction then increment it
        winddir = wind[indwind]
        indwind = mod1(indwind + 1, nwind)
        # Get current tower state as 32 bit mask
        towermask = gettowermask(tower, height)
        # Push rock according to wind
        rock = jetpush(rock, winddir, towermask)


        if length(tower) < height - 1
            # Above the current tower, no need to check if we touch anything,
            # the rock falls
            height -= 1
        elseif height == 1 || intersects(rock, gettowermask(tower, height - 1))
            # We are below tower max height, we need to check if rock is touching
            # ground or the tower
            # Insert rock byte per byte into the tower
            for rockbyte in Iterators.takewhile(!iszero, reinterpret(UInt8, [rock]))
                if (height - 1) < length(tower)
                    tower[height] |= rockbyte
                else
                    push!(tower, rockbyte)
                end
                height += 1
            end
            # Stop falling
            isfalling = false
        else
            # Rock doesn't touch anything and keeps falling
            height -= 1
        end
    end
    return indwind
end

function solution(wind; nrockfalls=2022)

    # 16 last rows of the tower (128 bit mask)
    topoftower = Dict()

    # Get all rocks to cycle
    rocks = getrocks()
    nrocks = length(rocks)

    # First ind of wind directions and rocks
    indwind = 1
    krock = 1

    # Initial tower with "ground" => must increment all heights by 1
    tower = [0x7f]
    height = 0

    # Cycle rocks
    while krock <= nrockfalls
        # Get rock
        indrock = mod1(krock, nrocks)
        rock = rocks[indrock]
        # Rock fall
        indwind = rockfall!(tower, rock, wind, indwind)
        # Next rock
        krock += 1

        # Check state of last 16 rows (128 bit mask) with rock and wind
        (length(tower) - 1) < 16 && continue
        towerstate = reinterpret(UInt128, tower[end-15:end])
        currentstate = (towerstate, indrock, indwind)

        if haskey(topoftower, currentstate)
            # If state has already been seen skip next ones
            # Get previous state
            prevkrock, prevheight = topoftower[currentstate]
            # Number of rocks since that previous states
            cyclenrocks = krock - prevkrock
            # Number of cycle left to process
            ncyclesleft = (nrockfalls - krock) ÷ cyclenrocks
            # Skip cycles
            krock += cyclenrocks * ncyclesleft
            height += ncyclesleft * (length(tower) - prevheight)
            topoftower = Dict()

        else
            # New state, save it
            topoftower[currentstate] = (krock, length(tower))
        end
    end
    return length(tower) - 1 + height
end

if benchmarkmode

    tformatinput(nday; test=true) = formatinput(IOaoc.loadinput(nday, test=test, verbose=false))
    tsolution1(input) = solution(input)
    tsolution2(input) = solution(input, nrockfalls=1000000000000)

else

    testinput = formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    puzzleinput = formatinput(IOaoc.loadinput(nday, verbose=verbose))

    testsol1 = solution(testinput)
    puzzlesol1 = solution(puzzleinput)

    testsol2 = solution(testinput, nrockfalls=1000000000000)
    puzzlesol2 = solution(puzzleinput, nrockfalls=1000000000000)

    if verbose
        IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    end
end