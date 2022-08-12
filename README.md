# PolynomialsMutableArithmetics

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jverzani.github.io/PolynomialsMutableArithmetics.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jverzani.github.io/PolynomialsMutableArithmetics.jl/dev/)
[![Build Status](https://github.com/jverzani/PolynomialsMutableArithmetics.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jverzani/PolynomialsMutableArithmetics.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jverzani/PolynomialsMutableArithmetics.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jverzani/PolynomialsMutableArithmetics.jl)


Add support for `MutableArithmetics` to `Polynomials`.

Based on work by `@blegat` in PR [#331](https://github.com/JuliaMath/Polynomials.jl/pull/331).

----

While polynomials of type `Polynomial` are mutable objects, operations such as
`+`, `-`, `*`, always create new polynomials without modifying its arguments.
The time needed for these allocations and copies of the polynomial coefficients
may be noticeable in some use cases. This is amplified when the coefficients
are for instance `BigInt` or `BigFloat` which are mutable themself.
This can be avoided by modifying existing polynomials to contain the result
of the operation using the [MutableArithmetics (MA) API](https://github.com/jump-dev/MutableArithmetics.jl).

Consider for instance the following arrays of polynomials
```julia
using Polynomials
d, m, n = 30, 20, 20
p(d) = Polynomial(big.(1:d))
A = [p(d) for i in 1:m, j in 1:n]
b = [p(d) for i in 1:n]
```

In this case, the arrays are mutable objects for which the elements are mutable
polynomials which have mutable coefficients (`BigInt`s).
These three nested levels of mutable objects communicate with the MA
API in order to reduce allocation.
Calling `A * b` requires approximately 40 MiB due to 2 M allocations
as it does not exploit any mutability. Using

```julia
using PolynomialsMutableArithmetics
```

To register `Polynomials` with `MutableArithmetics`, then

```julia
using MutableArithmetics
const MA = MutableArithmetics
MA.operate(*, A, b)
```

exploits the mutability and hence only allocates approximately 70 KiB due to 4 k
allocations. If the resulting vector is already allocated, e.g.,

```julia
z(d) = Polynomial([zero(BigInt) for i in 1:d])
c = [z(2d - 1) for i in 1:m]
```

then we can exploit its mutability with

```julia
MA.operate!(MA.add_mul, c, A, b)
```

to reduce the allocation down to 48 bytes due to 3 allocations. These remaining
allocations are due to the `BigInt` buffer used to store the result of
intermediate multiplications. This buffer can be preallocated with

```julia
buffer = MA.buffer_for(MA.add_mul, typeof(c), typeof(A), typeof(b))
MA.buffered_operate!(buffer, MA.add_mul, c, A, b)
```

then the second line is allocation-free.

The `MA.@rewrite` macro rewrite an expression into an equivalent code that
exploit the mutability of the intermediate results.
For instance
```julia
MA.@rewrite(A1 * b1 + A2 * b2)
```
is rewritten into
```julia
c = MA.operate!(MA.add_mul, MA.Zero(), A1, b1)
MA.operate!(MA.add_mul, c, A2, b2)
```
which is equivalent to
```julia
c = MA.operate(*, A1, b1)
MA.mutable_operate!(MA.add_mul, c, A2, b2)
```

*Note that currently, only the `Polynomial` type implements the API and it only
implements part of it.*
