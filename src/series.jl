"""
"""
function get_data(f::Fred, series::ASCIIString)
    # Setup
    metadata_url = get_api_url(f) * "series"
    obs_url      = get_api_url(f) * "series/observations"
    key          = get_api_key(f)
    query        = Dict()

    # Add query parameters
    query["api_key"]   = key
    query["file_type"] = "json"
    query["series_id"] = series

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
    realtime_start            = metadata_json["seriess"][1]["realtime_start"]
    realtime_end              = metadata_json["seriess"][1]["realtime_end"]
    notes                     = metadata_json["seriess"][1]["notes"]

    tmp = metadata_json["seriess"][1]["last_updated"]
    zone = tmp[end-2:end]
    last_updated = DateTime(tmp[1:end-3], "yyyy-mm-dd HH:MM:SS")

    # Query observations
    obs = get(obs_url; query=query)
    obs_json = Requests.json(obs)

    transformation_short = obs_json["units"]
    data = parse_observations(obs_json["observations"])

    return FredSeries(id, title, units_short, units, seasonal_adjustment_short,
                      seasonal_adjustment, frequency_short, frequency, realtime_start,
                      realtime_end, last_updated, notes, transformation_short, data)
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
