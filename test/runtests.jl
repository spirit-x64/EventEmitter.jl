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

    arr1 = [Event(:event1, () -> 1), Event(:event2, () -> 2; once=true)]
    arr2 = [0, Event(:event3, () -> 3), Event(:event4, () -> 4; once=true)]
    @test emit!(arr1) == [[1], [2]]
    @test emit!(arr1) == [[1], []]
    @test emit!(arr2) == [0, [3], [4]]
    @test emit!(arr2) == [0, [3], []]
    @test eventnames(arr1) == [:event1, :event2]
    @test eventnames(arr2) == [0, :event3, :event4]

    t1 = (Event(:event1, () -> 1), Event(:event2, () -> 2; once=true))
    t2 = (0, Event(:event3, () -> 3), Event(:event4, () -> 4; once=true))
    @test emit!(t1) == ([1], [2])
    @test emit!(t1) == ([1], [])
    @test emit!(t2) == (0, [3], [4])
    @test emit!(t2) == (0, [3], [])
    @test eventnames(t1) == (:event1, :event2)
    @test eventnames(t2) == (0, :event3, :event4)

    nt1 = NamedTuple(Event(:event1, () -> 1), Event(:event2, () -> 2; once=true))
    nt2 = (notevent=0, event3=Event(:event3, () -> 3))
    @test emit!(nt1) == ([1], [2])
    @test emit!(nt1) == ([1], [])
    @test emit!(nt2) == (0, [3])
    @test eventnames(nt1) == (:event1, :event2)
    @test eventnames(nt2) == (0, :event3)

    dict1 = Dict(Event(:event1, () -> 1), Event(:event2, () -> 2; once=true))
    dict2 = Dict("a" => 0, "b" => Event(:event3))
    @test emit!(dict1) == [[1], [2]]
    @test emit!(dict1) == [[1], [],]
    @test emit!(dict2) == [[], 0]
    @test eventnames(dict1) == [:event1, :event2]
    @test eventnames(dict2) == [:event3, 0]
end
