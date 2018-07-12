"""
```
get_data(f::Fred, series::AbstractString; kwargs...)
```

Request one series using the FRED API.

### Arguments
- `f`: Fred connection object
- `series`: series mnemonic

### Optional Arguments
`kwargs...`: key-value pairs to be appended to the FRED request. Accepted keys include:

- `realtime_start`: the start of the real-time period as YYYY-MM-DD string
- `realtime_end`: the end of the real-time period as YYYY-MM-DD string
- `limit`: maximum number of results to return
- `offset`: non-negative integer
- `sort_order`: `"asc"`, `"desc"`
- `observation_start`: the start of the observation period as YYYY-MM-DD string
- `observation_end`: the end of the observation period as YYYY-MM-DD string
- `units`: one of `"lin"`, `"chg"`, `"ch1"`, `"pch"`, `"pc1"`, `"pca"`, `"cch"`, `"cca"`,
  `"log"`
- `frequency`: one of `"d"`, `"w"`, `"bw"`, `"m"`, `"q"`, `"sa"`, `"a"`, `"wef"`,
  `"weth"`, `"wew"`, `"wetu"`, `"wem"`, `"wesu"`, `"wesa"`, `"bwew"`, `"bwem"`
- `aggregation_method`: one of `"avg"`, `"sum"`, `"eop"`
- `output_type`: one of `1` (obsevations by real-time period), `2` (observations by vintage
  date, all observations), `3` (observations by vintage date, new and revised observations
  only), `4` (observations, initial release only)
- `vintage_dates`: vintage dates as comma-separated YYYY-MM-DD strings
"""
function get_data(f::Fred, series::AbstractString; kwargs...)
    # Validation
    validate_args!(kwargs)

    # Setup
    metadata_url = get_api_url(f) * "series"
    obs_url      = get_api_url(f) * "series/observations"
    api_key      = get_api_key(f)

    # Add query parameters
    metadata_params = Dict("api_key"   => api_key,
                           "file_type" => "json",
                           "series_id" => series)
    obs_params = copy(metadata_params)

    # Query observations. Expand query dict with kwargs. Do this first so we can use the
    # calculated realtime values for the metadata request.
    for (key, value) in kwargs
        obs_params[string(key)] = string(value)
    end
    obs_response = HTTP.request("GET", obs_url, []; query=obs_params)
    obs_json = JSON.parse(String(copy(obs_response.body)))

    # Parse observations
    realtime_start  = obs_json["realtime_start"]
    realtime_end    = obs_json["realtime_end"]
    transformation_short = obs_json["units"]

    df = parse_observations(obs_json["observations"])

    # Query metadata
    metadata_params["realtime_start"] = realtime_start
    metadata_params["realtime_end"] = realtime_end
    metadata_response = HTTP.request("GET", metadata_url, []; query=metadata_params)
    metadata_json = JSON.parse(String(copy(metadata_response.body)))
    # TODO catch StatusError and just return incomplete data to the caller

    # Parse metadata
    metadata_parsed = Dict{Symbol, AbstractString}()
    for k in ["id", "title", "units_short", "units", "seasonal_adjustment_short",
        "seasonal_adjustment", "frequency_short", "frequency", "notes"]
        try
            metadata_parsed[Symbol(k)] = metadata_json["seriess"][1][k]
        catch err
            metadata_parsed[Symbol(k)] = ""
            warn("Metadata '$k' not returned from server.")
        end
    end

    # the last three chars are -05, for CST in St. Louis
    function parse_last_updated(last_updated)
        timezone = last_updated[end-2:end]  # TODO
        return DateTime(last_updated[1:end-3], "yyyy-mm-dd HH:MM:SS")
    end
    last_updated = parse_last_updated(
        metadata_json["seriess"][1]["last_updated"])

    # format notes field
    metadata_parsed[:notes] = strip(replace(replace(
        metadata_parsed[:notes], r"[\r\n]" => " "), r" +" => " "))

    return FredSeries(metadata_parsed[:id], metadata_parsed[:title],
                      metadata_parsed[:units_short], metadata_parsed[:units],
                      metadata_parsed[:seasonal_adjustment_short],
                      metadata_parsed[:seasonal_adjustment],
                      metadata_parsed[:frequency_short], metadata_parsed[:frequency],
                      realtime_start, realtime_end, last_updated, metadata_parsed[:notes],
                      transformation_short, df,
                      df) # deprecated
end

# obs is a vector, of which each element is a dict with four fields,
# - realtime_start
# - realtime_end
# - date
# - value
function parse_observations(obs::Vector)
    n_obs = length(obs)
    value = Vector{Float64}(undef, n_obs)
    date  = Vector{Date}(undef, n_obs)
    realtime_start = Vector{Date}(undef, n_obs)
    realtime_end = Vector{Date}(undef, n_obs)
    for (i, x) in enumerate(obs)
        try
            value[i] = parse(Float64, x["value"])
        catch err
            value[i] = NaN
        end
        date[i]           = Date(x["date"], "yyyy-mm-dd")
        realtime_start[i] = Date(x["realtime_start"], "yyyy-mm-dd")
        realtime_end[i]   = Date(x["realtime_end"], "yyyy-mm-dd")
    end
    return DataFrame(realtime_start=realtime_start, realtime_end=realtime_end,
                     date=date, value=value)
end

# Make sure everything is of the right format.
# kwargs is a vector of Tuple{Symbol, Any}.
isyyyymmdd(x) = occursin(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}$", x)
function validate_args!(kwargs)
    d = Dict(kwargs)

    # dates
    for k in [:realtime_start, :realtime_end, :observation_start, :observation_end]
        if (v = pop!(d, k, nothing)) != nothing && !isyyyymmdd(v)
                error("$k: Invalid date format: $v")
        end
    end
    # limit and offset
    for k in [:limit, :offset]
        if (v = pop!(d, k, nothing)) != nothing &&
            ( !(typeof(v) <: Number ) || typeof(v) <: Number && !(v>0) )
                error("$k: Invalid format: $v")
        end
    end
    # units
    if (v = pop!(d, :units, nothing)) != nothing &&
        v ∉ ["lin", "chg", "ch1", "pch", "pc1", "pca", "cch", "log"]
            error("units: Invalid format: $v")
    end
    # frequency
    if (v = pop!(d, :frequency, nothing)) != nothing &&
        v ∉ ["d", "w", "bw", "m", "q", "sa", "a", "wef", "weth", "wew", "wetu", "wem",
             "wesu", "wesa", "bwew", "bwem"]
            error("frequency: Invalid format: $v")
    end
    # aggregation_method
    if (v = pop!(d, :aggregation_method, nothing)) != nothing &&
        v ∉ ["avg", "sum", "eop"]
            error("aggregation_method: Invalid format: $v")
    end
    # output_type
    if (v = pop!(d, :output_type, nothing)) != nothing &&
        v ∉ [1, 2, 3, 4]
            error("output_type: Invalid format: $v")
    end
    # vintage dates, and too early vintages
    if (v = pop!(d, :vintage_dates, nothing)) != nothing
        vds_arr = split(string(v), ",")
        vds_bad = map(x -> !isyyyymmdd(x), vds_arr)
        if any(vds_bad)
            error("vintage_dates: Invalid date format: $(vds_arr[vds_bad])")
        end
        vds_early = map(x -> x<EARLY_VINTAGE_DATE, vds_arr)
        if any(vds_early)
            warn(:vintage_dates, ": Early vintage date, data might not exist: ",
                vds_arr[vds_early])
        end
    end
    # all remaining keys have unspecified behavior
    if length(d) > 0
        for k in keys(d)
            warn(string(k), ": Bad key. Removed from query.")
            deleteat!(kwargs, findall(x -> x[1]==k, kwargs))
        end
    end
end
