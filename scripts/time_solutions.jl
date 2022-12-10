using Printf

## PARAMETERS TO UPDATE

# Number of evaluation of each solution script
neval = 5
benchmarkmode = true

## PARAMETERS

# Find solution scripts
solutionspath = normpath(joinpath(@__DIR__,"solutions"))
solutions = readdir(solutionspath; join=true)
nfiles = length(solutions)
ntotal = nfiles*neval
# Array of execution times, last dimension is for format/solve/test/puzzle/1/2
exectimes = fill(NaN,(neval,nfiles,6))

## MAIN

# Loop through solutions
for (ksol,sol) in enumerate(solutions)
    
    for keval in 1:neval
        @printf("\r(%d/%d) Execution %02d/%d of %s ...",(ksol-1)*neval+keval,ntotal,keval,neval,sol)
        # Execute solution
        include(sol)
        
        # Get timed variables
        exectimes[keval,nday,1] = testinput.time
        exectimes[keval,nday,4] = puzzleinput.time
        exectimes[keval,nday,2] = testsol1.time
        exectimes[keval,nday,5] = puzzlesol1.time
        exectimes[keval,nday,3] = testsol2.time
        exectimes[keval,nday,6] = puzzlesol2.time
    end
end
@printf("\nAll %d executions done.\n",ntotal)
