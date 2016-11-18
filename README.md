# FredData
[![FredData](http://pkg.julialang.org/badges/FredData_0.4.svg)](http://pkg.julialang.org/?pkg=FredData)
[![FredData](http://pkg.julialang.org/badges/FredData_0.5.svg)](http://pkg.julialang.org/?pkg=FredData)
[![Build Status](https://travis-ci.org/micahjsmith/FredData.jl.svg?branch=master)](https://travis-ci.org/micahjsmith/FredData.jl)


A third-party Julia library to pull data from
[Federal Reserve Economic Data](https://research.stlouisfed.org/fred2/)
(FRED) using their [Developer API](https://research.stlouisfed.org/docs/api/).

You must register an API key [here](https://research.stlouisfed.org/docs/api/api_key.html)
in order to pull from the FRED servers.

## Disclaimer

*FredData* is not affiliated in any way with Federal Reserve Bank of St. Louis and is not
officially maintained or otherwise supported by Federal Reserve Bank of St. Louis.

*FredData* is free software and is issued under the MIT [license](LICENSE.md).

## Setup

Download the package with
```julia
julia> Pkg.add("FredData")
```

Now, register your FRED API key and make it accessible to *FredData* in one of several ways.
Ideally, we store your key such that it persists across sessions. In subsequent sections,
we'll assume that you *have* stored your key in one of these ways such that it can be detected
automatically. This will allow the use of the zero-argument constructor.

1. Populate a configuration file `~/.freddatarc`.

    ```julia
    julia> open(joinpath(homedir(), ".freddatarc"), "w") do f
               write(f, "abcdefghijklmnopqrstuvwxyz123456")
           end
    ```
2. Populate the environment variable `FRED_API_KEY` such that it remains across sessions.

    ```julia
    # on macOS/Linux
    shell> export FRED_API_KEY=abcdefghijklmnopqrstuvwxyz123456 >> ~/.bashrc

    # on Windows 7+
    shell> setx FRED_API_KEY abcdefghijklmnopqrstuvwxyz123456
    ```

 Another option, though less user-friendly, is to provide your API key to the constructor
every time you wish to use the package.

3. Provide the `Fred` constructor with your API key directly.

    ```julia
    julia> f = Fred("abcdefghijklmnopqrstuvwxyz123456")
    FRED API Connection
            url: https://api.stlouisfed.org/fred/
            key: abcdefghijklmnopqrstuvwxyz123456
    ```

## Usage

### Basic Usage

Query observations and metadata.
```
julia> using FredData

julia> f = Fred()
API key loaded.
FRED API Connection
        url: http://api.stlouisfed.org/fred/
        key: abcdefghijklmnopqrstuvwxyz123456

julia> a = get_data(f, "GDPC1")
FredSeries
        id: GDPC1
        title: Real Gross Domestic Product
        units: Billions of Chained 2009 Dollars
        seas_adj (native): Seasonally Adjusted Annual Rate
        freq (native): Quarterly
        realtime_start: 2015-12-11
        realtime_end: 2015-12-11
        last_updated: 2015-11-24T08:01:09
        notes: BEA Account Code: A191RX1 Real gross domestic product is the inflation adjusted value of the goods and services produced by labor and property located in the United States. For more information see the Guide to the National Income and Product Accounts of the United States (NIPA) - (http://www.bea.gov/national/pdf/nipaguid.pdf)
        trans_short: lin
        df: 275x4 DataFrame with columns [:realtime_start,:realtime_end,:date,:value]
```

### Advanced Usage

Add optional arguments. All optional arguments specified by the FRED API are supported.
```julia
using FredData
f = Fred()
b = get_data(f, "GDPC1"; vintage_dates="2008-09-15")
c = get_data(f, "GDPC1"; frequency="a", units="chg")
```

For a full list of optional arguments, see `?get_data` or
[here](https://research.stlouisfed.org/docs/api/fred/series_observations.html)

### The `Fred` type

The `Fred` type represents a connection to the FRED API.

Get and set fields.
- `get_api_key(f::Fred)`: Get the base URL used to connect to the server
- `get_api_url(f::Fred)`: Get the base URL used to connect to the server
- `set_api_url!(f::Fred, url::AbstractString)`: Set the base URL used to connect to the
  server

### The `FredSeries` type

The `FredSeries` type contains the data in a query response.

Get fields.
- `id(s::FredSeries)`: Series ID
- `title(s::FredSeries)`: Series title
- `units_short(s::FredSeries)`: Units (abbr.)
- `units(s::FredSeries)`: Units
- `seas_adj_short(s::FredSeries)`: Seasonal adjustment (abbr.)
- `seas_adj(s::FredSeries)`: Seasonal adjustment
- `freq_short(s::FredSeries)`: *Native* frequency (abbr.)
- `freq(s::FredSeries)`: *Native* frequency
- `realtime_start(s::FredSeries)`: Date realtime period starts
- `realtime_end(s::FredSeries)`: Date realtime period ends
- `last_updated(s::FredSeries)`: Date series last updated
- `notes(s::FredSeries)`: Series notes
- `trans_short(s::FredSeries)`: Transformation of queried data (abbr.)
- `df(s::FredSeries)`: The actual data; DataFrame with columns `:realtime_start`,
  `:realtime_end`, `:date`, `:value`

## Notes

Todo list:  
☐ improve test coverage  
☐ support creation of pseudo-vintages  
☐ support methods to query other parts of the API, such as releases, tags, and search  
☐ improve some API elements to be more idiomatic
