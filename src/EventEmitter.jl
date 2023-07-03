module EventEmitter

# exports
export Listener, Event,
    emit!,
    listenercount, getlisteners

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

# Functions
function emit!(e::Event, args::Any...)
    results::Vector{Any} = []
    todelete::Vector{Bool} = []
    for l ∈ e.listeners
        try
            push!(results, l(args...))
            push!(todelete, l.once)
        catch exc
            push!(results, exc)
            push!(todelete, false)
        end
    end
    deleteat!(e.listeners, todelete)
    return results
end
emit!(cb::Function, e::Event, args::Any...) = cb(emit!(e, args...)...)

listenercount(e::Event; once::Bool) = length(filter((l::Listener) -> l.once === once, e.listeners))
listenercount(e::Event) = length(e.listeners)

getlisteners(e::Event; once::Bool) = filter((l::Listener) -> l.once === once, e.listeners)
getlisteners(e::Event) = e.listeners

end # module
