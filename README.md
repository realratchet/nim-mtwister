# A Python compliant MTwister implementation

Provides Python's default (MTWister) random number generator implementation with Python compliant seeding.

When Python seeds it's random number generator it converts the given integer value into a series of uint32 arrays, which other MTwister implementations I've found do not account for.

Module can be used as is for regular Nim code as well as with interoperability for Python `requires nimpy` dependency which is not included by default.

## Usage

```nim
import mtwister

var rng = newMTwister(#[ seed ]#)

assert rng.randint(10) == 6
```

## Using Pythons `int` object for seed

```nim
import nimpy
import mtwister
import mtwister/utils

var seedValue = pyBuiltinsModule().int(4294967296 + 42) # 64 bits
var seedArray = pyLongToByteArray(seedValue)
var rng = newMTwister(seedValue)

assert rng.randInt(10) == 9
```

## Features

* rng.randint(max)
* rng.randint(min, max)
* rng.random()
* rng.sample(openArray | seq)
