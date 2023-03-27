#!/bin/bash

bash step03_generateData.sh
source step04_setupEnvs.sh

SCALAR_REPEAT=5 # the number of repeats executions for scalar (baseline) to take
SIMD_REPEAT=5 # the number of repeats executions for simd (proposed) to take

cd /root/basicProblemExplore/

for SIMD_WIDTH in 4 8 16 32 64
do
    (time python gem5ArmRunner.py ${SIMD_WIDTH} SetOperation file SetOperation/10000_o_5000.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/setop-${SIMD_WIDTH}.log"
    (time python gem5ArmRunner.py ${SIMD_WIDTH} JoinOp file JoinOp/10000_o_5000.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/joinop-${SIMD_WIDTH}.log"

    ## (6 kernels here) {vector/matrix/tensor} addition and element-wise multiplication on real numbers
    (time python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin Add Mul file ComplexJoin/vector_real.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/join-addmul-vector-${SIMD_WIDTH}.log"
    (time python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin Add Mul file ComplexJoin/matrix_real.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/join-addmul-matrix-${SIMD_WIDTH}.log"
    (time python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin Add Mul file ComplexJoin/tensor_real.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/join-addmul-tensor-${SIMD_WIDTH}.log"

    ## (3 kernels here) {vector/matrix/tensor} element-wise multiplication on complex numbers
    (time python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin MulComplex file ComplexJoin/vector_complex.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/join-mulcomplex-vector-${SIMD_WIDTH}.log"
    (time python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin MulComplex file ComplexJoin/matrix_complex.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/join-mulcomplex-matrix-${SIMD_WIDTH}.log"
    (time python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin MulComplex file ComplexJoin/tensor_complex.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/join-mulcomplex-tensor-${SIMD_WIDTH}.log"

    ## (1 kernel here) A merge operation in shortest path
    (time python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin ShortestPath file ComplexJoin/vector_real.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/join-shortestpath-tensor-${SIMD_WIDTH}.log"

    (time python gem5ArmRunner.py ${SIMD_WIDTH} Sort scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/sort-${SIMD_WIDTH}.log"
    (time python gem5ArmRunner.py ${SIMD_WIDTH} SortKV scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}) 2>&1 | tee "/results/sortkv-${SIMD_WIDTH}.log"

    SCALAR_REPEAT=0
done

cd /root/SpMMBenchmarks

SCALAR_REPEAT=5
SIMD_WIDTH=4

(time python ./Workflow/middleExpand.py execGem5Parallel all vecLen=${SIMD_WIDTH} scalar=${SCALAR_REPEAT} simd=${SIMD_REPEAT}) 2>&1 | tee "/results/spmm-${SIMD_WIDTH}.log"
(time python ./Workflow/middleExpand.py report all | tee "/results/spmm-report-${SIMD_WIDTH}.log"

for SIMD_WIDTH in 8 16 32 64
do
    (time python ./Workflow/middleExpand.py execGem5Parallel ProposedSIMD vecLen=${SIMD_WIDTH} scalar=${SCALAR_REPEAT} simd=${SIMD_REPEAT}) 2>&1 | tee "/results/spmm-${SIMD_WIDTH}.log"
    (time python ./Workflow/middleExpand.py report ProposedSIMD | tee "/results/spmm-report-${SIMD_WIDTH}.log"
done

mkdir /results/spmm
cp -r csvResults/ /results/spmm/
cp -r worksload/ /results/spmm/
