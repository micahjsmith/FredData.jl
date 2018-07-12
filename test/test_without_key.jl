using FredData
using Test

function with_key_env(f::Function, key::AbstractString)
    withenv(FredData.KEY_ENV_NAME => key) do
        f()
    end
end

function with_key_file(f::Function, key::AbstractString)
    mktempdir() do tmpdir
        open(joinpath(tmpdir, FredData.KEY_FILE_NAME), "w") do f
            write(f, key)
        end
        withenv(FredData.KEY_ENV_NAME => nothing,
                "USERPROFILE" => tmpdir,
                "HOME" => tmpdir, ) do
            f()
        end
    end
end

function with_key_none(f::Function)
    mktempdir() do tmpdir
        withenv(FredData.KEY_ENV_NAME => nothing,
                "USERPROFILE" => tmpdir,
                "HOME" => tmpdir, ) do
            f()
        end
    end
end

@testset "Client creation with key" begin
    fake_key = repeat("0", FredData.API_KEY_LENGTH)
    fake_key1 = repeat("1", FredData.API_KEY_LENGTH)

    # pass key directly
    f1 = Fred(fake_key)
    @test f1.key == fake_key

    # detect from ENV
    with_key_env(fake_key) do
        f2 = Fred()
        @test f2.key == fake_key
    end

    # detect from ~/.freddatarc
    # from libuv::uv_os_homedir, we find we need to set USERPROFILE for windows
    # and HOME for *nix
    with_key_file(fake_key1) do
        f3 = Fred()
        @test f3.key == fake_key1
    end
end

@testset "Client creation fails with invalid/missing key" begin
    bad_key_short = repeat("c",
                           convert(Int, round(FredData.API_KEY_LENGTH/2)))
    @test_throws Exception Fred(bad_key_short)

    # no key anywhere
    with_key_none() do
        @test_throws Exception Fred()
    end
end
