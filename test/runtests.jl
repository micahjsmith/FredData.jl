using FredData
using Base.Test

# Normal usage
f = Fred()
a = get_data(f, "GDPC1")
a = get_data(f, "GDPC1"; units="chg", vintage_dates="2015-01-01")

# Bad requests
@test_throws ErrorException get_data(f, "GDPC1"; limit="foo")
@test_throws ErrorException get_data(f, "GDPC1"; vintage_dates="bar")
