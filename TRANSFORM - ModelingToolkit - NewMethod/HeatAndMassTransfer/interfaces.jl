using ModelingToolkit, OrdinaryDiffEq

@connector HeatPort begin
    T(t) = 273.15, [unit=u"K"]
    Q_flow(t) = 0.0, [connect = Flow, unit=u"W"]
end