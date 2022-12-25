using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 21

## HELPER FUNCTIONS

function formatinput(input)
    knownvars = Dict()
    unknownvars = Dict()
    for spline ∈ map(x -> split(x, r"[:\s]+"), input)
        if length(spline) == 2
            knownvars[spline[1]] = parse(Int, spline[2])
        else
            unknownvars[spline[1]] = spline[2:end]
        end
    end
    return (knownvars, unknownvars)
end


function solve!(knownvars, unknownvars, opdict, var)
    # Recursively solve for variable var
    haskey(knownvars, var) && return knownvars[var]
    var1, op, var2 = unknownvars[var]
    res = opdict[op](solve!(knownvars, unknownvars, opdict, var1), solve!(knownvars, unknownvars, opdict, var2))
    knownvars[var] = res
    delete!(unknownvars, var)
    return res
end

function solution1(vardicts; var="root")
    knownvars, unknownvars = map(copy, vardicts)
    opdict = Dict("+" => +, "-" => -, "*" => *, "/" => /)
    return Int(solve!(knownvars, unknownvars, opdict, var))
end

function solution2(vardicts; var="root", yourvar="humn")
    # Now you have var: var1 = var2, so you want var2 - var1 = 0. Replace var 
    # operation with "-".
    # Since all operations and variables involve only real numbers, replace
    # yourvar with the imaginary unit and solve for var like part 1
    # You will get: var: a + i*b*yourvar + (c + i*d*yourvar) that must equal 0
    # You can then get yourvar = - real(var) / imag(var)
    knownvars, unknownvars = map(copy, vardicts)
    opdict = Dict("+" => +, "-" => -, "*" => *, "/" => /)
    knownvars[yourvar] = im
    unknownvars[var][2] = "-"
    complexvar = solve!(knownvars, unknownvars, opdict, var)
    return -real(complexvar) / imag(complexvar)
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