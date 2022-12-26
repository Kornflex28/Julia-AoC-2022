using Printf
using FromFile
@from "$(normpath(joinpath(@__DIR__,"..","..","src","IOaoc.jl")))" import IOaoc

## PARAMETERS
benchmarkmode = (@isdefined benchmarkmode) ? benchmarkmode : false
verbose = !benchmarkmode
nday = 19

## HELPER FUNCTIONS

if !(@isdefined BluePrint)
    mutable struct BluePrint
        orebot::UInt8
        claybot::UInt8
        obsidianbot::Tuple{UInt8,UInt8}
        geodebot::Tuple{UInt8,UInt8}
        maxore::UInt8

        # Constructor
        function BluePrint(orebot, claybot, obsidianbot, geodebot)
            new(orebot, claybot, obsidianbot, geodebot, max(orebot, claybot, obsidianbot[1], geodebot[1]))
        end
    end
end

if !(@isdefined CollectingState)
    mutable struct CollectingState
        remaining::UInt8
        orebot::UInt8
        claybot::UInt8
        obsidianbot::UInt8
        ore::UInt8
        clay::UInt8
        obsidian::UInt8

        # Constructor
        CollectingState(remaining::Integer=24, orebot::Integer=1, claybot::Integer=0, obsidianbot::Integer=0, ore::Integer=0, clay::Integer=0, obsidian::Integer=0) = new(remaining, orebot, claybot, obsidianbot, ore, clay, obsidian)
    end
end

copy(self::CollectingState) = CollectingState([getfield(self, fn) for fn ∈ fieldnames(CollectingState)]...)


function collect!(self::CollectingState, time::Integer=1)
    self.ore += self.orebot * time
    self.clay += self.claybot * time
    self.obsidian += self.obsidianbot * time
    self.remaining -= time
    return self
end

function buildbot!(self::CollectingState, bp::BluePrint, bot::AbstractString)
    if bot == "ore"
        self.ore -= bp.orebot
        self.orebot += 1
    elseif bot == "clay"
        self.ore -= bp.claybot
        self.claybot += 1
    elseif bot == "obsidian"
        self.ore -= bp.obsidianbot[1]
        self.clay -= bp.obsidianbot[2]
        self.obsidianbot += 1
    elseif bot == "geode"
        self.ore -= bp.geodebot[1]
        self.obsidian -= bp.geodebot[2]
    else
        error("Unknow bot : $(bot)")
    end
    return self
end

function timetobot(self::CollectingState, bp::BluePrint, bot::AbstractString; buildtime::Integer=1)
    # Return number of time units to get to specific bot (nothing if impossible)
    if bot == "ore"
        return UInt16(cld(max(0, bp.orebot - self.ore), self.orebot) + buildtime)
    elseif bot == "clay"
        return UInt16(cld(max(0, bp.claybot - self.ore), self.orebot) + buildtime)
    elseif bot == "obsidian"
        (self.orebot == 0 || self.claybot == 0) && return NaN
        return UInt16(max(cld(max(0, bp.obsidianbot[1] - self.ore), self.orebot), cld(max(0, bp.obsidianbot[2] - self.clay), self.claybot)) + buildtime)
    elseif bot == "geode"
        (self.orebot == 0 || self.obsidianbot == 0) && return NaN
        return UInt16(max(cld(max(0, bp.geodebot[1] - self.ore), self.orebot), cld(max(0, bp.geodebot[2] - self.obsidian), self.obsidianbot)) + buildtime)
    else
        error("Unknow bot : $(bot)")
    end
end

function getcurrentmaxgeodes(self::CollectingState, bp::BluePrint)
    # Simulate spawning a geodebot every minute
    timetocollect = bp.geodebot[2] <= self.obsidian ? UInt16(self.remaining) : UInt16(max(1, self.remaining - 1))
    return timetocollect * (timetocollect - 1) ÷ 2
end

function getmaxgeodes(self::CollectingState, bp::BluePrint, current, best, selfcache)

    self.remaining <= 1 && return 0
    # haskey(selfcache, self) && return selfcache[self]
    # (current + getcurrentmaxgeodes(self, bp) <= best[1]) && return [0 best[1]]

    my_best = 0
    timetoorebot = timetobot(self, bp, "ore")
    timetoclaybot = timetobot(self, bp, "clay")
    timetoobsidianbot = timetobot(self, bp, "obsidian")
    timetogeodebot = timetobot(self, bp, "geode")

    if timetogeodebot < self.remaining
        nextself = buildbot!(collect!(copy(self), timetogeodebot), bp, "geode")
        my_best = getmaxgeodes(nextself, bp, current + nextself.remaining, best, selfcache) + nextself.remaining
    end

    if self.obsidianbot < bp.geodebot[2] && 3 <= self.remaining && timetoobsidianbot < self.remaining
        nextself = buildbot!(collect!(copy(self), timetoobsidianbot), bp, "obsidian")
        my_best = max(my_best, getmaxgeodes(    nextself, bp, current, best, selfcache))
    end

    if self.claybot < bp.obsidianbot[2] && 4 <= self.remaining && timetoclaybot < self.remaining
        nextself = buildbot!(collect!(copy(self), timetoclaybot), bp, "clay")
        my_best = max(my_best, getmaxgeodes(nextself, bp, current, best, selfcache))
    end

    if self.orebot < bp.maxore && 3 <= self.remaining && timetoorebot < self.remaining
        nextself = buildbot!(collect!(copy(self), timetoorebot), bp, "ore")
        my_best = max(my_best, getmaxgeodes(nextself, bp, current, best, selfcache))
    end

    # selfcache[self] = [my_best, best[1]]
    best[1] = max(best[1], my_best + current)
    # println([my_best, best[1]])
    return my_best
end

function solution1(bps)
    for bp ∈ bps
        println(getmaxgeodes(CollectingState(24),bp,0,[0],Dict()))
    end
end


formatinput(input) = [BluePrint(ore, cla, (obs1, obs2), (geo1, geo2)) for (_, ore, cla, obs1, obs2, geo1, geo2) ∈ map(l -> parse.(UInt8, split(l, r"[^\d]+", keepempty=false)), input)]

function Base.show(io::IO, bp::BluePrint)
    print(io, "BluePrint(orebot:$(bp.orebot), claybot:$(bp.claybot), obsidianbot:($(bp.obsidianbot[1]),$(bp.obsidianbot[2])), geodebot:($(bp.geodebot[1]),$(bp.geodebot[2])), maxore:$(bp.maxore))")
end

function Base.show(io::IO, cs::CollectingState)
    print(io, "CollectingState(remaining:$(cs.remaining), ore:$(cs.ore), clay:$(cs.clay), obsidian:$(cs.obsidian), orebot:$(cs.orebot), claybot:$(cs.claybot), obsidianbot:$(cs.obsidianbot))")
end

## MAIN

if benchmarkmode

    tformatinput(nday; test=true) = formatinput(IOaoc.loadinput(nday, test=test, verbose=false))
    tsolution1(input) = solution1(input)
    tsolution2(input) = solution2(input)

else

    testinput = formatinput(IOaoc.loadinput(nday, test=true, verbose=verbose))
    #     puzzleinput = formatinput(IOaoc.loadinput(nday, verbose=verbose))

    testsol1 = solution1(testinput)
    #     puzzlesol1 = solution1(puzzleinput)

    #     testsol2 = solution2(testinput)
    #     puzzlesol2 = solution2(puzzleinput)

    #     if verbose
    #         IOaoc.printsol(testsol1, testsol2, puzzlesol1, puzzlesol2)
    #     end
end