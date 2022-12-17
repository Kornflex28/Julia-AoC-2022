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
            return sum([getsize(child) for child ∈ dorf.children])
        end
    end

    function getalldirs(d::Dir)
        if isnothing(d.children)
            return []
        else
            childrendir = d.children[findall(c -> isa(c, Dir), d.children)]
            return [d [getalldirs(c) for c ∈ childrendir]...]
        end
    end

    function Base.show(io::IO, s::Union{Dir,File})
        parentstr = isnothing(s.parent) ? nothing : s.parent.name
        childrenstr = (isa(s, File) || isnothing(s.children)) ? nothing : join([c.name for c ∈ s.children], ",")
        if isnothing(childrenstr)
            print(io, "[$(s.name), $(parentstr)]")
        else
            print(io, "[$(s.name), $(parentstr), ($(childrenstr))]")
        end
    end

end
function splitcmd(l)
    _, cmd, ags... = split(l)
    return cmd, ags
end

function formatinput(input)

    # Find all command occ
    cmdind = findall(l -> occursin(r"^\$", l), input)
    cmdind = cmdind[2:end]
    # Create list of [(cmd,args[])]
    cmdargs = map(splitcmd, input[cmdind])
    push!(cmdind, length(input) + 1)

    # Create file tree
    root = Dir("/")
    currentdir = root

    for k ∈ eachindex(cmdargs)
        cmd, ags = cmdargs[k]

        # If cmd is ls, update file tree
        if cmd == "ls"
            # Loop through all ls result
            ls = input[cmdind[k]+1:cmdind[k+1]-1]
            for l ∈ ls
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
    dirsizes = [getsize(d) for d ∈ getalldirs(root)]
    return sum(dirsizes[dirsizes.<=sizelim])
end

function solution2(root; sizelim=30000000, totalsize=70000000)
    dirsizes = [getsize(d) for d ∈ getalldirs(root)]
    return minimum(dirsizes[sizelim.<=((totalsize-dirsizes[1]).+dirsizes)])
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
    puzzlesol2 = solution2(puzzleinput)

    if verbose
        IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    end
end