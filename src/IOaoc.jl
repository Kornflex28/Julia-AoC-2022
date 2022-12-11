module IOaoc

using Printf

inputsTest = normpath(joinpath(@__DIR__, "..", "inputs", "test"))
inputsPuzzle = normpath(joinpath(@__DIR__, "..", "inputs", "puzzle"))

"""
    loadinput(fpath::Int)

Load AoC input file (text file)

# Arguments
- `nday::Int`: day of the problem
"""
function loadinput(nday::Int; test::Bool=false, verbose::Bool=true)
    fpath = test ? @sprintf("%s/day%02d", inputsTest, nday) : @sprintf("%s/day%02d", inputsPuzzle, nday)
    verbose && @printf("Loading %s\n", abspath(fpath))
    open(fpath) do file
        readlines(file)
    end
end

function printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    if typeof(testsol1) <: Number
        @printf("Test solution 1   : %d\n", testsol1)
    else
        @printf("Test solution 1   : %s\n", testsol1)
    end

    if typeof(testsol2) <: Number
        @printf("Test solution 2   : %d\n", testsol2)
    else
        @printf("Test solution 2   : %s\n", testsol2)
    end

    println(" ")

    if typeof(puzzlesol1) <: Number
        @printf("Puzzle solution 1 : %d\n", puzzlesol1)
    else
        @printf("Puzzle solution 1 : %s\n", puzzlesol1)
    end
    if typeof(puzzlesol2) <: Number
        @printf("Puzzle solution 2 : %d\n", puzzlesol2)
    else
        @printf("Puzzle solution 2 : %s\n", puzzlesol2)
    end
end

end  # module
