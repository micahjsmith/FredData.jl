# News

## v0.3.0

- Remove compatibility for Julia v0.6 and earlier.
- Switch to HTTP.jl for requests.

## v0.2.0

- Deprecate the old API that provides separate accessor functions for each field of the
    `FredSeries` type. Instead, use `s.name`, `s.data`, etc. directly.
