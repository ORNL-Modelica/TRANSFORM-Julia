using Printf
import ModiaResult

# the sol is different for modia than ModelingToolkit
function reportMinMax(name::String,modelName::String,result)

    (time, signal, signalType) = ModiaResult.rawSignal(result, name)

    y_min, i_min = findmin(signal[1])
    y_max, i_max = findmax(signal[1])
    t_min = time[1][i_min]
    t_max = time[1][i_max]
    print("$(name): $(modelName)\n")
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