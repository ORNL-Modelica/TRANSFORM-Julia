include("../Resistances/heat.jl")
include("../../Utilities/summary.jl")

using Measurements, Modia
#ENV["MODIA_PLOT"] = "PyPlot"
Modia.usePlotPackage("PyPlot")
@usingModiaPlot

# Boundary model(s)
T_a = 293.15u"K"
T_b = 313.15u"K"

r_inner = measurement(1.0,0.1)u"m"
r_outer = 2.0u"m"
lambda = 5.0u"W/(m*K)"

# Base Classes
PartialTest = Model(
    Q_total=Var(init=0.0u"J"),
    partialEquations =:[
        der(Q_total) = Qb_flow
    ]
)

# Sphere Model
sphere_model = PartialTest | Model(
    boundaryT_a = Temperature | Map(T=T_a),
    boundaryT_b = Temperature | Map(T=T_b),
    resistor = Sphere | Map(r_inner=r_inner,r_outer=r_outer,lambda=lambda),
    equations =:[
        Qb_flow = resistor.port_a.Q_flow
    ],
    connect =:[
        (boundaryT_a.port,resistor.port_a)
        (resistor.port_b,boundaryT_b.port)
    ]
)

result = @instantiateModel(sphere_model, log=false,FloatType=Measurement{Float64})
@time simulate!(result, stopTime=1.0, tolerance=1e-4, log=false)
y_min, t_min, y_max, t_max = reportMinMax("Q_total","Sphere Model",result)
errorCheck(-2513.2742u"J"±0.0u"J", y_min)
plot(result, ["Q_total"], figure=1)

# Convection model
surfaceArea = 2u"m^2"
alpha = 15u"W/(m^2*K)"

convection_model = PartialTest | Model(
    boundaryT_a = Temperature | Map(T=T_a),
    boundaryT_b = Temperature | Map(T=T_b),
    resistor = Convection | Map(surfaceArea = surfaceArea, alpha=alpha),
    equations =:[
        Qb_flow = resistor.port_a.Q_flow
    ],
    connect =:[
        (boundaryT_a.port,resistor.port_a)
        (resistor.port_b,boundaryT_b.port)
    ]
)

result = @instantiateModel(convection_model, log=false,FloatType=Measurement{Float64})
@time simulate!(result, stopTime=1.0, tolerance=1e-4, log=false)
y_min, t_min, y_max, t_max = reportMinMax("Q_total","Convection Model",result)
errorCheck(-600u"J"±0.0u"J", y_min)
plot(result, ["Q_total"], figure=1)

# Contact model
surfaceArea = 2u"m^2" # units hid until constant unit issue solved
Rc_pp = 5u"m^2*K/W"

contact_model = PartialTest | Model(
    boundaryT_a = Temperature | Map(T=T_a),
    boundaryT_b = Temperature | Map(T=T_b),
    resistor = Contact | Map(surfaceArea = surfaceArea, Rc_pp=Rc_pp),
    equations =:[
        Qb_flow = resistor.port_a.Q_flow
    ],
    connect =:[
        (boundaryT_a.port,resistor.port_a)
        (resistor.port_b,boundaryT_b.port)
    ]
)

result = @instantiateModel(contact_model, log=false,FloatType=Measurement{Float64})
@time simulate!(result, stopTime=1.0, tolerance=1e-4, log=false)
y_min, t_min, y_max, t_max = reportMinMax("Q_total","Contact Model",result)
errorCheck(-8u"J"±0.0u"J", y_min)
plot(result, ["Q_total"], figure=1)

# Radiation exact model
surfaceArea = 2u"m^2"
epsilon = 0.5u"m/m"

radiationExact_model = PartialTest | Model(
    boundaryT_a = Temperature | Map(T=T_a),
    boundaryT_b = Temperature | Map(T=T_b),
    resistor = Radiation | Map(surfaceArea = surfaceArea, epsilon=epsilon),
    equations =:[
        Qb_flow = resistor.port_a.Q_flow
    ],
    connect =:[
        (boundaryT_a.port,resistor.port_a)
        (resistor.port_b,boundaryT_b.port)
    ]
)

result = @instantiateModel(radiationExact_model, log=false,FloatType=Measurement{Float64})
@time simulate!(result, stopTime=1.0, tolerance=1e-4, log=false)
y_min, t_min, y_max, t_max = reportMinMax("Q_total","Radiation Exact Model",result)
errorCheck(-126.51638u"J"±0.0u"J", y_min)
plot(result, ["Q_total"], figure=1)

# Radiation approximate model
radiationApproximate_model = PartialTest | Model(
    boundaryT_a = Temperature | Map(T=T_a),
    boundaryT_b = Temperature | Map(T=T_b),
    resistor = Radiation | Map(surfaceArea = surfaceArea, epsilon=epsilon, useExact=false),
    equations =:[
        Qb_flow = resistor.port_a.Q_flow
    ],
    connect =:[
        (boundaryT_a.port,resistor.port_a)
        (resistor.port_b,boundaryT_b.port)
    ]
)

result = @instantiateModel(radiationApproximate_model, log=false,FloatType=Measurement{Float64})
@time simulate!(result, stopTime=1.0, tolerance=1e-4, log=false)
y_min, t_min, y_max, t_max = reportMinMax("Q_total","Radiation Approximate Model",result)
errorCheck(-126.51638u"J"±0.0u"J", y_min)
plot(result, ["Q_total"], figure=1)