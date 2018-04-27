# FredData

A third-party Julia library to pull data from
[Federal Reserve Economic Data](https://research.stlouisfed.org/fred2/) (FRED).

|                         | Does this thing work?                                           |
| ----------------------- | :-------------------------------------------------------------- |
| **Documentation**       | \<this page, for now\>                                          |
| **Package Evaluator**   | [![][pkg-0.5-img]][pkg-0.5-url] [![][pkg-0.6-img]][pkg-0.6-url] |
| **Build Status**        | [![][travis-img]][travis-url] [![][appveyor-img]][appveyor-url] |

## Disclaimer


*FredData* is not affiliated in any way with Federal Reserve Bank of St. Louis and is not
officially maintained or otherwise supported by Federal Reserve Bank of St. Louis.

*FredData* is free software and is issued under the MIT [license](LICENSE.md).

## Setup

*FredData* uses FRED's [Developer API](https://research.stlouisfed.org/docs/api/). As such,
you must register an API key [here](https://research.stlouisfed.org/docs/api/api_key.html)
in order to pull from the FRED servers.

Download the package with
```julia
julia> Pkg.add("FredData")
```

Make the FRED API key that you just registered accessible to *FredData* in one of several
ways. Ideally, we store your key such that it persists across sessions. In subsequent
sections, we'll assume that you *have* stored your key in one of these ways such that it can
be detected automatically. This will allow the use of the zero-argument constructor.

1. Populate a configuration file `~/.freddatarc`.

    ```julia
    julia> open(joinpath(homedir(), ".freddatarc"), "w") do f
               write(f, "0123456789abcdef0123456789abcdef")
           end
    ```
2. Populate the environment variable `FRED_API_KEY` such that it remains across sessions.

    ```julia
    # on macOS/Linux
    shell> echo "export FRED_API_KEY=0123456789abcdef0123456789abcdef" >> ~/.bashrc

    # on Windows 7+
    shell> setx FRED_API_KEY 0123456789abcdef0123456789abcdef
    ```

Another option is to provide your API key to the constructor every time you wish to use the
package.

3. Provide the `Fred` constructor with your API key directly.

    ```julia
    julia> f = Fred("0123456789abcdef0123456789abcdef")
    FRED API Connection
            url: https://api.stlouisfed.org/fred/
            key: 0123456789abcdef0123456789abcdef
    ```

## Usage

### Basic Usage

Query observations and metadata.
```julia
julia> using FredData

julia> f = Fred()
API key loaded.
FRED API Connection
        url: http://api.stlouisfed.org/fred/
        key: 0123456789abcdef0123456789abcdef

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
        data: 275x4 DataFrame with columns [:realtime_start,:realtime_end,:date,:value]
```

### Advanced Usage

Add optional arguments. All optional arguments specified by the FRED API are supported.
```julia
using FredData
f = Fred()
data = get_data(f, "GDPC1"; vintage_dates="2008-09-15")
data = get_data(f, "GDPC1"; frequency="a", units="chg")
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

Get fields of a series `s`:
- `s.id`: Series ID
- `s.title`: Series title
- `s.units_short`: Units (abbr.)
- `s.units`: Units
- `s.seas_adj_short`: Seasonal adjustment (abbr.)
- `s.seas_adj`: Seasonal adjustment
- `s.freq_short`: *Native* frequency (abbr.)
- `s.freq`: *Native* frequency
- `s.realtime_start`: Date realtime period starts
- `s.realtime_end`: Date realtime period ends
- `s.last_updated`: Date series last updated
- `s.notes`: Series notes
- `s.trans_short`: Transformation of queried data (abbr.)
- `s.data`: The actual data; DataFrame with columns `:realtime_start`,
  `:realtime_end`, `:date`, `:value`

## Notes

Todo list:  
☐ improve test coverage  
☐ support creation of pseudo-vintages  
☐ support methods to query other parts of the API, such as releases, tags, and search  

[pkg-0.4-img]: http://pkg.julialang.org/badges/FredData_0.4.svg
[pkg-0.4-url]: http://pkg.julialang.org/?pkg=FredData
[pkg-0.5-img]: http://pkg.julialang.org/badges/FredData_0.5.svg
[pkg-0.5-url]: http://pkg.julialang.org/?pkg=FredData
[pkg-0.6-img]: http://pkg.julialang.org/badges/FredData_0.6.svg
[pkg-0.6-url]: http://pkg.julialang.org/?pkg=FredData
[pkg-0.7-img]: http://pkg.julialang.org/badges/FredData_0.7.svg
[pkg-0.7-url]: http://pkg.julialang.org/?pkg=FredData
[travis-img]: https://travis-ci.org/micahjsmith/FredData.jl.svg?branch=master
[travis-url]: https://travis-ci.org/micahjsmith/FredData.jl
[appveyor-img]: https://ci.appveyor.com/api/projects/status/qmrotjcadtruev03/branch/master?svg=true
[appveyor-url]: https://ci.appveyor.com/project/micahjsmith/freddata-jl
