#=
Example driver script for running the rural-abm model
=#

# Load RuralABM
include("src/RuralABM.jl")
using Pkg, .RuralABM
using CSV
Pkg.activate(".")

# Initialize town with household, work, and school assignments
model_init, townDataSummaryDF, businessStructureDF, houseStructureDF = Construct_Town("data/example_towns/small_town/population.csv", "data/example_towns/small_town/businesses.csv")

# Run the model without any contagion to converge the social network
length_to_run_in_days = 15
Run_Model!(model_init; duration = length_to_run_in_days)

# Apply vaccination and masking behaviors to certain age ranges
portion_will_mask = 0.0
portion_vaxed = 0.0
mask_id_arr = Get_Portion_Random(model_init, portion_will_mask, [(x)->x.age >= 2])
vaccinated_id_arr = Get_Portion_Random(model_init, portion_vaxed, [(x)-> x.age > 4], [1.0])

Update_Agents_Attribute!(model_init, mask_id_arr, :will_mask, [true, true, true])
Update_Agents_Attribute!(model_init, vaccinated_id_arr, :status, :V)
Update_Agents_Attribute!(model_init, vaccinated_id_arr, :vaccinated, true)

# Run the model with contagion until the count of infected agents is zero
Seed_Contagion!(model_init) # set seed_num = x for x seedings. Default = 1.
model_result, agent_data, transmission_network, social_contact_matrix, epidemic_summary = Run_Model!(model) # the social_contact_matrix returned is only the upper half. To reconstruct entire matrix use decompact_adjacency_matrix(filename)

# Extract Adjacency Matrix
#using DataFrames, CSV
#arr = RuralABM.get_adjacency_matrix(model)
#df = DataFrame([eachcol(arr)...], :auto, copycols=false)
#CSV.write("SCM.csv", df, header = false)
