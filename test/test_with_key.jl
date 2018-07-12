using FredData
using Test

@testset "Basic usage" begin
    f = Fred()
    s1 = get_data(f, "GDPC1")
end

@testset "Sanity tests on simple queries" begin
    function sanity_test_on_query_response(id)
        f = Fred()
        s = get_data(f, id)
        @test s.id == id
        @test !isempty(s.data)
    end

    for id in ["GDPC1"]
        sanity_test_on_query_response(id)
    end
end

@testset "Consistent responses from specific vintages" begin
    f = Fred()
    vintage_dates = "2015-01-01"
    s = get_data(f, "GDPC1"; units="chg", vintage_dates=vintage_dates)
    @test size(s.data) == (271, 4)
    @test s.realtime_start == vintage_dates
    @test s.realtime_end == vintage_dates
end

@testset "Bad requests throw exceptions" begin
    f = Fred()
    @test_throws Exception get_data(f, "GDPC1"; limit="foo")
    @test_throws Exception get_data(f, "GDPC1"; vintage_dates="bar")
end

nothing
