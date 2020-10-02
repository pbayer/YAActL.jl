#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

"Abstract type for messages to actors."
abstract type Message end

"""
    Dispatch

Enumeration type for dispatch modes of actors.

Depending on the `Dispatch` mode the actor composes the arguments 
to the behavior function:

- `full`: from the [`Become`](@ref) `args...` and the `msg.x...`.
    This is the default dispatch mode.
- `state`: from the actor state and the `msg.x...`. In this case the 
    actor updates its state with the result of the behavior
    function. The result is saved in a `Tuple`. 
"""
@enum Dispatch full state

"""
A `Channel{Message}` type for communicating with local actors.

!!! warn

    In actor systems we always use buffered links to avoid blocking.
    Responding on an unbuffered or full link causes an actor to block.
    `Link()` creates an unbuffered Channel, use `Link(32)` or
    [`newLink()`](@ref newLink) instead!

# Example

```julia
julia> response = Link(32)
Channel{Message}(sz_max:32,sz_curr:0)
```
"""
const Link = Channel{Message}

"""
A `RemoteChannel{Link}` type for communicating with remote actors.
"""
const RLink = RemoteChannel{Link}

"""
A `Union{Link, RLink}` type for communicating with actors. 
"""
const LINK = Union{Link, RLink}

# define promote rule
Base.promote_rule(::Type{Link}, ::Type{RLink}) = LINK
