include("../interfaces.jl")

import PhysicalConstants.CODATA2018 as Constants # this must be moved at a high level in the package to standardize use
#using IfElse
### Boundary conditions
@mtkmodel Temperature begin
    @parameters begin
        T = 273.15, [unit=u"K", description = "Temperature"]
    end
    @components begin
        port = HeatPort()
    end
    @equations begin
        port.T ~ T
    end
end

@mtkmodel HeatFlow begin
    @parameters begin
        Q_flow = 0, [unit=u"W", description = "Heat flow rate"]
    end
    @components begin
        port = HeatPort()
    end
    @equations begin
        port.Q_flow + Q_flow ~ 0.0
    end
end

### Base Classes
@mtkmodel PartialResistance begin
    @variables begin
        R(t), [unit=u"K/W"]
    end
    @components begin
        port_a = HeatPort()
        port_b = HeatPort()  
    end
    @equations begin
        0 ~ port_a.Q_flow + port_b.Q_flow
        port_a.Q_flow ~ (port_a.T - port_b.T)/R
    end
end

### Resistance Models
@mtkmodel Sphere begin
    @extend PartialResistance()
    @parameters begin    
        r_inner = 0.01, [unit=u"m"]
        r_outer = 1.0, [unit=u"m"]
        lambda = 5.0, [unit=u"W/(m*K)"]
    end
    @equations begin
        R ~ 1/(4*3.14159*lambda)*(1/r_inner - 1/r_outer)
    end
end

@mtkmodel Convection begin
    @extend PartialResistance()
    @parameters begin    
        surfaceArea = 0.01, [unit=u"m^2"]
        alpha = 1000.0, [unit=u"W/(m^2*K)"]
        eps = 1e-15,  [unit=u"m^2"] # should be eps()
    end
    @equations begin
        R ~ 1/(alpha*max(eps,surfaceArea))
    end
end

@mtkmodel Contact begin
    @extend PartialResistance()
    @parameters begin    
        surfaceArea = 0.01, [unit=u"m^2"]
        Rc_pp = 1.0, [unit=u"m^2*K/W"]
        eps = 1e-15,  [unit=u"m^2"] # should be eps()
    end
    @equations begin
        R ~ Rc_pp/max(eps,surfaceArea)
    end
end

@mtkmodel Radiation begin
    @extend PartialResistance()
    @parameters begin    
        surfaceArea = 0.01, [unit=u"m^2"]
        epsilon = 1.0, [unit=u"m/m"]
        useExact=true
        sigma = 5.6703744E-8, [unit=u"W/(m^2*K^4)"] # should be Constants.StefanBoltzmannConstant
    end
    @equations begin
        R ~ 1/(surfaceArea*sigma*epsilon*(port_a.T^2+port_b.T^2)*(port_a.T + port_b.T))
        #R ~ IfElse.ifelse(useExact,
        #            1/(surfaceArea*sigma*epsilon*(port_a.T^2+port_b.T^2)*(port_a.T + port_b.T)),
        #            1/(4*surfaceArea*sigma*epsilon*(0.5*(port_a.T + port_b.T))^3))
        # IfElse doesn't seem to be working...
    end
end