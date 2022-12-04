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

end  # module
