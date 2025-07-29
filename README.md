# TRANSFORM-Julia

A test implementing capabilities of the TRANSFORM Modelica Library in the Julia language. This tests the Modia approach and the ModelingToolkit approach.

# Instructions for Dyad
- See [README.md in TRANSFORM](TRANSFORM/README.md) folder

# Instructions for ModelingToolk and Modia
- Clone repository
- Install [VSCode](https://code.visualstudio.com/download)
    - Once installed, go to `Extensions` and Install the official `Julia` extension.
- Install [Julia](https://julialang.org/downloads/)
    - In the Julia terminal, run:
        - `import Pkg; Pkg.add("ModelingToolkit"), Pkg.add("OrdinaryDiffEq"); Pkg.add("PhysicalConstants"); Pkg.add("Plots");Pkg.add("Measurements"); Pkg.add("Modia"); Pkg.add("ModiaResult"); Pkg.add("Unitful")`