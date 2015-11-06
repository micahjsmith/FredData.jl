"""
"""
function get_data(f::Fred, series::ASCIIString)
    # Setup
    metadata_url = get_api_url(f) * "series"
    obs_url      = get_api_url(f) * "series/observations"
    key          = get_api_key(f)
    query        = Dict()

    # Add query parameters
    query["series_id"] = series
    query["api_key"]   = key
    query["file_type"] = "json"

    # Query metadata
    metadata = get(url; query=query)
    metadata_json = Requests.json(metadata)

    # Query observations
    obs = get(url; query=query)
    obs_json = Request.json(obs)

    df = parse_observations(obs_json["observations"])

    return nothing
end

# obs is a vector, of which each element is a dict with four fields,
# - realtime_start
# - realtime_end
# - date
# - value
function parse_observations(obs::Vector)
    n_obs = length(obs["observations"])
    values = Vector{Float64}(n_obs)
    dates  = Vector{Date}(n_obs)
    for (i, x) in enumerate(obs["series"])
        values[i] = parse(Float64, x["value"])
        dates[i]  = Date(x["date"], "yyyy-mm-dd")
    end
    return DataFrame(dates=dates, values=values)
end
