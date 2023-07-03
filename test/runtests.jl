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
    @test isa(event1, Event)
    @test isa(event2, Event)
    @test isa(event3, Event)
end
