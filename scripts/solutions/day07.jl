using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 7

## HELPER FUNCTIONS
if !(@isdefined Dir)
    abstract type AbstractFile end
    abstract type AbstractDir end

    function addchildren!(d::AbstractDir, c::Union{<:AbstractDir,<:AbstractFile})
        if isnothing(d.children)
            d.children = [c]
        else
            push!(d.children, c)
        end
    end

    mutable struct Dir <: AbstractDir
        name::AbstractString
        parent::Union{Dir,Nothing}
        children::Union{Vector{Union{Dir,<:AbstractFile}},Nothing}

        function Dir(name::AbstractString, parent::Union{Dir,Nothing}=nothing, children::Union{Vector{Union{Dir,<:AbstractFile}},Nothing}=nothing)
            d = new(name, parent, children)
            if !isnothing(parent)
                addchildren!(parent, d)
            end
            return d
        end
    end

    function findchildbyname(d::Dir, name::AbstractString; isDir=true)
        if isDir
            return d.children[findfirst(c -> isa(c, Dir) && c.name == name, d.children)]
        else
            return d.children[findfirst(c -> !isa(c, Dir) && c.name == name, d.children)]
        end
    end

end


if !(@isdefined File)
    mutable struct File <: AbstractFile
        name::AbstractString
        parent::Dir
        size::Int
        function File(name::AbstractString, parent::Dir, size::Int)
            f = new(name, parent, size)
            addchildren!(parent, f)
            return f
        end
    end

    function getsize(dorf::Union{Dir,File})
        if isa(dorf, File)
            return dorf.size
        else
            return sum([getsize(child) for child in dorf.children])
        end
    end

    function getalldirs(d::Dir)
        if isnothing(d.children)
            return []
        else
            childrendir = d.children[findall(c -> isa(c, Dir), d.children)]
            return [d [getalldirs(c) for c in childrendir]...]
        end
    end

    function Base.show(io::IO, s::Union{Dir,File})
        parent_str = isnothing(s.parent) ? nothing : s.parent.name
        children_str = (isa(s, File) || isnothing(s.children)) ? nothing : join([c.name for c in s.children], ",")
        if isnothing(children_str)
            print(io, "[$(s.name), $(parent_str)]")
        else
            print(io, "[$(s.name), $(parent_str), ($(children_str))]")
        end
    end

end
function splitcmd(l)
    _, cmd, ags... = split(l)
    return cmd, ags
end

function formatinput(input)

    # Find all command occ
    cmd_ind = findall(l -> occursin(r"^\$", l), input)
    cmd_ind = cmd_ind[2:end]
    # Create list of [(cmd,args[])]
    cmd_args = map(splitcmd, input[cmd_ind])
    push!(cmd_ind, length(input) + 1)

    # Create file tree
    root = Dir("/")
    currentdir = root

    for k in eachindex(cmd_args)
        cmd, ags = cmd_args[k]

        # If cmd is ls, update file tree
        if cmd == "ls"
            # Loop through all ls result
            ls = input[cmd_ind[k]+1:cmd_ind[k+1]-1]
            for l in ls
                dirorsize, name = split(l)
                if dirorsize == "dir"
                    Dir(name, currentdir)
                else
                    File(name, currentdir, parse(Int, dirorsize))
                end
            end
        else # cd
            targetdir = ags[1]
            if targetdir == "/"
                currentdir = root
            elseif targetdir == ".."
                currentdir = currentdir.parent
            else
                currentdir = findchildbyname(currentdir, targetdir)
            end
        end
    end

    return root
end


function solution1(root; sizelim=100000)
    dirsizes = [getsize(d) for d in getalldirs(root)]
    return sum(dirsizes[dirsizes.<=sizelim])
end

function solution2(root; sizelim=30000000, totalsize=70000000)
    dirsizes = [getsize(d) for d in getalldirs(root)]
    return minimum(dirsizes[sizelim.<=((totalsize-dirsizes[1]).+dirsizes)])
end

## MAIN

# precompile for timing
if benchmarkmode
    testinput = @timed formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    @timed solution1(testinput.value)
    @timed solution2(testinput.value)
end

testinput = @timed formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
puzzleinput = @timed formatinput(IOaoc.loadinput(nday, verbose=verbose))

testsol1 = @timed solution1(testinput.value)
puzzlesol1 = @timed solution1(puzzleinput.value)

testsol2 = @timed solution2(testinput.value)
puzzlesol2 = @timed solution2(puzzleinput.value)

if verbose
    IOaoc.printsol(testsol1.value, testsol2.value, puzzlesol1.value, puzzlesol2.value)
end