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
type Fred
    key::ASCIIString
    url::ASCIIString
end
Fred(key::ASCIIString) =  Fred(key, DEFAULT_API_URL)
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
set_api_url(b::Fred, url::ASCIIString) = setfield!(b, :url, url)

immutable FredSeries
    # From series query
    id::ASCIIString
    title::ASCIIString
    units_short::ASCIIString
    units::ASCIIString
    seasonal_adjustment_short::ASCIIString
    seasonal_adjustment::ASCIIString
    frequency_short::ASCIIString
    frequency::ASCIIString
    realtime_start::ASCIIString
    realtime_end::ASCIIString

    # From series/observations query
    transformation::ASCIIString # "units"
    data::DataFrames.DataFrame
end

include("series.jl")

end # module
