#!/bin/bash

source step04_setupEnvs.sh

SCALAR_REPEAT=5 # the number of repeats executions for scalar (baseline) to take
SIMD_REPEAT=5 # the number of repeats executions for simd (proposed) to take
SIMD_WIDTH=64
DISTRIBUTIONS=("uniform" "gaussian" "zipfian" "exponential" "lognormal" "geometric")

cd /root/basicProblemExplore/

# Set the sizes and overlap
a_size=10000
b_size=10000
overlap=5000

# Run the simulation for each distribution
for dist in "${DISTRIBUTIONS[@]}"; do
    for ((run=1; run<=25; run++)); do
        echo "######## Run: ${run}/25 ########"

        # Generate the merge file
        cd SetOperation
        python generateMergeDists.py "${dist}_${run}.bin" $a_size $b_size $overlap $dist
        cd ..

        # Run the simulation
        (time python gem5ArmRunner.py ${SIMD_WIDTH} SetOperation file SetOperation/"${dist}_${run}.bin" scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/setop-${dist}_${run}-${SIMD_WIDTH}.log"
    done
done