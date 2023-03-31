#!/bin/bash

# Function to convert numbers to human-readable format
to_human_readable() {
    local value=$1
    if ((value >= 1000000)); then
        if ((value % 1000000 == 0)); then
            printf "%dM" $((value / 1000000))
        else
            printf "%.1fM" $(echo "scale=1; $value / 1000000" | bc)
        fi
    elif ((value >= 1000)); then
        if ((value % 1000 == 0)); then
            printf "%dK" $((value / 1000))
        else
            printf "%.1fK" $(echo "scale=1; $value / 1000" | bc)
        fi
    elif ((value != value / 1)); then # check if value is not an integer
        printf "%.1f" $value
    else
        printf "%d" $value
    fi
}

source step04_setupEnvs.sh

SCALAR_REPEAT=5 # the number of repeats executions for scalar (baseline) to take
SIMD_REPEAT=5 # the number of repeats executions for simd (proposed) to take
SIMD_WIDTH=64

cd /root/basicProblemExplore/

# Define the number of steps
num_steps=4
overlap_values=(0 10 50 100 200 500 1000 2500 5000 10000)

# Define the initial values
max_value=10000
initial_a=max_value
initial_b=max_value

# Calculate the step size for each iteration
step_size=$(( max_value / num_steps ))

for ((i=0; i<=num_steps; i++)); do
    a=$(( initial_a + (step_size * i) ))
    b=$(( 20000 - a ))  # Make sure a + b = 20000
    b=$(( b == 0 ? 1 : b ))  # Ensure b is not 0, and a + b can be 20001 if b is 1

    # Generate human-readable file names
    a_readable=$(to_human_readable $a)
    b_readable=$(to_human_readable $b)

    for overlap in "${overlap_values[@]}"; do
        if (( overlap > ((a < b) ? a : b) )); then
            break
        fi
        overlap_readable=$(to_human_readable $overlap)

        # Generate the merge file
        cd SetOperation
        python generateMerge.py "${a_readable}_${b_readable}_${overlap_readable}.bin" $a $b $overlap
        cd ..

        # Run the simulation
        (time python gem5ArmRunner.py ${SIMD_WIDTH} SetOperation file SetOperation/"${a_readable}_${b_readable}_${overlap_readable}.bin" scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/setop-${a_readable}_${b_readable}_${overlap_readable}-${SIMD_WIDTH}.log"
    done
done