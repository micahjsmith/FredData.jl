# News

## 0.6.0 (2022-08-23)

- Add HTTP.jl v1 compatibility

## v0.5.0 (2021-04-23)

- Add DataFrames.jl v1 compatibility
    ([#19](https://github.com/micahjsmith/FredData.jl/pull/19) by
    [@chenwilliam77](https://github.com/chenwilliam77))


## v0.4.0 (2020-02-04)

- Fix compatibility upper bounds

## v0.3.2 (2020-02-04)

- Fix compatibility issue with TimeZones.jl ([#17](https://github.com/micahjsmith/FredData.jl/pull/17) by [@fratrik](https://github.com/fratrik))
- Bump minimum version of TimeZones.jl to 0.11, in turn bumping minimum version of Julia to v1

## v0.3.1 (2019-09-30)

- Fix usage of `@warn` ([#15](https://github.com/micahjsmith/FredData.jl/pull/15) by
    [@greimel](https://github.com/greimel))

## v0.3.0 (2018-07-12)

- Remove compatibility for Julia v0.6 and earlier
- Switch to HTTP.jl for requests

## v0.2.0 (2018-02-02)

- Deprecate the old API that provides separate accessor functions for each field of the
    `FredSeries` type. Instead, use `s.name`, `s.data`, etc. directly

## v0.1.0 (2015-12-11)

- Initial release
