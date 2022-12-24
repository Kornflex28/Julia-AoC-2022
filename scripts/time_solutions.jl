using Printf

## PARAMETERS TO UPDATE

# Number of evaluation of each solution script
neval = (@isdefined neval) ? neval : 50
benchmarkmode = true

## PARAMETERS

# Find solution scripts
solutionspath = normpath(joinpath(@__DIR__, "solutions"))
solutions = readdir(solutionspath; join=true)
nfiles = length(solutions)
ntotal = nfiles * neval
# Array of execution times, last dimension is for format/solve/test/puzzle/1/2
exectimes = fill(NaN, (neval, nfiles, 6))
days = zeros(nfiles,1)


## MAIN

# Loop through solutions
for (ksol, sol) ∈ enumerate(solutions)

    include(sol) # "Import" functions

    days[ksol] = nday

    for keval ∈ 0:neval
        @printf("\r(%d/%d) Execution %d/%d of %s ...", (ksol - 1) * neval + keval, ntotal, keval, neval, sol)

        # Execute solution
        puzzleinput = @timed tformatinput(nday)
        puzzlesol1 = @timed tsolution1(puzzleinput.value)
        puzzlesol2 = @timed tsolution2(puzzleinput.value)
        testinput = @timed tformatinput(nday, test=true)
        testsol1 = @timed tsolution1(testinput.value)
        testsol2 = @timed tsolution2(testinput.value)

        keval == 0 && continue # Don't consider first run (always longer)

        # Get timed variables
        exectimes[keval, ksol, 1] = testinput.time
        exectimes[keval, ksol, 2] = testsol1.time
        exectimes[keval, ksol, 3] = testsol2.time
        exectimes[keval, ksol, 4] = puzzleinput.time
        exectimes[keval, ksol, 5] = puzzlesol1.time
        exectimes[keval, ksol, 6] = puzzlesol2.time

    end
end

@printf("\nAll %d executions done.\n", ntotal)
