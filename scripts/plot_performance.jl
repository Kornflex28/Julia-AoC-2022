using Plots
using Printf
using StatsPlots
using Statistics
using Dates
using Plots.PlotMeasures

## PARAMETERS
neval = 500
include(joinpath(@__DIR__, "time_solutions.jl"))
# exectimes [neval;nfiles;[formattest,solvetest1,solvetest2,formatpuzzle,solvepuzzle1,solvepuzzle2]]

lightbarcolors = [:peachpuff2 :chocolate :brown4 :lightskyblue :deepskyblue3 :navy]
darkbarcolors = [:gold :darkorange :firebrick1 :lightslateblue :springgreen3 :deepskyblue]
# barcolors = [lightbarcolors; darkbarcolors]
barcolors = [darkbarcolors; darkbarcolors]
backgroundcolors = [:white nothing]
textcolors = [:black :white]

annotationstr = @sprintf("generated on %s - %s (GitHub Actions)", Dates.format(now(), "yyyy-mm-dd HH:MM:SS"), Sys.cpu_info()[1].model)

## MAIN
mediantimes = dropdims(median(exectimes, dims=1), dims=1)

for (k, thm) ∈ enumerate(["light", "dark"])

     plot(title="Time performance of Julia solutions for AoC 2022", xlabel="Day",
          ylabel=@sprintf("Run time [s]\n(median, %d runs)", neval),
          yminorgrid=true, yminorgridalpha=0.1, size=(800, 400), margin=3mm,
          background_color=backgroundcolors[k])

     plot!(days,mediantimes, legend=:topleft, label=["Test format" "Test solve 1" "Test Solve 2" "Puzzle format" "Puzzle solve 1" "Puzzle solve 2"],
          yscale=:log10, color=reduce(hcat, barcolors[k, :]), line=:dash, linewidth=[1 1 1 2 2 2], marker=[:circle :circle :circle :diamond :diamond :diamond])

     xticks!(1:maximum(days))
     threshold = log10(5)
     mnexp = round(log10(minimum(x for x in mediantimes if !isnan(x))) - threshold + 0.5)
     mxexp = ceil(log10(maximum(x for x in mediantimes if !isnan(x))))
     ylims!(0.2 * 10^mnexp, 10^(mxexp))
     yticks!(10 .^ (mnexp:mxexp))

     plot!(legendcolumns=1)
     annotate!(0.5 + xlims()[2] / 2, 1.4 * ylims()[2], text(annotationstr, :center, 8, color=textcolors[k]))

     figname = "time_performance_$(thm).svg"
     figpath = normpath(joinpath(@__DIR__, "..", "figs", figname))
     savefig(figpath)
     println("Saved to $(figpath)")
end