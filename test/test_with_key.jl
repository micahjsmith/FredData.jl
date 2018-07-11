using FredData
using Test

f = Fred()
s1 = get_data(f, "GDPC1")
s2 = get_data(f, "GDPC1"; units="chg", vintage_dates="2015-01-01")

# Bad requests
@test_throws Exception get_data(f, "GDPC1"; limit="foo")
@test_throws Exception get_data(f, "GDPC1"; vintage_dates="bar")

nothing
