include("../interfaces.jl")

import PhysicalConstants.CODATA2018 as Constants # this must be moved at a high level in the package to standardize use

### Boundary conditions
function Temperature(;name,T=273.15)
    val = T
    @parameters T # how to give default parameters. how to give default to variables

    @named port = HeatPort()

    eqs = 
    [
        port.T ~ T
    ]
    ODESystem(eqs, t, [], [T], systems=[port], name=name)
end

### Resistance Models
# how to have the similar effect as extend PartialResistance to avoid code rewrite
function Sphere(;name, r_inner = 0.01, r_outer=1.0, lambda=5.0)
    val0 = r_inner # don't understand why there "val*" are required for parameters with default values
    val1 = r_outer
    val2 = lambda
    @variables R(t)
    @parameters r_inner, r_outer, lambda

    @named port_a = HeatPort()
    @named port_b = HeatPort()

    eqs =
    [
        0 ~ port_a.Q_flow + port_b.Q_flow
        port_a.Q_flow ~ (port_a.T - port_b.T)/R
        R ~ 1/(4*3.14159*lambda)*(1/r_inner - 1/r_outer)
    ]
    ODESystem(eqs, t, [R], [r_inner, r_outer, lambda], systems=[port_a, port_b], name=name)
end

function Convection(;name, surfaceArea = 0.01, alpha=1000.0)
    val0 = surfaceArea
    val1 = alpha
    @variables R(t)
    @parameters surfaceArea, alpha

    @named port_a = HeatPort()
    @named port_b = HeatPort()

    eqs =
    [
        0 ~ port_a.Q_flow + port_b.Q_flow
        port_a.Q_flow ~ (port_a.T - port_b.T)/R
        R ~ 1/(alpha*max(eps(),surfaceArea))
    ]
    ODESystem(eqs, t, [R], [surfaceArea, alpha], systems=[port_a, port_b], name=name)
end

function Contact(;name, surfaceArea = 0.01, Rc_pp=1.0)
    val0 = surfaceArea
    val1 = Rc_pp
    @variables R(t)
    @parameters surfaceArea, Rc_pp

    @named port_a = HeatPort()
    @named port_b = HeatPort()

    eqs =
    [
        0 ~ port_a.Q_flow + port_b.Q_flow
        port_a.Q_flow ~ (port_a.T - port_b.T)/R
        R ~ Rc_pp/max(eps(),surfaceArea)
    ]
    ODESystem(eqs, t, [R], [surfaceArea, Rc_pp], systems=[port_a, port_b], name=name)
end

function Radiation(;name, surfaceArea = 0.01, epsilon=1.0)
    val0 = surfaceArea
    val1 = epsilon
    @variables R(t)
    @parameters surfaceArea, epsilon

    @named port_a = HeatPort()
    @named port_b = HeatPort()

    eqs =
    [
        0 ~ port_a.Q_flow + port_b.Q_flow
        port_a.Q_flow ~ (port_a.T - port_b.T)/R
        R ~ 1/(surfaceArea*5.6703744E-8*epsilon*(port_a.T^2+port_b.T^2)*(port_a.T + port_b.T))
    ]
 # exact: R ~ 1/(surfaceArea*5.6703744E-8*epsilon*(port_a.T^2+port_b.T^2)*(port_a.T + port_b.T))
 # approximate: R ~ 1/(4*surfaceArea*5.6703744E-8*epsilon*(0.5*(port_a.T + port_b.T))^3)
    # seems to be having issues :(

    # using "Constants.StefanBoltzmannConstant" causes Unitful error
    ODESystem(eqs, t, [R], [surfaceArea, epsilon], systems=[port_a, port_b], name=name)
end
