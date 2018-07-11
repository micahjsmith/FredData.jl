using FredData
using Test

include("test_without_key.jl")

# Normal usage - API key must be present in ENV
if haskey(ENV, "FRED_API_KEY")
    include("test_with_key.jl")
end
