module FredData

using Requests
using DataFrames
import Requests: get
import JSON

export Fred, get_data

const MAX_ATTEMPTS = 3
const FIRST_REALTIME = Date(1776,07,04)
const LAST_REALTIME  = Date(9999,12,31)
const DEFAULT_API_URL = "http://api.stlouisfed.org/fred/"
const API_KEY_LENGTH  = 32

# Fred connection type
"""
A connection to the Fred API.

Constructors
------------
Fred()                                          # Default connection
Fred(key::ASCIIString; url::ASCIIString)  # Custom connection

Arguments
---------
*`url`: Base url to the Fred API.
*`key`: Registration key provided by the Fred.

Notes
-----
A valid registration key increases the allowable number of requests per day as well making
catalog metadata available.
"""
type Fred{T<:AbstractString}
    key::T
    url::T
end
Fred(key) =  Fred(key, DEFAULT_API_URL)
function Fred()
    key = try
        open(joinpath(homedir(),".freddatarc"), "r") do f
            readall(f)
        end
    catch err
        @printf STDERR "Add Fred API key to ~/.freddatarc\n"
        rethrow(err)
    end

    # Key validation
    if length(key) > API_KEY_LENGTH
        key = key[1:API_KEY_LENGTH]
        warn("Key too long. First ", API_KEY_LENGTH, " chars used.")
    end
    if !isxdigit(key)
        error("Invalid FRED API key: ", key)
    end

    return Fred(key)
end
get_api_key(b::Fred) = b.key
get_api_url(b::Fred) = b.url
set_api_url{T}(b::Fred{T}, url::T) = setfield!(b, :url, url)

immutable FredSeries{T<:AbstractString}
    # From series query
    id::T
    title::T
    units_short::T
    units::T
    seasonal_adjustment_short::T
    seasonal_adjustment::T
    frequency_short::T
    frequency::T
    realtime_start::T
    realtime_end::T
    last_updated::DateTime
    notes::T

    # From series/observations query
    transformation_short::T # "units"
    data::DataFrames.DataFrame
end

include("series.jl")

end # module
