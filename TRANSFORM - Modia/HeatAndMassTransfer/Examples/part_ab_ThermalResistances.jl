include("../Resistances/heat.jl")
include("../../Utilities/summary.jl")

using Measurements, ModiaPlot

# Boundary model(s)
T_a = 95.6u"K"
T_b = 273.15u"K"

# Parameters
r_inner = 0.1u"m"#measurement(0.1,0.01)u"m"
th_1 = 0.0025u"m"
th_ins = 0.01u"m"
th_2 = 0.0025u"m"

r_ins_inner = r_inner + th_1
r_ins_outer = r_ins_inner + th_ins
r_outer = r_ins_outer + th_2

model = Model(
    boundaryT_a = Temperature | Map(T=T_a),
    boundaryT_b = Temperature | Map(T=T_b),
    convectionInner = Convection | Map(surfaceArea=4*π*r_inner^2,alpha=150u"W/(m^2*K)"),
    linerInner = Sphere | Map(r_inner=r_inner,r_outer=r_ins_inner,lambda=15u"W/(m*K)"),
    contact_1 = Contact | Map(surfaceArea=4*π*r_ins_inner^2,Rc_pp=0.003u"m^2*K/W"),
    insulation = Sphere | Map(r_inner=r_ins_inner,r_outer=r_ins_outer,lambda=0.033u"W/(m*K)"),
    contact_2 = Contact | Map(surfaceArea=4*π*r_ins_outer^2,Rc_pp=0.003u"m^2*K/W"),
    linerOuter = Sphere | Map(r_inner=r_ins_outer,r_outer=r_outer,lambda=15u"W/(m*K)"),
    radiationOuter = Radiation | Map(surfaceArea=4*π*r_outer^2,epsilon=0.7u"m/m"), #nondim units?
    convectionOuter = Convection | Map(surfaceArea=4*π*r_outer^2,alpha=6.0u"W/(m^2*K)"),
    Q_total=Var(init=0.0u"J"),
    equations =:[
        der(Q_total) = convectionInner.port_a.Q_flow
    ],
    connect =:[
        (convectionInner.port_a,boundaryT_a.port)
        (convectionInner.port_b,linerInner.port_a)
        (linerInner.port_b,contact_1.port_a)
        (contact_1.port_b,insulation.port_a)
        (insulation.port_b,contact_2.port_a)
        (contact_2.port_b,linerOuter.port_a)
        (linerOuter.port_b,radiationOuter.port_a,convectionOuter.port_a)
        (convectionOuter.port_b,radiationOuter.port_b,boundaryT_b.port)
    ]
)

sol = @instantiateModel(model, log=false,FloatType=Measurement{Float64})
@time simulate!(sol, stopTime=1.0, tolerance=1e-4, log=false)
y_min, t_min, y_max, t_max = reportMinMax("Q_total","Thermal Resistances Model",sol)
errorCheck(-69.43455u"J"±0.0u"J", y_min)
plot(sol, ["Q_total"], figure=1)