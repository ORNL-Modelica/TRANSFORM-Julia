include("../Resistances/heat.jl")
include("../../Utilities/summary.jl")

using Plots, Measurements
using ModelingToolkit: t_nounits as t, D_nounits as D
using Unitful

#=
Issues:
- MTK doesn't support replaceable classes it appears yet... HUGE issue. Only parameters
- No media library
- use of Measurements/MonteCarlo for uncertainty throws errors
- IfElse doesn't work
- using constants doesn't work
=#
function runTest(model, u0, tspan, checkVariable, checkValue)
    prob = ODEProblem(model, u0, tspan)
    sol = solve(prob, Tsit5())
    y_min, t_min, y_max, t_max = reportMinMax(string(checkVariable),string(model.name),sol)
    errorCheck(checkValue, y_min)
    plot(sol, idxs = (checkVariable))
end

## Base Class
@mtkmodel PartialTest begin
    @parameters begin
        # Boundary conditions
        T_a = 293.15, [unit=u"K"]
        T_b = 313.15, [unit=u"K"]
    end
    @variables begin
        Q_total(t), [unit=u"W"]
    end
    @components begin
        boundaryT_a =Temperature(T=T_a)
        boundaryT_b =Temperature(T=T_b)
    end
end

## Sphere Test
@mtkmodel SphereTest begin
    @extend PartialTest()
    @parameters begin
        r_inner = 1.0 # measurement(1.0,0.1) # how to do this type of logic? tried various things even others examples and it doesn't work...
        r_outer = 2.0
        lambda = 5.0
    end
    @components begin
        resistance = Sphere(r_inner=r_inner, r_outer=r_outer, lambda=lambda)
    end
    @equations begin
        connect(boundaryT_a.port,resistance.port_a)
        connect(resistance.port_b,boundaryT_b.port)
        D(Q_total) ~ resistance.port_a.Q_flow
    end
end

@mtkbuild sphereTest =  SphereTest()
u0 = [sphereTest.Q_total=>0.0]
tspan = (0,1.0)
runTest(sphereTest, u0, tspan, sphereTest.Q_total, -2513.2742)

## Convection Test
@mtkmodel ConvectionTest begin
    @extend PartialTest()
    @parameters begin
        surfaceArea = 2.0
        alpha = 15.0
    end
    @components begin
        resistance = Convection(surfaceArea = surfaceArea, alpha=alpha)
    end
    @equations begin
        connect(boundaryT_a.port,resistance.port_a)
        connect(resistance.port_b,boundaryT_b.port)
        D(Q_total) ~ resistance.port_a.Q_flow
    end
end

@mtkbuild convectionTest =  ConvectionTest()
u0 = [convectionTest.Q_total=>0.0]
tspan = (0,1.0)
runTest(convectionTest, u0, tspan, convectionTest.Q_total, -600)

## Contact Test
@mtkmodel ContactTest begin
    @extend PartialTest()
    @parameters begin
        surfaceArea = 2.0
        Rc_pp = 5.0
    end
    @components begin
        resistance = Contact(surfaceArea = surfaceArea, Rc_pp=Rc_pp)
    end
    @equations begin
        connect(boundaryT_a.port,resistance.port_a)
        connect(resistance.port_b,boundaryT_b.port)
        D(Q_total) ~ resistance.port_a.Q_flow
    end
end

@mtkbuild contactTest =  ContactTest()
u0 = [contactTest.Q_total=>0.0]
tspan = (0,1.0)
runTest(contactTest, u0, tspan, contactTest.Q_total, -8)

## Radiation Test
@mtkmodel RadiationTest begin
    @extend PartialTest()
    @parameters begin
        surfaceArea = 2.0
        epsilon = 0.5
    end
    @components begin
        resistance = Radiation(surfaceArea = surfaceArea, epsilon=epsilon)
    end
    @equations begin
        connect(boundaryT_a.port,resistance.port_a)
        connect(resistance.port_b,boundaryT_b.port)
        D(Q_total) ~ resistance.port_a.Q_flow
    end
end

@mtkbuild radiationTest =  RadiationTest()
u0 = [radiationTest.Q_total=>0.0]
tspan = (0,1.0)
runTest(radiationTest, u0, tspan, radiationTest.Q_total, -126.51638)