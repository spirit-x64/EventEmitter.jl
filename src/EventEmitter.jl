module EventEmitter

# exports
export Listener, Event

# Types
struct Listener
    callback::Function
    once::Bool

    Listener(cb::Function, once::Bool=false) = new(cb, once)
    (l::Listener)(args...) = l.callback(args...)
end

struct Event
    name::Union{Symbol,AbstractString}
    listeners::Vector{Listener}

    function Event(n::Union{Symbol,AbstractString}, cbs::Function...; once::Bool=false)
        new(n, [Listener(cb, once) for cb ∈ cbs])
    end
    Event(n::Union{Symbol,AbstractString}, l::Listener...) = new(n, [l...])
    Event(n::Union{Symbol,AbstractString}) = new(n, [])
end

end # module
