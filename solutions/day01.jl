using Printf
using FromFile
@from "../utils/IOaoc.jl" import IOaoc

function formatinput(input)
    # Split input by empty string
    splits = [firstindex(input)-1; findall(isempty,input); lastindex(input)+1]
    # Get index for each split
    s1, s2 = @view(splits[1:end-1]), @view(splits[2:end])
    # Get list of split
    [[parse(Int,i) for i in sub] for sub in [view(input, i1+1:i2-1) for (i1, i2) in zip(s1, s2)]]
end

function solution1(data)
    maximum(sum,data,dims=1)[1]
end

function solution2(data)
    sum(sort(map(sum,data),rev=true)[1:3])
end

testinput   = formatinput(IOaoc.loadinput(1,test=true))
puzzleinput = formatinput(IOaoc.loadinput(1))

testsol1   = solution1(testinput)
puzzlesol1 = solution1(puzzleinput)

testsol1   = solution1(testinput)
puzzlesol1 = solution1(puzzleinput)

testsol2   = solution2(testinput)
puzzlesol2 = solution2(puzzleinput)

@printf("Test solution 1   : %d\n",testsol1)
@printf("Test solution 2   : %d\n",testsol2)

@printf("Puzzle solution 1 : %d\n",puzzlesol1)
@printf("Puzzle solution 2 : %d\n",puzzlesol2)
