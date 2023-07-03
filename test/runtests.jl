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
    @test length(on!(event1, () -> 5, () -> 6)) === 3
    @test length(prependlisteners!(event1, () -> 7; once=false)) === 4
    @test off!(event1, 1)() === 7
    @test off!(event1)() === 6
    @test emit!(event1) == [3, 5]
    @test length(once!(event1, () -> 8)) === 3
    removealllisteners!(event1; once=true)
    @test emit!(event1) == [3, 5]
    removealllisteners!(event1)
    @test emit!(event1) == []
    @test event2() == [4]
    @test event2() == []
    @test emit!(event3) == []
end
