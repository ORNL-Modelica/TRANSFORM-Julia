using Modia

HeatPort = Model( T = potential,   # Absolute temperature
                  Q_flow = flow )  # Heat flow into the component

HeatPort = HeatPort | Map(T=Var(start=273.15u"K"),Q_flow=Var(start=0.0u"W"))