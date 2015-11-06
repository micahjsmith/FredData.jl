module FredData

using DataFrames
using Requests
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
Fred()                     # Default connection, reading from ~/.freddatarc
Fred(key::AbstractString)  # Custom connection

Arguments
---------
*`key`: Registration key provided by the Fred.

Notes
-----
Set the API url with `set_api_url{T}(f::Fred{T}, url::T)`
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
get_api_key(f::Fred) = b.key
get_api_url(f::Fred) = b.url
set_api_url{T}(f::Fred{T}, url::T) = setfield!(f, :url, url)

"""
`FredSeries(...)`

Represent a single data series, and all associated metadata, return from Fred.
"""
immutable FredSeries{T<:AbstractString}
    # From series query
    id::T
    title::T
    units_short::T
    units::T
    seas_adj_short::T
    seas_adj::T
    freq_short::T
    freq::T
    realtime_start::T
    realtime_end::T
    last_updated::DateTime
    notes::T

    # From series/observations query
    trans_short::T # "units"
    data::DataFrames.DataFrame
end
id(f::FredSeries) = f.id
title(f::FredSeries) = f.title
units_short(f::FredSeries) = f.units_short
units(f::FredSeries) = f.units
seas_adj_short(f::FredSeries) = f.seas_adj_short
seas_adj(f::FredSeries) = f.seas_adj
freq_short(f::FredSeries) = f.freq_short
freq(f::FredSeries) = f.freq
realtime_start(f::FredSeries) = f.realtime_start
realtime_end(f::FredSeries) = f.realtime_end
last_updated(f::FredSeries) = f.last_updated
notes(f::FredSeries) = f.notes
trans_short(f::FredSeries) = f.trans_short
data(f::FredSeries) = f.data

include("series.jl")

end # module
