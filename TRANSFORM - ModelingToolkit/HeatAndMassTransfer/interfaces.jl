using ModelingToolkit, OrdinaryDiffEq

@parameters t
@connector function HeatPort(;name)
    @variables Q_flow(t) T(t)
    ODESystem(Equation[], t, [Q_flow, T], [], name=name, defaults=[Q_flow=>0.0, T=>273.15]) # how to we update these guess values in the future/require them to be updated
end

# add in additional heat ports for flow and state - can there be some auto reminder of what to connect?

function ModelingToolkit.connect(::Type{HeatPort}, ports...)
    eqs = 
    [
        0 ~ sum(port->port.Q_flow, ports)
    ]

    for i in 1:length(ports)-1
        push!(eqs, ports[i].T ~ ports[i+1].T)
    end
    
    return eqs
end