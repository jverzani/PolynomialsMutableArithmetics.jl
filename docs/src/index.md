[PolynomialsMutableArithmetics.jl](https://github.com/jverzani/PolynomialsMutableArithmetics.jl)
is a Julia package that registers the `Polynomial` type from the
`Polynomials` package with the
[MutableArithmetics](https://github.com/jump-dev/MutableArithmetics.jl)
package. This allows some operations with polynomials to allocate
significantly less.

For example, with

```julia
using Polynomials
d, m, n = 30, 20, 20
p(d) = Polynomial(big.(1:d))
A = [p(d) for i in 1:m, j in 1:n]
b = [p(d) for i in 1:n]
```

The multiplication `A*b` allocates about 40 MiB due to 2 M
allocations, as it does not exploit any mutability.

Whereas,

```julia
using PolynomialsMutableArithmetics
import MutableArithmetics
MutableArithmetics.operate(*, A, b)
```

allocates about 70 KiB due to 4k allocations.



```@meta
CurrentModule = PolynomialsMutableArithmetics
```

# PolynomialsMutableArithmetics

Documentation for [PolynomialsMutableArithmetics](https://github.com/jverzani/PolynomialsMutableArithmetics.jl).

```@index
```

```@autodocs
Modules = [PolynomialsMutableArithmetics]
```
