from std/math import log2

const UPPER_MASK = 0x80000000u32
const LOWER_MASK = 0x7fffffffu32
const TEMPERING_MASK_B = 0x9d2c5680u32
const TEMPERING_MASK_C = 0xefc60000u32
const MATRIX_A = 0x9908b0dfu32

const STATE_VECTOR_LENGTH = 624
const STATE_VECTOR_M = 397

type MTwister* = object
    mt: array[STATE_VECTOR_LENGTH, uint32]
    index: uint32


proc initRand(self: var MTwister, s: uint32): void {.inline.} =
    #[ initialize the generator from a seed ]#
    self.mt[0] = s

    for mti in 1u32..<STATE_VECTOR_LENGTH:
        self.mt[mti] = (1812433253u32 * (self.mt[mti-1] xor (self.mt[mti-1] shr 30u32)) + mti)

    self.index = STATE_VECTOR_LENGTH

proc initSeedRand*(self: var MTwister, initKey: seq[uint32]): void {.inline.} =
    #[ copied init_array from python ]#
    let keyLen = initKey.len

    self.initRand(19650218u32)

    var i = 1
    var j = 0
    var k = (if STATE_VECTOR_LENGTH > keyLen: STATE_VECTOR_LENGTH else: keyLen)

    while k > 0:
        self.mt[i] = (
            self.mt[i] xor (
                (self.mt[i - 1] xor (self.mt[i - 1] shr 30)) * 1664525u32
            )
        ) + initKey[j] + (uint32)j

        inc i
        inc j

        if i >= STATE_VECTOR_LENGTH:
            self.mt[0] = self.mt[STATE_VECTOR_LENGTH-1]
            i = 1

        if j >= keyLen:
            j = 0

        dec k


    k = STATE_VECTOR_LENGTH - 1

    while k > 0:
        self.mt[i] = (
            self.mt[i] xor ((self.mt[i - 1] xor (self.mt[i - 1] shr 30u32)) * 1566083941u32)
        ) - (uint32)i

        inc i

        if i >= STATE_VECTOR_LENGTH:
            self.mt[0] = self.mt[STATE_VECTOR_LENGTH - 1]
            i = 1

        dec k

    self.mt[0] = 0x80000000u32

proc newMTwister*(seed: uint32 = 0): MTwister {.inline.} =
    var rng = MTwister()

    rng.initSeedRand(@[seed])

    return rng

proc newMTwister*(seed: seq[uint32]): MTwister {.inline.} =
    var rng = MTwister()

    rng.initSeedRand(seed)

    return rng


proc extractNumber(self: var MTwister): uint32 {.inline.} =
    var y: uint32
    const mag01 = [0x0u32, MATRIX_A]
    #[ mag01[x] = x * MATRIX_A  for x=0,1 ]#

    if self.index >= STATE_VECTOR_LENGTH: #[ generate N words at one time ]#
        var kk = 0

        while kk < STATE_VECTOR_LENGTH - STATE_VECTOR_M:
            y = (self.mt[kk] and UPPER_MASK) or (self.mt[kk + 1] and LOWER_MASK)
            self.mt[kk] = self.mt[kk + STATE_VECTOR_M] xor (y shr 1) xor mag01[y and 0x1u32]

            inc kk

        while kk < STATE_VECTOR_LENGTH - 1:
            y = (self.mt[kk] and UPPER_MASK) or (self.mt[kk + 1] and LOWER_MASK)
            self.mt[kk] = self.mt[kk + (STATE_VECTOR_M - STATE_VECTOR_LENGTH)] xor (y shr 1) xor mag01[y and 0x1u32]

            inc kk

        y = (self.mt[STATE_VECTOR_LENGTH - 1] and UPPER_MASK) or (self.mt[0] and LOWER_MASK)
        self.mt[STATE_VECTOR_LENGTH-1] = self.mt[STATE_VECTOR_M - 1] xor (y shr 1) xor mag01[y and 0x1u32]

        self.index = 0

    y = self.mt[self.index]

    inc self.index

    y = y xor (y shr 11)
    y = y xor (y shl 7) and TEMPERING_MASK_B
    y = y xor (y shl 15) and TEMPERING_MASK_C
    y = y xor (y shr 18)

    return y

proc getBitsLen(n: int64): uint64 {.inline.} = uint64(log2(float64 n) + 1)
proc getRandBits(self: var MTwister, k: range[0..64]): uint64 {.inline.} =
    if k <= 32:
        return uint64 (self.extractNumber() shr (32 - k))

    let a = uint64 self.extractNumber()
    let b = uint64 self.extractNumber()

    return (a shl 32u64 or b) shr (64 - k)

proc getRandBelowWithBits(self: var MTwister, n: int32 | int64 | int): uint64 =
    if n <= 0:
        return 0

    let k = n.getBitsLen()
    var r = self.getRandBits(k)

    while r >= uint n:
        r = self.getRandBits(k)

    return r

proc getRandBellowWithRange(self: var MTwister, start, stop: int, step = 1): int {.inline.} =
    var iStart = start
    var iStop = stop

    var width = iStop - iStart
    var iStep = step
    var n: int

    if istep > 0:
        n = (width + istep - 1) div istep
    elif istep < 0:
        n = (width + istep + 1) div istep
    else:
        raise newException(ValueError, "zero step for randrange()")
    if n <= 0:
        raise newException(ValueError, "empty range for randrange()")

    return istart + istep * int self.getRandBelowWithBits(n)

proc random*(self: var MTwister): float {.inline.} =
    let ua = self.extractNumber()
    let ub = self.extractNumber()

    let a = float64 (ua shr 5)
    let b = float64 (ub shr 6)

    return (a * 67108864.0 + b) * (1.0 / 9007199254740992.0)

proc random*(self: var MTwister, max: float): float {.inline.} = return self.random() * max
proc randInt*(self: var MTwister, min, max: int): int {.inline.} = self.getRandBellowWithRange(min, max + 1)
proc randInt*(self: var MTwister, max: int): int {.inline.} = self.randInt(0, max + 1)
proc sample*[T](self: var MTwister, arr: openArray[T] | seq[T]): T {.inline.} = arr[self.randInt(0, arr.len-1)]
