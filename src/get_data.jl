"""
```
get_data(f::Fred, series::AbstractString; kwargs...)
```

Request one series using the FRED API.

### Arguments
- `f`: Fred connection object
- `series`: series mnemonic

### Optional Arguments
- `retries`: number of retries if server error

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
function get_data(f::Fred, series::AbstractString; retries=MAX_ATTEMPTS, kwargs...)
    # Validation
    validate_args!(kwargs)

    # Setup
    metadata_url = get_api_url(f) * "series"
    obs_url      = get_api_url(f) * "series/observations"
    key          = get_api_key(f)

    # Add query parameters
    query_metadata = Dict("api_key"   => key,
                          "file_type" => "json",
                          "series_id" => series)
    query_obs = query_metadata

    # Query observations. Expand query dict with kwargs. Do this first so we can use the
    # calculated realtime values for the metadata request.
    for (i,j) in kwargs
        query_obs[string(i)] = string(j)
    end
    obs = get(obs_url; query=query_obs)
    obs_json = Requests.json(obs)

    # Confirm request okay
    if haskey(obs_json, "error_code")

        # If error 500 (Internal Server Error), we can retry our request. Otherwise, give
        # up.
        if obs_json["error_code"] == 500 && retries > 0
            return get_data(f, series; retries=retries-1, kwargs)
        else
            error(series, ": ", obs_json["error_message"], " (", obs_json["error_code"],")")
        end

    end

    # Parse observations
    realtime_start  = obs_json["realtime_start"]
    realtime_end    = obs_json["realtime_end"]
    transformation_short = obs_json["units"]

    df = parse_observations(obs_json["observations"])

    # Query metadata
    query_metadata["realtime_start"] = realtime_start
    query_metadata["realtime_end"] = realtime_end
    metadata = get(metadata_url; query=query_metadata)
    metadata_json = Requests.json(metadata)

    # Parse metadata
    metadata_parsed = Dict{Symbol, AbstractString}()
    for k in ["id", "title", "units_short", "units", "seasonal_adjustment_short",
        "seasonal_adjustment", "frequency_short", "frequency", "notes"]
        try
            @compat metadata_parsed[Symbol(k)] = metadata_json["seriess"][1][k]
        catch err
            @compat metadata_parsed[Symbol(k)] = ""
            warn("Metadata '$k' not returned from server.")
        end
    end

    # the last three chars are -05, for CST in St. Louis
    tmp = metadata_json["seriess"][1]["last_updated"]
    zone = tmp[end-2:end]
    last_updated = DateTime(tmp[1:end-3], "yyyy-mm-dd HH:MM:SS")

    # format notes field
    metadata_parsed[:notes] = (metadata_parsed[:notes]
                               |> replace(r"[\r\n]", " ")
                               |> replace(r" +", " ")
                               |> strip)

    return FredSeries(metadata_parsed[:id], metadata_parsed[:title],
                      metadata_parsed[:units_short], metadata_parsed[:units],
                      metadata_parsed[:seasonal_adjustment_short],
                      metadata_parsed[:seasonal_adjustment],
                      metadata_parsed[:frequency_short], metadata_parsed[:frequency],
                      realtime_start, realtime_end, last_updated, metadata_parsed[:notes],
                      transformation_short, df)
end

# obs is a vector, of which each element is a dict with four fields,
# - realtime_start
# - realtime_end
# - date
# - value
function parse_observations(obs::Vector)
    n_obs = length(obs)
    value = Vector{Float64}(n_obs)
    date  = Vector{Date}(n_obs)
    realtime_start = Vector{Date}(n_obs)
    realtime_end = Vector{Date}(n_obs)
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
isyyyymmdd(x) = ismatch(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}$", x)
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
            deleteat!(kwargs, find(x -> x[1]==k, kwargs))
        end
    end
end
