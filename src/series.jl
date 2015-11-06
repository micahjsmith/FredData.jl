"""
"""
function get_data(f::Fred, series::ASCIIString)
    # Setup
    url = get_api_url(f) * "series"
    key = get_api_key(f)
    query=Dict()

    # Add query parameters
    query["series_id"] = series
    query["api_key"] = key
    query["file_type"] = "json"

    response = get(url; query=query)
    response_json = Requests.json(response)

    return response_json
end
