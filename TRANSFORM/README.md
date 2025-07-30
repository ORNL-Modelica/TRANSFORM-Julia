# TRANSFORM
  
Testing the migration of TRANSFORM to Julia using the Dyad Julia language extension.

## Getting Started
  
This library was created with the Dyad Studio VS Code extension.  Your Dyad
models should be placed in the `dyad` directory and the files should be
given the `.dyad` extension.  Several such files have already been placed
in there to get you started.  The Dyad compiler will compile the Dyad models
into Julia code and place it in the `generated` folder.  Do not edit the
files in that directory or remove/rename that directory.

A complete tutorial on using Dyad Studio can be found [here](#).  But you
can run the provided example models by doing the following:

1. Run `Julia: Start REPL` from the command palette.

2. Type `]`.  This will take you to the package manager prompt.

3. At the `pkg>` prompt, type `instantiate` (this downloads all the Julia libraries
   you will need, and the very first time you do it it might take a while).

4. From the same `pkg>` prompt, type `test`.  This will test to make sure the models
   are working as expected.  It may also take some time but you should eventually
   see a result that indicates 2 of 2 tests passed.

5. Use the `Backspace`/`Delete` key to return to the normal Julia REPL, it should
   look like this: `julia>`.

6. Type `using TRANSFORM`.  This will load your model library.

7. Type `Sim*()` to run a simulation where `*` is an available test.  The first time you run it,
   this might take a few seconds, but each successive time you run it, it should be very fast.

8. To see simulation results type `using Plots` (and answer `y` if asked if you want
   to add it as a dependency).

9. To plot results of the `Sim*` simulation, simply type `plot(Sim*())`.

10. You can plot variations on that simulation using keyword arguments.  For example,
    try `plot(Sim*(VALUE=4))` where VALUE is exposed parameters if any are available.



# Julia CON
- Everything should be `variable`. `parameter`, etc. should be special cases
   - Prevents switching from a parameter from a static value to a variable value. Requires new model. Dymola does this much better (not MSL).
- `variable` should have information baked in that can be referenced without defining additional parameters.
   - e.g., they should have a `start` value that can be defined elsewhere without have to define an addition parameter
   - note, below is a quick description that may not make sense to others. feel free to ask me to clarify
      ```
      component TEST
      parameter a_start::Real = 1 # why!??!
      variable a::Real
      # variable
      relations
      initial a = a_start # unclear if this is fixed or a guess? how to distinguish between guess/fixed. this should be fixed if used here
      initial a.start = 10 # or don't define here and allow to define in another model
      end

      component COOL
      #below are options/ideas and not saying to be used all together
      model = TEST(a.start=10)
      initial model.a.start = 10 #guess
      relation
      initial model.a.start = 10 #fixed
      end
      ```

# Currently identified issues with Dyad (not in order)
- Previously limiations to number of `extends`. Not tested yet if still an issue.
- Can you reference parameters within models without adding new ones every layer up? 
   - should be able to dive into a model to modify
- Subfolders not supported in Dyad for now
   - Cannot properly structure libraries
- `generated` folder is included in git to allow someone to use without regenerating.
   - Though it has merits I tend to think this isn't the best approach
- No `generated` folder if any errors occur
- No `generated` folder if the top-level folder is not the "open" folder in VSCode
- Is it possible to have multiple Dyad projects/libraries open in a single VSCode session (i.e., both being developed together)?
   - Initial tests in would not recognize the library
- `Ctrl+Click` navigation not available (hopefully coming)
- Unit types conflict with component names
   - e.g., if `component Temperature` exists then `parameter k::Temperature` will throw an error even though they are different types and in different locations
   - Related, cannot have any components with the same name in the same Dyad project as there is no support for subfolders
- Ability to map connector names automatically without needing to add an adapter
   - This would be an interesting additional feature to make it easier to adopt different naming conventions in connectors and then instruct the compiler to map
- Variable flows should follow the `*_flow` convention (e.g., `m` is mass, `m_flow` is flow) – use Modelica syntax
- Everything should be an input; parameters are special cases!!!!!!!!!!!!!!!!!!!!!!!!!! 
   - I will never stop saying that this is THE WAY. Dymola is the closest to having done this right. Huge issue IMO.
- Commenting
   - Commenting out code turns it into documentation if it is before a line of code... this isn't good
   - Commenting before `relations` causes errors – very weird. I think this occurred before `end` too.
- Update [tutorial](https://help.juliahub.com/dyad/dev/tutorials/getting-started.html)
   - To step through what each command does and the intended use of each library folder (assume the user is new to Julia) or links to that info
   - Improve readability by extracting out user actions from text. Easy to miss some steps.
   - Broken links in the tutorial (e.g., *TransientAnalysis* documentation link)
- Restarting the REPL has to happen ALOT to find new files, sometimes pickup changes.
- Constants
   - Are there a globally defined set of constants for the community? How to use if so (e.g., `pi`, Boltzmann constant, etc.)?
- `if/else` statements (`ifelse`) - think this worked...
   - Is there if/elseif/../else?
- Can you put more than 2 things in `connect(a,b,c)`?
- How to get values from simulation results that are not state variables?
   - e.g., had simulations with no state variables (pure steady state) and couldn't plot anything
- Replaceable models supported?
- Having to add an `analysis` to do simple simulations seems burdensome.
   - Have to expose more parameters again
   - Possible to embed dynamic simulations, like the metadata, that can be run like a normal model.
   - or some other method to remove having "unnecessary" redundancy
- VSCode
   - See variable values in Explorer (like other languages)
   - See open file components/functions for navigation (like other languages)
- What does the `test` prefix do before a component?
- What are the protected names? (e.g., apparently `eps` is protected?)
- What is the correct way to run multiple examples or unit tests at once?  
  - Currently, putting them all in a `.jl` file (e.g., `plot(SimTest*())`) and running with  
    `include("test/runUnitTests.jl")` throws weird errors that don't make sense (tests pass individually but fail together, e.g., throw `eps_` error even though it doesn’t exist in that component)
- Had to close and reopen VSCode to get rid of deleted Dyad files in the `generated` folder
- ~~Still get random erros saying `eps_` isn't defined even though it OF COURSE IT ISN'T... Very strange. Phantom errors that can't be fixed.~~
   - **FIXED**: The error was in partial resistances. Error messages could be improved to help locate the issue better perhaps.
- ~~plot(part_ab_ThermalResistances()) throws a non-sensical (from my perspective) error~~
   - plot(part_ab_ThermalResistances())
ERROR: UndefKeywordError: keyword argument `name` not assigned
Stacktrace:
 [1] Part_ab_ThermalResistances()
   @ TRANSFORM C:\Users\fig\.julia\packages\ModelingToolkit\Z9mEq\src\systems\abstractsystem.jl:2463
 [2] top-level scope
   @ REPL[3]:1
   - **FIXED:** Meant to call SimPart_ab_ThermalResistances instead of Part_ab_ThermalResistances
- plot(SimPart_ab_ThermalResistances()) gives the error below. Assuming no other issues, this model solves easily in Dymola (see [TRANSFORM example](https://github.com/ORNL-Modelica/TRANSFORM-Library/blob/master/TRANSFORM/HeatAndMassTransfer/Examples/ExamplesFrom_NellisAndKlein/Example_1_2_1_LiquidOxygenDewar/part_ab_ThermalResistances.mo)). Not sure how to address this.
   ```
   ERROR: Cyclic guesses detected in the system. Symbolic values were found for the following variables/parameters in the map:
   insulation₊port_a₊T(t)  => contact_1₊port_b₊T(t)
   insulation₊port_b₊T(t)  => contact_2₊port_a₊T(t)
   linerOuter₊port_a₊T(t)  => contact_2₊port_b₊T(t)
   convectionInner₊port_b₊T(t)  => linerInner₊port_a₊T(t)
   contact_1₊port_a₊T(t)  => linerInner₊port_b₊T(t)
   radiationOuter₊port_a₊T(t)  => convectionOuter₊port_a₊T(t)
   ```