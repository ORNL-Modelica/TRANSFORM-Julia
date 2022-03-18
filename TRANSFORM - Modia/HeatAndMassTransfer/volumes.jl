# Base Classes
@enum(Dynamics, dynamicFreeInitial, fixedInitial, steadyStateInitial, steadyState) # this works but it can't find it in the the "Model"

# Volumes
UnitVolume = Model(
    nParallel=1,
    V=1.0u"m^3",
    d=1000.0u"kg/m^3",
    cp=1.0u"J/(kg*K)",
    Q_gen=0.0u"W",
    T_reference  = 273.15u"K",
    U=Var(start=6000.0u"J"),
    port = HeatPort,
    equations = :[
        m = d*V
        U = m*cp*(T-T_reference)
        Qb_flow = port.Q_flow / nParallel + Q_gen
        der(U) = Qb_flow
        port.T = T
    ]
)