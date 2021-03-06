```@meta
CurrentModule = FredData
```

# FredData

[FredData.jl](https://github.com/micahjsmith/FredData.jl) is a third-party Julia library to pull data from
[Federal Reserve Economic Data](https://research.stlouisfed.org/fred2/) (FRED).

Among other uses, FredData is used by the [NY Fed's DSGE.jl package](https://frbny-dsge.github.io/DSGE.jl/latest/).

## Disclaimer


*FredData* is not affiliated in any way with Federal Reserve Bank of St. Louis and is not
officially maintained or otherwise supported by Federal Reserve Bank of St. Louis.

*FredData* is free software and is issued under the MIT License.

## Setup

### Installation

Download the package with

```julia
julia> Pkg.add("FredData")
```

### FRED API Access

*FredData* uses FRED's [Developer API](https://research.stlouisfed.org/docs/api/). As such,
you must register an API key [here](https://research.stlouisfed.org/docs/api/api_key.html)
in order to pull from the FRED servers.


Make the FRED API key that you just registered accessible to *FredData* in one of several
ways. Ideally, we store your key such that it persists across sessions. In subsequent
sections, we'll assume that you *have* stored your key in one of these ways such that it can
be detected automatically. This will allow the use of the zero-argument constructor.

#### Configuration File

Populate a configuration file `~/.freddatarc`.

```julia
julia> open(joinpath(homedir(), ".freddatarc"), "w") do f
           write(f, "0123456789abcdef0123456789abcdef")
       end
```

#### Environment variable

Populate the environment variable `FRED_API_KEY` such that it persists across sessions.

```julia
# on macOS/Linux
shell> echo "export FRED_API_KEY=0123456789abcdef0123456789abcdef" >> ~/.bashrc

# on Windows 7+
shell> setx FRED_API_KEY 0123456789abcdef0123456789abcdef
```

#### Constructor

Another option is to provide your API key to the constructor every time you wish to use the
package.

```@repl
f = Fred("0123456789abcdef0123456789abcdef")
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

For a full list of optional arguments, see [`get_data`](@ref) or
[the FRED API docs](https://research.stlouisfed.org/docs/api/fred/series_observations.html)

### The `Fred` type

The `Fred` type represents a connection to the FRED API.

See [`Fred`](@ref).

### The `FredSeries` type

The `FredSeries` type contains the data in a query response.

See [`FredSeries`](@ref).
