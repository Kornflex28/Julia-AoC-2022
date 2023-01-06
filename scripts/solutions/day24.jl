using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 24

## HELPER FUNCTIONS

# Custom type for the map, every row for each type is saved as a UInt array
mutable struct ValleyMap
    width::UInt
    height::UInt
    positions::AbstractArray{UInt128} # All positions of character on grid
    walls::AbstractArray{UInt128} # '.'
    blizznorth::AbstractArray{UInt128} # '^'
    blizzsouth::AbstractArray{UInt128} # 'v'
    blizzwest::AbstractArray{UInt128} # '<'
    blizzeast::AbstractArray{UInt128} # '>'
end

# Custom type functions

isatstart(vm::ValleyMap) = (vm.positions[1] & (UInt128(1) << UInt128(1))) != 0 # Check if one position at second element of first row
isatgoal(vm::ValleyMap) = (vm.positions[vm.height] & (UInt128(1) << UInt128(vm.width - 2))) != 0 # Check if one position at antepenultimate element of last row
resettostart!(vm::ValleyMap) = fill!(vm.positions, 0)[1] |= UInt128(1) << UInt128(1) # Reset all positions and put it back to start
resettogoal!(vm::ValleyMap) = fill!(vm.positions, 0)[vm.height] |= UInt128(1) << UInt128(vm.width - 2) # Reset all positions and put it back to goal

# Function to update map after one minute and moving in all possible positions at the same time
function update!(vm::ValleyMap)
    # Update north blizzard accounting for walls
    circshift!(view(vm.blizznorth, 2:vm.height-1), -1)
    # Update south blizzard accounting for walls
    circshift!(view(vm.blizzsouth, 2:vm.height-1), 1)
    # Update east blizzard accounting for walls
    (vm.blizzeast.<<=UInt128(1))[vm.blizzeast.&vm.walls.!=0] .|= UInt128(1) << UInt128(1)
    vm.blizzeast .&= .~vm.walls
    # Update west blizzard accounting for walls
    (vm.blizzwest.>>=UInt128(1))[vm.blizzwest.&vm.walls.!=0] .|= (vm.walls[vm.blizzwest.&vm.walls.!=0] .>> UInt128(1))
    vm.blizzwest .&= .~vm.walls

    # Update positions row by row (we suppose the character moves in 4 directions and stays in place at the same time)
    rowabove = UInt128(0)
    for row ∈ 1:vm.height
        initrow = vm.positions[row]
        # Get position from above and move west and east
        vm.positions[row] |= rowabove | (initrow >> UInt128(1)) | (initrow << UInt128(1))
        # Get position from below
        row < vm.height && (vm.positions[row] |= vm.positions[row+1])
        rowabove = initrow
        # Remove positions on same position as blizzard or wall
        vm.positions[row] &= ~(vm.walls[row] | vm.blizznorth[row] | vm.blizzsouth[row] | vm.blizzwest[row] | vm.blizzeast[row])
    end

end


# Show function to display custom ValleyMap
function Base.show(io::IO, vm::ValleyMap)
    # Fill map with "empty" symbols
    vmstr = fill('.', vm.height, vm.width)
    # Fill map with every symbols at correct positions
    vmstr[findall(isone, reduce(hcat, digits.(vm.walls, base=2, pad=vm.width))')] .= '#'
    vmstr[findall(isone, reduce(hcat, digits.(vm.blizzwest, base=2, pad=vm.width))')] .= '<'
    vmstr[findall(isone, reduce(hcat, digits.(vm.blizzeast, base=2, pad=vm.width))')] .= '>'
    vmstr[findall(isone, reduce(hcat, digits.(vm.blizznorth, base=2, pad=vm.width))')] .= '^'
    vmstr[findall(isone, reduce(hcat, digits.(vm.blizzsouth, base=2, pad=vm.width))')] .= 'v'
    vmstr[findall(isone, reduce(hcat, digits.(vm.positions, base=2, pad=vm.width))')] .= 'O'

    # Print ValleyMap
    print(io, "ValleyMap(width:$(vm.width),height:$(vm.height)\n$(join(join.(eachrow(vmstr)),'\n'))\n)")
end

# Copy function for custom type
Base.deepcopy(vm::ValleyMap) = ValleyMap([deepcopy(getfield(vm, fn)) for fn ∈ fieldnames(ValleyMap)]...)

function formatinput(input)
    # Grid size
    width = length(input[1])
    height = length(input)

    # Grid symbols init
    walls = zeros(UInt128, height, 1)
    blizznorth = zeros(UInt128, height, 1)
    blizzsouth = zeros(UInt128, height, 1)
    blizzwest = zeros(UInt128, height, 1)
    blizzeast = zeros(UInt128, height, 1)
    presence = zeros(UInt128, height, 1)

    # Set starting position at second element of first row
    presence[1] |= 1 << 1
    # Loop through input and update each row,col for each symbol with bit shifts
    for (r, row) ∈ enumerate(input), (col, s) ∈ enumerate(row)
        s == '<' && (blizzwest[r] |= UInt128(1) << UInt128(col - 1))
        s == '>' && (blizzeast[r] |= UInt128(1) << UInt128(col - 1))
        s == '^' && (blizznorth[r] |= UInt128(1) << UInt128(col - 1))
        s == 'v' && (blizzsouth[r] |= UInt128(1) << UInt128(col - 1))
        s == '#' && (walls[r] |= UInt128(1) << UInt128(col - 1))
    end
    return ValleyMap(width, height, presence, walls, blizznorth, blizzsouth, blizzwest, blizzeast)
end

function solution1(vm)
    vm_ = deepcopy(vm)
    # Keep running until one position hits goal
    # We simulate all possible positions at the same time each step
    nround = 0
    while !isatgoal(vm_)
        update!(vm_)
        nround += 1
    end
    return nround
end

function solution2(vm)
    vm_ = deepcopy(vm)
    # Keep running until one position hits goal then go back to start then go back again to goal
    # We simulate all possible positions at the same time each step
    nround = 0
    while !isatgoal(vm_)
        update!(vm_)
        nround += 1
    end
    resettogoal!(vm_)
    while !isatstart(vm_)
        update!(vm_)
        nround += 1
    end
    resettostart!(vm_)
    while !isatgoal(vm_)
        update!(vm_)
        nround += 1
    end

    return nround
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