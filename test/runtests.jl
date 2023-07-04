using EventEmitter
using Test

@testset "EventEmitter.jl" begin
    listener1 = Listener(() -> 1)
    listener2 = Listener(() -> 2, true)
    @test listener1() === 1
    @test listener2() === 2

    event1 = Event(:event1, () -> 3; once=false)
    event2 = Event(:event2, Listener(() -> 4, true))
    event3 = Event(:event3)
    @test listenercount(event1) === 1
    @test listenercount(event2; once=true) === 1
    @test listenercount(event2; once=false) === 0
    @test all(l.once === true for l ∈ getlisteners(event1; once=true))
    @test all(l.once === false for l ∈ getlisteners(event2; once=false))
    @test isa(getlisteners(event2), Vector{Listener})
    @test isa(event3, Event)
    @test emit!(event1) == [3]
    emit!(event1) do result
        @test result === 3
    end
    once!(event1) do
        5
    end
    on!(event1) do
        6
    end
    @test length(on!(event1, () -> 7)) === 4
    @test length(prependlisteners!(event1, () -> 8; once=false)) === 5
    @test off!(event1, 1)() === 8
    @test off!(event1)() === 7
    @test emit!(event1) == [3, 5, 6]
    @test length(once!(event1, () -> 9)) === 3
    removealllisteners!(event1; once=true)
    @test emit!(event1) == [3, 6]
    removealllisteners!(event1)
    @test emit!(event1) == []
    @test event2() == [4]
    @test event2() == []
    @test emit!(event3) == []

    arr1 = [Event(:event4, () -> 10), Event(:event5, () -> 11; once=true)]
    arr2 = [0, Event(:event6, () -> 12), Event(:event7, () -> 13; once=true)]
    @test emit!(arr1) == [[10], [11]]
    @test emit!(arr1) == [[10], []]
    @test emit!(arr2) == [0, [12], [13]]
    @test emit!(arr2) == [0, [12], []]
    @test eventnames(arr1) == [:event4, :event5]
    @test eventnames(arr2) == [0, :event6, :event7]

    t1 = (Event(:event8, () -> 14), Event(:event9, () -> 15; once=true))
    t2 = (0, Event(:event10, () -> 16), Event(:event11, () -> 17; once=true))
    @test emit!(t1) == ([14], [15])
    @test emit!(t1) == ([14], [])
    @test emit!(t2) == (0, [16], [17])
    @test emit!(t2) == (0, [16], [])
    @test eventnames(t1) == (:event8, :event9)
    @test eventnames(t2) == (0, :event10, :event11)

    nt1 = NamedTuple(Event(:event12, () -> 18), Event(:event13, () -> 19; once=true))
    nt2 = (notevent=0, event14=Event(:event14, () -> 20))
    @test emit!(nt1) == ([18], [19])
    @test emit!(nt1) == ([18], [])
    @test emit!(nt2) == (0, [20])
    @test eventnames(nt1) == (:event12, :event13)
    @test eventnames(nt2) == (0, :event14)

    dict1 = Dict(Event(:event15, () -> 21), Event(:event16, () -> 22; once=true))
    dict2 = Dict(0 => Event(:event17))
    @test isa(dict1, Dict{Symbol, Event})
    @test isa(dict2, Dict{<:Any, Event})
end
