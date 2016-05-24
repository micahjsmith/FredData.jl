isdefined(Base, :__precompile__) && __precompile__()

module FredData

using Requests
using DataFrames
using TimeZones
import Requests: get
import JSON

export 
       # Fred object
       Fred, get_api_url, set_api_url!, get_api_key,

       # FredSeries object
       FredSeries, id, title, units_short, units, seas_adj_short, seas_adj, freq_short,
       freq, realtime_start, realtime_end, last_updated, notes, trans_short, df,
    
       # Download data
       get_data

const MAX_ATTEMPTS       = 3
const FIRST_REALTIME     = Date(1776,07,04)
const LAST_REALTIME      = Date(9999,12,31)
const FRED_TIME_ZONE     = TimeZone("America/Chicago")
const EARLY_VINTAGE_DATE = "1991-01-01"
const DEFAULT_API_URL    = "https://api.stlouisfed.org/fred/"
const API_KEY_LENGTH     = 32
const KEY_ENV_NAME       = "FRED_API_KEY"
const KEY_FILE_NAME      = ".freddatarc"

# Fred connection type
"""
A connection to the Fred API.

Constructors
------------
- `Fred()`: Key detected automatically. First, looks for the environment variable
    FRED_API_KEY, then looks for the file ~/.freddatarc.
- `Fred(key::AbstractString)`: User specifies key

Arguments
---------
- `key`: Registration key provided by the Fred.

Notes
-----
- Set the API url with `set_api_url!(f::Fred, url::AbstractString)`
"""
type Fred
    key::AbstractString
    url::AbstractString
end
Fred(key) =  Fred(key, DEFAULT_API_URL)
function Fred()
    key = ""
    if KEY_ENV_NAME in keys(ENV)
        key = ENV[KEY_ENV_NAME]
    elseif isfile(joinpath(homedir(), KEY_FILE_NAME))
        open(joinpath(homedir(), KEY_FILE_NAME), "r") do file
            key = readall(file)
        end
        key = rstrip(key)
    else
        error("FRED API Key not detected.")
    end

    @printf "API key loaded.\n"

    # Key validation
    if length(key) > API_KEY_LENGTH
        key = key[1:API_KEY_LENGTH]
        warn("Key too long. First ", API_KEY_LENGTH, " chars used.")
    elseif length(key) < API_KEY_LENGTH
        error("Invalid FRED API key: ", key, ". Key too short.")
    end
    if !isxdigit(key)
        error("Invalid FRED API key: ", key, ". Invalid characters.")
    end

    return Fred(key)
end
get_api_key(f::Fred) = f.key
get_api_url(f::Fred) = f.url
set_api_url!(f::Fred, url::AbstractString) = setfield!(f, :url, url)

function Base.show(io::IO, f::Fred)
    @printf io "FRED API Connection\n"
    @printf io "\turl: %s\n" get_api_url(f)
    @printf io "\tkey: %s\n" get_api_key(f)
end


"""
```
FredSeries(...)
```

Represent a single data series, and all associated metadata, return from Fred.

### Field access
- `id(f)`
- `title(f)`
- `units_short(f)`
- `units(f)`
- `seas_adj_short(f)`
- `seas_adj(f)`
- `freq_short(f)`
- `freq(f)`
- `realtime_start(f)`
- `realtime_end(f)`
- `last_updated(f)`
- `notes(f)`
- `trans_short(f)`
- `df(f)`

"""
immutable FredSeries
    # From series query
    id::AbstractString
    title::AbstractString
    units_short::AbstractString
    units::AbstractString
    seas_adj_short::AbstractString
    seas_adj::AbstractString
    freq_short::AbstractString
    freq::AbstractString
    realtime_start::AbstractString
    realtime_end::AbstractString
    last_updated::DateTime
    notes::AbstractString

    # From series/observations query
    trans_short::AbstractString # "units"
    df::DataFrames.DataFrame
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
function notes(f::FredSeries)
    str = f.notes
    str = replace(str, r"[\r\n]", " ")
    str = replace(str, r" +", " ")
    str = strip(str)
    return str
end
trans_short(f::FredSeries) = f.trans_short
df(f::FredSeries) = f.df

function Base.show(io::IO, s::FredSeries)
    @printf io "FredSeries\n"
    @printf io "\tid: %s\n"                id(s)
    @printf io "\ttitle: %s\n"             title(s)
    @printf io "\tunits: %s\n"             units(s)
    @printf io "\tseas_adj (native): %s\n" seas_adj(s)
    @printf io "\tfreq (native): %s\n"     freq(s)
    @printf io "\trealtime_start: %s\n"    realtime_start(s)
    @printf io "\trealtime_end: %s\n"      realtime_end(s)
    @printf io "\tlast_updated: %s\n"      last_updated(s)
    @printf io "\tnotes: %s\n"             notes(s)
    @printf io "\ttrans_short: %s\n"       trans_short(s)
    @printf io "\tdf: %dx%d DataFrame with columns %s\n" size(df(s))... names(df(s))
end

include("get_data.jl")

end # module
