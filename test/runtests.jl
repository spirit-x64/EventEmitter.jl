using EventEmitter
using Test

@testset "EventEmitter.jl" begin
    listener1 = Listener(() -> 1)
    listener2 = Listener(() -> 2, true)
    @test listener1() === 1
    @test listener2() === 2

    event1 = Event(:event1, () -> 1; once=false)
    event2 = Event(() -> 2; once=true)
    event3 = Event("event3", Listener(() -> 3, true))
    event4 = Event(Listener(() -> 4, true))
    event5 = Event(:event5)
    event6 = Event()
    @test listenercount(event1) === 1
    @test listenercount(event2; once=true) === 1
    @test listenercount(event2; once=false) === 0
    for e ∈ (event1, event2, event3, event4, event5, event6)
        @test any(e === i for i ∈ (event1, event3, event5)) ? hasname(e) : !hasname(e)
        @test isa(e, Event)
        @test isa(getlisteners(e), Vector{Listener})
        @test all(l.once === true for l ∈ getlisteners(e; once=true))
        @test all(l.once === false for l ∈ getlisteners(e; once=false))
    end
    @test emit!(event1) == [1]
    @test event2() == [2]
    @test event2() == []
    @test event3() == [3]
    @test event3() == []
    @test event4() == [4]
    @test event4() == []
    @test event5() == []
    @test event6() == []
    emit!(event1) do result
        @test result === 1
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
    @test emit!(event1) == [1, 5, 6]
    @test length(once!(event1, () -> 9)) === 3
    removealllisteners!(event1; once=true)
    @test emit!(event1) == [1, 6]
    removealllisteners!(event1)
    @test emit!(event1) == []

    arr1 = [Event(:event1, () -> 1), Event(() -> 2; once=true)]
    arr2 = [0, Event(:event2, () -> 3), Event(() -> 4; once=true)]
    @test emit!(arr1) == [[1], [2]]
    @test emit!(arr1) == [[1], []]
    @test emit!(arr2) == [0, [3], [4]]
    @test emit!(arr2) == [0, [3], []]
    @test eventnames(arr1) == [:event1, nothing]
    @test eventnames(arr2) == [0, :event2, nothing]

    t1 = (Event(:event1, () -> 1), Event(() -> 2; once=true))
    t2 = (0, Event(:event2, () -> 3), Event(() -> 4; once=true))
    @test emit!(t1) == ([1], [2])
    @test emit!(t1) == ([1], [])
    @test emit!(t2) == (0, [3], [4])
    @test emit!(t2) == (0, [3], [])
    @test eventnames(t1) == (:event1, nothing)
    @test eventnames(t2) == (0, :event2, nothing)

    nt1 = NamedTuple(Event(:event1, () -> 1), Event(:event2, () -> 2; once=true))
    nt2 = (notevent=0, event=Event(:event2, () -> 3), event3=Event(() -> 4))
    @test emit!(nt1) == ([1], [2])
    @test emit!(nt1) == ([1], [])
    @test emit!(nt2) == (0, [3], [4])
    @test eventnames(nt1) == (:event1, :event2)
    @test eventnames(nt2) == (0, :event2, :event3)

    dict1 = Dict(Event(:event1, () -> 1), Event(() -> 2; once=true))
    dict2 = Dict("a" => 0, "b" => Event(:event3, () -> 3), :event4 => Event()) # Automatically add event name from pair construct
    @test emit!(dict1) == [[2], [1]]
    @test emit!(dict1) == [[], [1]]
    @test emit!(dict2) == [[], [3], 0]
    @test eventnames(dict1) == [nothing, :event1]
    @test eventnames(dict2) == [:event4, :event3, 0]
end
