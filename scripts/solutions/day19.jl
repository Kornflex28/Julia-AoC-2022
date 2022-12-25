using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 19

## HELPER FUNCTIONS

if !(@isdefined BluePrint)
    mutable struct BluePrint
        orebot::UInt8
        claybot::UInt8
        obsidianbot::Tuple{UInt8,UInt8}
        geodebot::Tuple{UInt8,UInt8}
        maxore::UInt8

        # Constructor
        function BluePrint(orebot, claybot, obsidianbot, geodebot)
            new(orebot, claybot, obsidianbot, geodebot, max(orebot, claybot, obsidianbot[1], geodebot[1]))
        end
    end
end

function Base.show(io::IO, bp::BluePrint)
    print(io,"BluePrint(orebot:$(bp.orebot), claybot:$(bp.claybot), obsidianbot:($(bp.obsidianbot[1]),$(bp.obsidianbot[2])), geodebot:($(bp.geodebot[1]),$(bp.geodebot[2])), maxore:$(bp.maxore))")
end



## MAIN

if benchmarkmode

    tformatinput(nday; test=true) = formatinput(IOaoc.loadinput(nday, test=test, verbose=false))
    tsolution1(input) = solution1(input)
    tsolution2(input) = solution2(input)

else

    #     testinput = formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    #     puzzleinput = formatinput(IOaoc.loadinput(nday, verbose=verbose))

    #     testsol1 = solution1(testinput)
    #     puzzlesol1 = solution1(puzzleinput)

    #     testsol2 = solution2(testinput)
    #     puzzlesol2 = solution2(puzzleinput)

    #     if verbose
    #         IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    #     end
end