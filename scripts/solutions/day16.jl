using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 16

## HELPER FUNCTIONS

function formatinput(input)
    data = [split(l, r"[a-z\s=;,]+")[2:end] for l ∈ input]

    # Graph of valves
    valvesgraph = Dict(v1 => Set(v2) for (v1, _, v2...) in data)
    # Flow of each valves with non zero flow
    valvesflow = Dict(v1 => parse(Int, flow) for (v1, flow, _) in data if parse(Int, flow) != 0)
    # List valves of non zero flow with a power of 2 (a bit)
    # So each state of opened valves network can be represented as a binary number
    valvesbin = Dict(v => 1 << k for (k, (v, _)) in enumerate(valvesflow))

    # Floyd-Warshall to get adjacency matrix
    valvesadjency = Dict(v1 => Dict(v2 => v2 ∈ valvesgraph[v1] ? 1 : Inf for v2 ∈ keys(valvesgraph)) for v1 in keys(valvesgraph))
    for i ∈ keys(valvesadjency), j ∈ keys(valvesadjency), k ∈ keys(valvesadjency)
        valvesadjency[j][k] = min(valvesadjency[j][k], valvesadjency[j][i] + valvesadjency[i][k])
    end
    return (valvesadjency, valvesflow, valvesbin)
end

function getmaxstatesflows(valvesadjency, valvesflow, valvesbin, currentvalve, minutesleft, currentstate, currentflow, statesflows)
    # Get for all states of opened valves (represented as a binary number) its maximum final flow 

    # Set total flow of current state of opened valves to maximum of possible flows for that state
    statesflows[currentstate] = max(get(statesflows, currentstate, 0), currentflow)
    # Check for each valves (non-zero flow ones)
    for nextvalve ∈ keys(valvesflow)
        # Time to get to next valve and open it
        newminutesleft = minutesleft - valvesadjency[currentvalve][nextvalve] - 1
        # Check if next valve is open or no time to go to next valve and open it
        ((valvesbin[nextvalve] & currentstate) != 0 || newminutesleft <= 0) && continue
        # Compute new state flow (by opening next valve)
        newstate = currentstate | valvesbin[nextvalve]
        newcurrentflow = currentflow + newminutesleft * valvesflow[nextvalve]
        getmaxstatesflows(valvesadjency, valvesflow, valvesbin, nextvalve, newminutesleft, newstate, newcurrentflow, statesflows)
    end
    return statesflows
end

function solution1(data; startingvalve="AA", minutesleft=30)
    valvesadjency, valvesflow, valvesbin = data
    maxstatesflows = getmaxstatesflows(valvesadjency, valvesflow, valvesbin, startingvalve, minutesleft, 0, 0, Dict())
    # Return best states
    return maximum(values(maxstatesflows))
end

function solution2(data; startingvalve="AA", minutesleft=26)
    valvesadjency, valvesflow, valvesbin = data
    maxstatesflows = getmaxstatesflows(valvesadjency, valvesflow, valvesbin, startingvalve, minutesleft, 0, 0, Dict())
    # Return best combinaison of states that share no common opened valves
    return maximum(flow1 + flow2 for (state1, flow1) in maxstatesflows, (state2, flow2) in maxstatesflows if (state1 & state2) == 0)
end

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