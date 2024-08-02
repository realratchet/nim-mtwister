import nimpy
import std/math

proc pyLongToByteArray*(vv: nimpy.PyObject): seq[uint32] =
    let bits = vv.bit_length().to(int)
    var words = newSeq[uint32]()
    var bitsLeft = bits
    var v = vv

    while bitsLeft > 0:
        let newBits = min(32, bitsLeft)
        let shift = int (pow(2.0, float newBits) - 1)
        let extracted = v.callMethod("__and__", shift)
        v = v.callMethod("__rshift__", newBits)

        words.add(extracted.to(uint32))
        
        bitsLeft = bitsLeft - newBits

    return words