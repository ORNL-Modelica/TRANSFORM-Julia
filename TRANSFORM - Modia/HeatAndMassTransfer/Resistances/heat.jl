include("../interfaces.jl")

import PhysicalConstants.CODATA2018 as Constants

### Boundary conditions
Temperature = Model(
    T = 293.15u"K",
    port = HeatPort,
    equations = :[port.T=T]
)

# Base Classes
PartialResistance = Model(
    port_a = HeatPort,
    port_b = HeatPort,
    partialEquations  = :[
        0 = port_a.Q_flow + port_b.Q_flow
        port_a.Q_flow = (port_a.T - port_b.T)/R
    ]
)

### Resistance Models
Sphere = PartialResistance | Model(
    r_inner = 0.1u"m",
    r_outer = 1.0u"m",
    lambda = 1.0u"W/(m*K)",
    R = Var(start=1.0u"K/W"),
    π=π,
    equations = :[
        R = 1/(4*π*lambda)*(1/r_inner - 1/r_outer)
    ]
)

Convection = PartialResistance | Model(
    surfaceArea = 0.01u"m^2",
    alpha = 1000.0u"W/(m^2*K)",
    R = Var(start=1.0u"K/W"),
    equations = :[
        R = 1/(alpha*max(eps()u"m^2",surfaceArea))
    ]
)

Contact = PartialResistance | Model(
    surfaceArea = 0.01u"m^2",
    Rc_pp = 1.0u"m^2*K/W",
    R = Var(start=1.0u"K/W"),
    equations = :[
        R = Rc_pp/max(eps()u"m^2",surfaceArea)
    ]
)

Radiation = PartialResistance | Model(
    surfaceArea = 0.01u"m^2",
    epsilon = 1.0u"m/m", # no units... don't know how to represent that
    R = Var(start=1.0u"K/W"),
    useExact=true,
    sigma=Constants.StefanBoltzmannConstant, # how to use this within a model without specifying as a parameter/variable?
    equations = :[
        R = if useExact 
                1/(surfaceArea*sigma*epsilon*(port_a.T^2+port_b.T^2)*(port_a.T + port_b.T))
            else
                1/(4*surfaceArea*sigma*epsilon*(0.5*(port_a.T + port_b.T))^3) 
            end
    ]
)