import nimpy
import std/unittest
import utils


test "test python interop short":
    var builtins = nimpy.pyBuiltinsModule()
    var pyVal = builtins.int(42)
    var pyLong = pyLongToByteArray(pyVal)

    assert pyLong.len == 1
    assert pyLong[0] == 42u32

test "test python interop long":
    var builtins = nimpy.pyBuiltinsModule()
    var pyVal = builtins.int(4294967296 + 42)
    var pyLong = pyLongToByteArray(pyVal)

    assert pyLong.len == 2
    assert pyLong[0] == 42u32
    assert pyLong[1] == 1u32
