using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 3

## HELPER FUNCTIONS

getcommonitems(data) = join([intersect(compartiment[1], compartiment[2])[1] for compartiment ∈ data])

getcommonbadge(input) = join([intersect(input[k], input[k+1], input[k+2])[1] for k = 1:3:length(input)])

function solution1(input)
    priority = Dict(a => i for (i, a) ∈ enumerate(['a':'z'; 'A':'Z']))
    compartiments = [[rucksack[1:Int64(length(rucksack) / 2)], rucksack[Int64(length(rucksack) / 2)+1:end]] for rucksack ∈ input]
    sum([priority[item] for item ∈ getcommonitems(compartiments)])
end

function solution2(input)
    priority = Dict(a => i for (i, a) ∈ enumerate(['a':'z'; 'A':'Z']))
    sum([priority[item] for item ∈ getcommonbadge(input)])
end

## MAIN

if benchmarkmode

    tformatinput(nday; test=true) = IOaoc.loadinput(nday, test=test, verbose=false)
    tsolution1(input) = solution1(input)
    tsolution2(input) = solution2(input)

else

    testinput = IOaoc.loadinput(nday, test=true, verbose=verbose)
    puzzleinput = IOaoc.loadinput(nday, verbose=verbose)

    testsol1 = solution1(testinput)
    puzzlesol1 = solution1(puzzleinput)

    testsol2 = solution2(testinput)
    puzzlesol2 = solution2(puzzleinput)

    if verbose
        IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    end
end