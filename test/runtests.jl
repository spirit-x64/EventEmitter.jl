using EventEmitter
using Test

@testset "EventEmitter.jl" begin
    listener1 = Listener(() -> 1)
    listener2 = Listener(() -> 2, true)
    @test listener1() === 1
    @test listener2() === 2

    event1 = Event()
    event2 = Event(() -> 1, () -> 2; once=true)
    event3 = Event(Listener(() -> 3, true), Listener(() -> 4, false))
    @test listenercount(event1) === 0
    @test listenercount(event2; once=true) === 2
    @test listenercount(event3; once=false) === 1
    for e ∈ (event1, event2, event3)
        @test isa(e, Event)
        @test isa(getlisteners(e), Vector{Listener})
        @test all(l.once === true for l ∈ getlisteners(e; once=true))
        @test all(l.once === false for l ∈ getlisteners(e; once=false))
    end
    @test emit!(event1) == []
    @test event2() == [1, 2]
    @test event2() == []
    @test event3() == [3, 4]
    emit!(event3) do results
        @test results == [4]
    end
    once!(event3) do # [4, 5]
        5
    end
    on!(event3) do # [4, 5, 6]
        6
    end
    @test length(on!(event3, () -> 7)) === 4 # [4, 5, 6, 7]
    @test length(prependlisteners!(event3, () -> 8; once=false)) === 5 # [8, 4, 5, 6, 7]
    @test off!(event3, 1)() === 8 # [4, 5, 6, 7]
    @test off!(event3)() === 7 # [4, 5, 6]
    @test emit!(event3) == [4, 5, 6]
    @test length(once!(event3, () -> 9)) === 3 # [4, 6, 9]
    removealllisteners!(event3; once=true)
    @test emit!(event3) == [4, 6]
    removealllisteners!(event3)
    @test emit!(event3) == []

    arr1 = [Event(() -> 1), Event(() -> 2; once=true)]
    arr2 = [0, Event(() -> 3), Event(() -> 4; once=true)]
    @test emit!(arr1) == [[1], [2]]
    @test emit!(arr1) == [[1], []]
    @test emit!(arr2) == [0, [3], [4]]
    @test emit!(arr2) == [0, [3], []]

    t1 = (Event(() -> 1), Event(() -> 2; once=true))
    t2 = (0, Event(() -> 3), Event(() -> 4; once=true))
    @test emit!(t1) == ([1], [2])
    @test emit!(t1) == ([1], [])
    @test emit!(t2) == (0, [3], [4])
    @test emit!(t2) == (0, [3], [])

    nt1 = (a=Event(() -> 1), b=Event(() -> 2; once=true))
    nt2 = (a=0, b=Event(() -> 3), c=Event(() -> 4; once=true))
    @test emit!(nt1) == ([1], [2])
    @test emit!(nt1) == ([1], [])
    @test emit!(nt2) == (0, [3], [4])
    @test emit!(nt2) == (0, [3], [])

    dict1 = Dict(:a => Event(() -> 1), :b => Event(() -> 2; once=true))
    dict2 = Dict(1 => 0, "b" => Event(() -> 3), :c => Event(() -> 4; once=true))
    @test emit!(dict1) == [[1],[2]]
    @test emit!(dict1) == [[1], []]
    @test emit!(dict2) == [[3], [4], 0]
    @test emit!(dict2) == [[3], [], 0]
end
