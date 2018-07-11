using FredData
using Test

# Normal usage - API key must be present in ENV
if haskey(ENV, "FRED_API_KEY")
    include("test_with_key.jl")
end
