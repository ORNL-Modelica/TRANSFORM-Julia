include("../Resistances/heat.jl")
include("../../Utilities/summary.jl")

using Plots, Measurements

# Boundary model(s)
T_a = 293.15
T_b = 313.15

@named boundaryT_a =Temperature(T=T_a)
@named boundaryT_b =Temperature(T=T_b)

@variables Q_total(t)
D = Differential(t)

# Sphere model
r_inner = measurement(1.0,0.1)
r_outer = 2.0
lambda = 5.0

@named sphere = Sphere(r_inner=r_inner,r_outer=r_outer,lambda=lambda)

eqs =
[
    connect(boundaryT_a.port,sphere.port_a)
    connect(sphere.port_b,boundaryT_b.port)
    D(Q_total) ~ sphere.port_a.Q_flow
]

@named sphere_model = ODESystem(eqs, t, [Q_total],[], systems=[boundaryT_a,boundaryT_b,sphere])

sys = structural_simplify(sphere_model)
u0 = [Q_total=>0.0]
prob = ODAEProblem(sys, u0, (0, 1.0), [T_a, T_b, r_inner, r_outer, lambda])
sol = solve(prob, Tsit5())
y_min, t_min, y_max, t_max = reportMinMax("Q_total","Sphere Model",sol)
errorCheck(-2513.2742, y_min)
plot(sol)

# Convection model
surfaceArea = 2
alpha = 15

@named convection = Convection(surfaceArea = surfaceArea, alpha=alpha)

eqs =
[
    connect(boundaryT_a.port,convection.port_a)
    connect(convection.port_b,boundaryT_b.port)
    D(Q_total) ~ convection.port_a.Q_flow
]

@named convection_model = ODESystem(eqs, t, [Q_total],[], systems=[boundaryT_a,boundaryT_b,convection])

sys = structural_simplify(convection_model)
u0 = [Q_total=>0.0]
prob = ODAEProblem(sys, u0, (0, 1.0), [T_a, T_b, surfaceArea, alpha])
sol = solve(prob, Tsit5())
y_min, t_min, y_max, t_max = reportMinMax("Q_total","Convection Model",sol)
errorCheck(-600, y_min)
plot(sol) # how to get both to plot to jupyter without overriding like plt.figure()?

# Contact model
surfaceArea = 2
Rc_pp = 5

@named contact = Contact(surfaceArea = surfaceArea, Rc_pp=Rc_pp)

eqs =
[
    connect(boundaryT_a.port,contact.port_a)
    connect(contact.port_b,boundaryT_b.port)
    D(Q_total) ~ contact.port_a.Q_flow
]

@named contact_model = ODESystem(eqs, t, [Q_total],[], systems=[boundaryT_a,boundaryT_b,contact])

sys = structural_simplify(contact_model)
u0 = [Q_total=>0.0]
prob = ODAEProblem(sys, u0, (0, 1.0), [T_a, T_b, surfaceArea, Rc_pp])
sol = solve(prob, Tsit5())
y_min, t_min, y_max, t_max = reportMinMax("Q_total","Contact Model",sol)
errorCheck(-8, y_min)
plot(sol)

# Radiation model
surfaceArea = 2.0
epsilon = 0.5

@named radiation = Radiation(surfaceArea = surfaceArea, epsilon=epsilon)

eqs =
[
    connect(boundaryT_a.port,radiation.port_a)
    connect(radiation.port_b,boundaryT_b.port)
    D(Q_total) ~ radiation.port_a.Q_flow
]

@named radiation_model = ODESystem(eqs, t, [Q_total],[], systems=[boundaryT_a,boundaryT_b,radiation])

sys = structural_simplify(radiation_model)
u0 = [Q_total=>0.0]
prob = ODAEProblem(sys, u0, (0, 1.0), [T_a, T_b, surfaceArea, epsilon])
sol = solve(prob, Tsit5())
y_min, t_min, y_max, t_max = reportMinMax("Q_total","Radiation Model",sol)
errorCheck(-126.51638, y_min)
plot(sol)