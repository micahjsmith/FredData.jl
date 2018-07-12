__precompile__()


module FredData

using DataFrames
using Dates
using Printf
import HTTP
import JSON

export
       # Fred object
       Fred, get_api_url, set_api_url!, get_api_key,

       # FredSeries object
       FredSeries,

       # Download data
       get_data

const MAX_ATTEMPTS       = 3
const FIRST_REALTIME     = Date(1776,07,04)
const LAST_REALTIME      = Date(9999,12,31)
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
- `Fred(key::AbstractString)`: User specifies key directly

Arguments
---------
- `key`: Registration key provided by the Fred.

Notes
-----
- Set the API url with `set_api_url!(f::Fred, url::AbstractString)`
"""
mutable struct Fred
    key::AbstractString
    url::AbstractString
    function Fred(key, url)
        # Key validation
        if length(key) > API_KEY_LENGTH
            key = key[1:API_KEY_LENGTH]
            warn("FRED API key too long. First $(API_KEY_LENGTH) chars used.")
        elseif length(key) < API_KEY_LENGTH
            error("Invalid FRED API key -- key too short: $(key)")
        end
        if !all(isxdigit, key)
            error("Invalid FRED API key -- invalid characters: $(key)")
        end
        return new(key, url)
    end
end
Fred(key::AbstractString) = Fred(key, DEFAULT_API_URL)
function Fred()
    key = if KEY_ENV_NAME in keys(ENV)
        ENV[KEY_ENV_NAME]
    elseif isfile(joinpath(homedir(), KEY_FILE_NAME))
        open(joinpath(homedir(), KEY_FILE_NAME), "r") do file
            rstrip(read(file, String))
        end
    else
        error("FRED API Key not detected.")
    end

    println("API key loaded.")
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

Represent a single data series, and all associated metadata, as queried from FRED.

The following fields are available:
- `id`
- `title`
- `units_short`
- `units`
- `seas_adj_short`
- `seas_adj`
- `freq_short`
- `freq`
- `realtime_start`
- `realtime_end`
- `last_updated`
- `notes`
- `trans_short`
- `data`

"""
struct FredSeries
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
    data::DataFrames.DataFrame

    # deprecated
    df::DataFrames.DataFrame
end

function Base.show(io::IO, s::FredSeries)
    @printf io "FredSeries\n"
    @printf io "\tid: %s\n"                s.id
    @printf io "\ttitle: %s\n"             s.title
    @printf io "\tunits: %s\n"             s.units
    @printf io "\tseas_adj (native): %s\n" s.seas_adj
    @printf io "\tfreq (native): %s\n"     s.freq
    @printf io "\trealtime_start: %s\n"    s.realtime_start
    @printf io "\trealtime_end: %s\n"      s.realtime_end
    @printf io "\tlast_updated: %s\n"      s.last_updated
    @printf io "\tnotes: %s\n"             s.notes
    @printf io "\ttrans_short: %s\n"       s.trans_short
    @printf io "\tdata: %dx%d DataFrame with columns %s\n" size(s.data)... names(s.data)
end

# old, deprecated accessors
export
    id, title, units_short, units, seas_adj_short, seas_adj, freq_short,
    freq, realtime_start, realtime_end, last_updated, notes, trans_short,
    df
@deprecate id(f::FredSeries) getfield(f, :id)
@deprecate title(f::FredSeries) getfield(f, :title)
@deprecate units_short(f::FredSeries) getfield(f, :units_short)
@deprecate units(f::FredSeries) getfield(f, :units)
@deprecate seas_adj_short(f::FredSeries) getfield(f, :seas_adj_short)
@deprecate seas_adj(f::FredSeries) getfield(f, :seas_adj)
@deprecate freq_short(f::FredSeries) getfield(f, :freq_short)
@deprecate freq(f::FredSeries) getfield(f, :freq)
@deprecate realtime_start(f::FredSeries) getfield(f, :realtime_start)
@deprecate realtime_end(f::FredSeries) getfield(f, :realtime_end)
@deprecate last_updated(f::FredSeries) getfield(f, :last_updated)
@deprecate notes(f::FredSeries) getfield(f, :notes)
@deprecate trans_short(f::FredSeries) getfield(f, :trans_short)
@deprecate df(f::FredSeries) getfield(f, :data)

include("get_data.jl")

end # module
