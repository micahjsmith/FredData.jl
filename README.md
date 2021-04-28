<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://micahjsmith.github.io/FredData.jl/stable) -->
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://micahjsmith.github.io/FredData.jl/dev)
[![Tests](https://github.com/micahjsmith/FredData.jl/actions/workflows/Tests.yml/badge.svg)](https://github.com/micahjsmith/FredData.jl/actions/workflows/Tests.yml)
[![Coverage](https://codecov.io/gh/micahjsmith/FredData.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/micahjsmith/FredData.jl)
[![version](https://juliahub.com/docs/FredData/version.svg)](https://juliahub.com/ui/Packages/FredData/SEoaS)
[![pkgeval](https://juliahub.com/docs/FredData/pkgeval.svg)](https://juliahub.com/ui/Packages/FredData/SEoaS)

# FredData.jl

A third-party Julia library to pull data from
[Federal Reserve Economic Data](https://research.stlouisfed.org/fred2/) (FRED).

* Homepage: https://github.com/micahjsmith/FredData.jl
* Documentation: https://micahjsmith.github.io/FredData.jl/dev
* License: [MIT License](LICENSE)

## Disclaimer

*FredData* is not affiliated in any way with Federal Reserve Bank of St. Louis and is not
officially maintained or otherwise supported by Federal Reserve Bank of St. Louis.

## Quickstart

Here is what you can do with *FredData*:

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

For full usage, refer to the [documentation](https://micahjsmith.github.io/FredData.jl/dev)
