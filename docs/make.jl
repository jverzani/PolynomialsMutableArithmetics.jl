using PolynomialsMutableArithmetics
using Documenter

DocMeta.setdocmeta!(PolynomialsMutableArithmetics, :DocTestSetup, :(using PolynomialsMutableArithmetics); recursive=true)

makedocs(;
    modules=[PolynomialsMutableArithmetics],
    authors="jverzani <jverzani@gmail.com> and contributors",
    repo="https://github.com/jverzani/PolynomialsMutableArithmetics.jl/blob/{commit}{path}#{line}",
    sitename="PolynomialsMutableArithmetics.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://jverzani.github.io/PolynomialsMutableArithmetics.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jverzani/PolynomialsMutableArithmetics.jl",
    devbranch="main",
)
