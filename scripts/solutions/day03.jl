using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 3

## HELPER FUNCTIONS
getcommonitems(data) = join([intersect(compartiment[1], compartiment[2])[1] for compartiment in data])

getcommonbadge(input) = join([intersect(input[k], input[k+1], input[k+2])[1] for k = 1:3:length(input)])

function solution1(input)
    priority = Dict(a => i for (i, a) in enumerate(['a':'z'; 'A':'Z']))
    compartiments = [[rucksack[1:Int64(length(rucksack) / 2)], rucksack[Int64(length(rucksack) / 2)+1:end]] for rucksack in input]
    sum([priority[item] for item in getcommonitems(compartiments)])
end

function solution2(input)
    priority = Dict(a => i for (i, a) in enumerate(['a':'z'; 'A':'Z']))
    sum([priority[item] for item in getcommonbadge(input)])
end

## MAIN

# precompile for timing
if benchmarkmode
    testinput = @timed IOaoc.loadinput(nday, test=true, verbose=verbose)
    @timed solution1(testinput.value)
    @timed solution2(testinput.value)
end

testinput = @timed IOaoc.loadinput(nday, test=true, verbose=verbose)
puzzleinput = @timed IOaoc.loadinput(nday, verbose=verbose)

testsol1 = @timed solution1(testinput.value)
puzzlesol1 = @timed solution1(puzzleinput.value)

testsol2 = @timed solution2(testinput.value)
puzzlesol2 = @timed solution2(puzzleinput.value)

if verbose
    IOaoc.printsol(testsol1.value, testsol2.value, puzzlesol1.value, puzzlesol2.value)
end