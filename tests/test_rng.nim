import std/[unittest, math]
import mtwister

test "no seed":
    var rng = newMTwister()

    assert rng.randInt(10) == 6
    assert rng.randInt(10) == 6
    assert rng.randInt(10) == 0
    assert rng.randInt(10) == 4
    assert rng.randInt(10) == 8

    rng = newMTwister()

    assert rng.randInt(10) == 6
    assert rng.randInt(10) == 6
    assert rng.randInt(10) == 0
    assert rng.randInt(10) == 4
    assert rng.randInt(10) == 8

test "with seed":
    var rng = newMTwister(42)

    assert rng.randInt(10) == 10
    assert rng.randInt(10) == 1
    assert rng.randInt(10) == 0
    assert rng.randInt(10) == 11
    assert rng.randInt(10) == 4

test "array seed 32bits":
    var rng = newMTwister(@[42u32])

    assert rng.randInt(10) == 10
    assert rng.randInt(10) == 1
    assert rng.randInt(10) == 0
    assert rng.randInt(10) == 11
    assert rng.randInt(10) == 4

test "array seed 64bits":
    var rng = newMTwister(@[42u32, 1u32])

    assert rng.randInt(10) == 9
    assert rng.randInt(10) == 6
    assert rng.randInt(10) == 2
    assert rng.randInt(10) == 1
    assert rng.randInt(10) == 4

test "float":
    var rng = newMTwister(42)
    var eps = 1e-5

    assert abs(rng.random() - 0.6394267984578837) < eps
    assert abs(rng.random() - 0.02501075522266694) < eps
    assert abs(rng.random() - 0.2750293183691193) < eps
    assert abs(rng.random() - 0.2232107381488228) < eps
    assert abs(rng.random() - 0.7364712141640124) < eps

test "sample":
    var rng = newMTwister(42)
    var arr = @[1, 2, 3, 4, 5]

    assert rng.sample(arr) == 1
    assert rng.sample(arr) == 1
    assert rng.sample(arr) == 3
    assert rng.sample(arr) == 2
    assert rng.sample(arr) == 2
