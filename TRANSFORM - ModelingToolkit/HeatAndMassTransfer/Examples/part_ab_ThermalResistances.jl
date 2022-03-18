include("../Resistances/heat.jl")

using Plots, Measurements

# Boundary model(s)
T_a = 95.6
T_b = 273.15

@named boundaryT_a =Temperature(T=T_a)
@named boundaryT_b =Temperature(T=T_b)

@variables Q_total(t)
D = Differential(t)

# Sphere model
r_inner = 0.1
th_1 = 0.0025
th_ins = 0.01
th_2 = 0.0025

r_ins_inner = r_inner + th_1
r_ins_outer = r_ins_inner + th_ins
r_outer = r_ins_outer + th_2

@named convectionInner = Convection(surfaceArea=4*3.14159*r_inner^2,alpha=150)
@named linerInner = Sphere(r_inner=r_inner,r_outer=r_ins_inner,lambda=15)
@named contact_1 = Contact(surfaceArea=4*3.14159*r_ins_inner^2,Rc_pp=0.003)
@named insulation = Sphere(r_inner=r_ins_inner,r_outer=r_ins_outer,lambda=0.033)
@named contact_2 = Contact(surfaceArea=4*3.14159*r_ins_outer^2,Rc_pp=0.003)
@named linerOuter = Sphere(r_inner=r_ins_outer,r_outer=r_outer,lambda=15)
@named radiationOuter = Radiation(surfaceArea=4*3.14159*r_outer^2,epsilon=0.7)
@named convectionOuter = Convection(surfaceArea=4*3.14159*r_outer^2,alpha=6.0)

eqs =
[
    connect(convectionInner.port_a,boundaryT_a.port)
    connect(convectionInner.port_b,linerInner.port_a)
    connect(linerInner.port_b,contact_1.port_a)
    connect(contact_1.port_b,insulation.port_a)
    connect(insulation.port_b,contact_2.port_a)
    connect(contact_2.port_b,linerOuter.port_a)
    connect(linerOuter.port_b,radiationOuter.port_a,convectionOuter.port_a)
    connect(convectionOuter.port_b, radiationOuter.port_b,boundaryT_b.port)
    D(Q_total) ~ convectionInner.port_a.Q_flow
]

@named model = ODESystem(eqs, t, [Q_total],[], systems=[boundaryT_a,boundaryT_b,convectionInner,linerInner,contact_1,insulation,contact_2,linerOuter,radiationOuter,convectionOuter])

sys = structural_simplify(model)
u0 = [Q_total=>0.0]
prob = ODAEProblem(sys, u0, (0, 1.0), [T_a, T_b, r_inner, th_1, r_ins_inner, th_ins, r_ins_outer, th_2, r_outer])
sol = solve(prob, Tsit5())
y_min, t_min, y_max, t_max = reportMinMax("Q_total","Thermal Resistances Model",sol)
errorCheck(-69.43455, y_min)
plot(sol)