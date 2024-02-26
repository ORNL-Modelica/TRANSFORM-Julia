using Printf

function reportMinMax(varName::String,modelName::String,sol)
    y_min = findmin(sol.u)[1][1]
    t_min = sol.t[findmin(sol.u)[2]]
    y_max = findmax(sol.u)[1][1]
    t_max = sol.t[findmax(sol.u)[2]]
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
    @printf("%.2e\t%.2e\t%.2e\t%.2e\n\n",measured,predicted,error_abs,error_rel)
end