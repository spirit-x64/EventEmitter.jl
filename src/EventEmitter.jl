module EventEmitter

export Listener, Event, listenercount, getlisteners,
    addlisteners!, prependlisteners!, removelistener!, removealllisteners!,
    on!, once!, off!, emit!

struct Listener
    callback::Function
    once::Bool

    Listener(cb::Function, once::Bool=false) = new(cb, once)
    (l::Listener)(args...) = l.callback(args...)
end

struct Event
    listeners::Vector{Listener}

    Event(cbs::Function...; once::Bool=false) = new([Listener(cb, once) for cb ∈ cbs])
    Event(l::Listener...) = new([l...])
    Event() = new([])
    (e::Event)(args::Any...) = emit!(e, args...)
end

addlisteners!(e::Event, l::Listener...) = push!(e.listeners, l...)
function addlisteners!(e::Event, cbs::Function...; once::Bool=false)
    addlisteners!(e, (Listener(cb, once) for cb ∈ cbs)...)
end

prependlisteners!(e::Event, l::Listener...) = pushfirst!(e.listeners, l...)
function prependlisteners!(e::Event, cbs::Function...; once::Bool=false)
    prependlisteners!(e, (Listener(cb, once) for cb ∈ cbs)...)
end

function removelistener!(e::Event, i::Int)
    index = i ≤ 0 ? i += length(e.listeners) : i
    listener = e.listeners[index]
    deleteat!(e.listeners, index)
    return listener
end
removelistener!(e::Event) = pop!(e.listeners)

function removealllisteners!(e::Event; once::Union{Bool,Nothing}=nothing)
    once === nothing ? empty!(e.listeners) : deleteat!(e.listeners, [l.once === once for l ∈ e.listeners])
end

on!(e::Event, cbs::Function...) = addlisteners!(e, cbs...; once=false)
on!(cb::Function, e::Event) = addlisteners!(e, cb; once=false)

once!(e::Event, cbs::Function...) = addlisteners!(e, cbs...; once=true)
once!(cb::Function, e::Event) = addlisteners!(e, cb; once=true)

const off! = removelistener!

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
emit!(cb::Function, e::Event, args::Any...) = cb(emit!(e, args...))
emit!(arr::AbstractArray{Event}, args::Any...) = [e() for e in arr]
emit!(arr::AbstractArray, args::Any...) = [isa(i, Event) ? i() : i for i in arr]
emit!(t::Tuple{Vararg{Event}}, args::Any...) = Tuple(e() for e in t)
emit!(t::Tuple, args::Any...) = Tuple(isa(i, Event) ? i() : i for i in t)
emit!(nt::NamedTuple{<:Any,<:Tuple{Vararg{Event}}}, args::Any...) = Tuple(e(args...) for e in nt)
emit!(nt::NamedTuple, args::Any...) = Tuple(isa(e, Event) ? e(args...) : e for e in nt)
emit!(dict::AbstractDict{<:Any,Event}, args::Any...) = [e(args...) for e in values(dict)]
emit!(dict::AbstractDict, args::Any...) = [isa(e, Event) ? e(args...) : e for e in values(dict)]

function listenercount(e::Event; once::Union{Bool,Nothing}=nothing)
    once === nothing ? length(e.listeners) : length(filter((l::Listener) -> l.once === once, e.listeners))
end

function getlisteners(e::Event; once::Union{Bool,Nothing}=nothing)
    once === nothing ? e.listeners : filter((l::Listener) -> l.once === once, e.listeners)
end

end # module
