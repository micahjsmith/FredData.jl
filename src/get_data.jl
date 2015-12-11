"""
```
get_data(f::Fred, series::AbstractString; kwargs...)
```

Request one series using the FRED API.

### Arguments
- `f`: Fred connection object
- `series`: series mnemonic

### Optional Arguments
- `kwargs...`: key-value pairs to be appended to the FRED request. Accepted keys include:
  - `realtime_start`: the startof the real-time period as YYYY-MM-DD string
  - `realtime_end`: the end of the real-time period as YYYY-MM-DD string
  - `limit`: maximum number of results to return
  - `offset`: non-negative integer
  - `sort_order`: `"asc"`, `"desc`"
  - `observation_start`: the start of the observation period as YYYY-MM-DD string
  - `observation_end`: the end of the observation period as YYYY-MM-DD string
  - `units`: one of `"lin"`, `"chg"`, `"ch1"`, `"pch"`, `"pc1"`, `"pca"`, `"cch"`, `"cca"`,
    `"log`"
  - `frequency`: one of `"d"`, `"w"`, `"bw"`, `"m"`, `"q"`, `"sa"`, `"a"`, `"wef"`,
    `"weth"`, `"wew"`, `"wetu"`, `"wem"`, `"wesu"`, `"wesa"`, `"bwew"`, `"bwem`"
  - `aggregation_method`: one of `"avg"`, `"sum"`, `"eop"`
  - `output_type`: output type
    1. obsevations by real-time period
    2. observations by vintage date, all observations
    3. observations by vintage date, new and revised observations only
    4. observations, initial release only
  - `vintage_dates`: comma-separated string of YYYY-MM-DD vintage dates


"""
function get_data(f::Fred, series::AbstractString; kwargs...)
    # Setup
    metadata_url = get_api_url(f) * "series"
    obs_url      = get_api_url(f) * "series/observations"
    key          = get_api_key(f)

    # Add query parameters
    query = Dict("api_key"   => key,
                 "file_type" => "json",
                 "series_id" => series)

    # Query and extract metadata
    metadata = get(metadata_url; query=query)
    metadata_json = Requests.json(metadata)
    id                        = metadata_json["seriess"][1]["id"]
    title                     = metadata_json["seriess"][1]["title"]
    units_short               = metadata_json["seriess"][1]["units_short"]
    units                     = metadata_json["seriess"][1]["units"]
    seasonal_adjustment_short = metadata_json["seriess"][1]["seasonal_adjustment_short"]
    seasonal_adjustment       = metadata_json["seriess"][1]["seasonal_adjustment"]
    frequency_short           = metadata_json["seriess"][1]["frequency_short"]
    frequency                 = metadata_json["seriess"][1]["frequency"]
    notes                     = metadata_json["seriess"][1]["notes"]

    # the last three chars are -05, for CST in St. Louis
    tmp = metadata_json["seriess"][1]["last_updated"]
    zone = tmp[end-2:end]
    last_updated = DateTime(tmp[1:end-3], "yyyy-mm-dd HH:MM:SS")

    # Query observations. Expand query dict with kwargs.
    for (i,j) in kwargs
        query[string(i)] = j
    end
    obs = get(obs_url; query=query)
    obs_json = Requests.json(obs)

    realtime_start  = obs_json["realtime_start"]
    realtime_end    = obs_json["realtime_end"]
    transformation_short = obs_json["units"]

    df = parse_observations(obs_json["observations"])

    return FredSeries(id, title, units_short, units, seasonal_adjustment_short,
                      seasonal_adjustment, frequency_short, frequency, realtime_start,
                      realtime_end, last_updated, notes, transformation_short, df)
end

# obs is a vector, of which each element is a dict with four fields,
# - realtime_start
# - realtime_end
# - date
# - value
function parse_observations(obs::Vector)
    n_obs = length(obs)
    values = Vector{Float64}(n_obs)
    dates  = Vector{Date}(n_obs)
    for (i, x) in enumerate(obs)
        values[i] = parse(Float64, x["value"])
        dates[i]  = Date(x["date"], "yyyy-mm-dd")
    end
    return DataFrame(dates=dates, values=values)
end
