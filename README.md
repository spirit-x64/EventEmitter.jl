# EventEmitter
> Events in julia

<div align="center">
  <br />
  <p>
    <a href="https://julialang.org/"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Julia_Programming_Language_Logo.svg/320px-Julia_Programming_Language_Logo.svg.png" alt="Julia Programming Language Logo" /></a>
  </p>
  <p>
    <a href="https://discord.gg/fsgRUpK"><img src="https://img.shields.io/discord/726050330068123679?color=000000&logo=discord&logoColor=white" alt="Spirit's discord server" /></a>
    <a target="_blank" href="https://github.com/8bou3/EventEmitter.jl/actions/workflows/CI.yml?query=branch%3Amain"><img src="https://github.com/8bou3/EventEmitter.jl/actions/workflows/CI.yml/badge.svg?branch=main" alt="Build Status" /></a>
  </p>
  Julia package to easly implement event pattern in julia
</div>

## Installation

```julia
using Pkg; Pkg.add(url="https://github.com/8bou3/EventEmitter.jl")
```

## License

All code licensed under the [MIT license][license].

<!-- Markdown link & img dfn's -->
[discord-url]: https://discord.gg/fsgRUpK
[license]: LICENSE
[example.env]: example.env

## Getting started
First run
```julia
using EventEmitter
```
Construct an `Event`
```julia
myevent = Event()
```
You can pass callback functions as arguments
```julia
myfunction() = println("function")
myevent = Event(myfunction, () -> println("Arrow function"))
```
Listeners are `on` by default. change this by setting `once`
```julia
myevent = Event((x) -> print(x); once=true)
```
Or construct listeners manually and pass them
```julia
# Listener(callback, once)
myevent = Event(Listener(() -> 1), Listener(() -> 2, true))
```
Use `on!()` or `once!()` to add listeners
```julia
on!(myevent) do
  return "called everytime"
end
once!(myevent) do
  return "called once"
end
```
Emit an event by calling it or using `emit!()`
```julia
myevent() # [1, 2, "called everytime", "called once"]
emit!(myevent) # [1, "called everytime"]
```
Listeners are called in order
```julia
myevent = Event(() -> 1, () -> 2)
on!(myevent, () -> 3)

myevent() # [1, 2, 3]
```
Use `prependlisteners!()` to prepend listeners
```julia
prependlisteners!(myevent, () -> 4, () -> 5)
myevent() # [4, 5, 1, 2, 3]
```
Use `off!()` to remove a `Listener`

\*`off!()` returns the `Listener` it removes, so doing `off!(event)()` will call it\*
```julia
off!(myevent)() # 3 - (last) equivalent to `off!(myevent, 0)()`
off!(myevent, 1)() # 4 - (first)
off!(myevent, -1)() # 1 - (before last)
myevent() # [5, 2]
```
Construct collections of `Event`s (arrays, tuples, named tuples and dictionaries)
```julia
event1 = Event(() -> 1)
event2 = Event(() -> 2)
arr = [event1, event2]
tuple = (event1, event2)
namedtuple = (a=event1, b=event2)
dict = Dict(:a => event1, :b => event2)
```
Emit the collections

\*emitting a dict will give almost random order for the events\*
```julia
emit!(arr) # [[1], [2]]
emit!(tuple) # [[1], [2]]
emit!(namedtuple) # [[1], [2]]
emit!(dict) # [[1], [2]]
```
