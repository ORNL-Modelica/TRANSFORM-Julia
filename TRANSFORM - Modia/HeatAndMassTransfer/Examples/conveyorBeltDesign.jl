include("../Resistances/heat.jl")
include("../volumes.jl")
include("../../Utilities/summary.jl")

using Measurements, ModiaPlot

T_boundary = (20+273.15)u"K"
diameter = 0.1u"m"
th = 0.002u"m"
alpha = 15.0u"W/(m^2*K)"

surfaceArea = π*0.25*diameter^2

model = Model(
    boundary = Temperature | Map(T=T_boundary),
    resistor = Convection | Map(surfaceArea = surfaceArea, alpha=alpha),
    plasticDisk = UnitVolume | Map(V=surfaceArea*th, d = 1100.0u"kg/m^3", cp=1900.0u"J/(kg*K)"),
    connect =:[
        (boundary.port,resistor.port_b)
        (resistor.port_a,plasticDisk.port)
    ]
)

sol = @instantiateModel(model, log=false)#,FloatType=Measurement{Float64})
@time simulate!(sol, stopTime=500.0, tolerance=1e-4, log=false)
y_min, t_min, y_max, t_max = reportMinMax("plasticDisk.T","",sol)
errorCheck(319.72586u"K"±0.0u"K", y_min)
plot(sol, ["plasticDisk.T"], figure=1)