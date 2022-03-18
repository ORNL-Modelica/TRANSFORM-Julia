using Printf, ModiaPlot

# the sol is different for modia than ModelingToolkit
function reportMinMax(varName::String,modelName::String,sol)

    time = ModiaPlot.getSignal(sol,"time")[1]
    val = ModiaPlot.getSignal(sol,varName)[1]

    y_min = findmin(val)[1][1]
    t_min = time[findmin(val)[2]]
    y_max = findmax(val)[1][1]
    t_max = time[findmax(val)[2]]
    print("$(varName): $(modelName)\n")
    print("var\ttime\tvalue\n")
    print("min\t$(t_min)\t$(y_min)\n")
    print("max\t$(t_max)\t$(y_max)\n\n")
    return y_min, t_min, y_max, t_max
end

function errorCheck(measured, predicted)
    error_abs = measured-predicted
    error_rel = (measured-predicted)/measured

    println("Measured\tPredicted\tM-P\t\t(M-P)/M")
    @printf("%.2e\t%.2e\t%.2e\t%.2e\n\n",ustrip(measured),ustrip(predicted),ustrip(error_abs),ustrip(error_rel))
end