#!/usr/bin/env python3
from sys import argv
import numpy as np
from typing import IO


def randVector(l: int, dist: str):
    if dist == 'gaussian':
        vec = np.random.normal(loc=5*(10**7), scale=10 **
                               6, size=l).astype(np.uint32)
    elif dist == 'zipfian':
        vec = np.random.zipf(a=2, size=l).astype(np.uint32)
    elif dist == 'exponential':
        vec = np.random.exponential(scale=10**7, size=l).astype(np.uint32)
    elif dist == 'lognormal':
        vec = np.random.lognormal(mean=16, sigma=1.5, size=l).astype(np.uint32)
    elif dist == 'geometric':
        vec = (np.random.geometric(p=0.1, size=l) * 10**6).astype(np.uint32)
    else:  # Default: uniform
        vec = np.random.randint(0, 10**8, l, dtype=np.uint32)
    return np.sort(vec)


def dumpVector(f: IO, arr: np.ndarray):
    length: int = int(arr.size)
    f.write(length.to_bytes(4, "little"))
    f.write(arr.tobytes())


if __name__ == "__main__":
    (cmd, fileName, len1, len2, overlapNum, dist) = argv
    len1, len2, overlapNum = int(len1), int(len2), int(overlapNum)

    a_and_b = randVector(overlapNum, dist)
    a_only = randVector(len1 - overlapNum, dist)
    b_only = randVector(len2 - overlapNum, dist)

    vec_a = np.sort(np.unique(np.concatenate([a_and_b, a_only])))
    vec_b = np.sort(np.unique(np.concatenate([a_and_b, b_only])))
    with open(fileName, "wb") as f:
        dumpVector(f, vec_a)
        dumpVector(f, vec_b)
