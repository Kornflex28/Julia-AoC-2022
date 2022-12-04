module IOaoc

using Printf

inputsTest = "./inputs/test/"
inputsPuzzle = "./inputs/puzzle/"

"""
    loadinput(fpath::Int)

Load AoC input file (text file)

# Arguments
- `nday::Int`: day of the problem
"""
function loadinput(nday::Int; test::Bool=false, verbose::Bool=true)
    fpath = test ? @sprintf("%sday%02d",inputsTest,nday) : @sprintf("%sday%02d",inputsPuzzle,nday)
    verbose && @printf("Loading %s\n",abspath(fpath))
    open(fpath) do file
        readlines(file)
    end
end

function printsol(testsol1,testsol2,puzzlesol1,puzzlesol2)
    @printf("Test solution 1   : %d\n",testsol1)
    @printf("Test solution 2   : %d\n",testsol2)
    println(" ")
    @printf("Puzzle solution 1 : %d\n",puzzlesol1)
    @printf("Puzzle solution 2 : %d\n",puzzlesol2)
end

end  # module
