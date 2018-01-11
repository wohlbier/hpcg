#!/bin/bash

# Run this as
# % . ./tau.sh
# the first time to export the papi path.

# Run app as
# % tau numactl -C 0 -- ./xhpcg

rm -rf ./.tau

# Configure your project...
APPNAME=hpcg

# papi built with git checkout of libpfm4
PAPI_ROOT=${HOME}/devel/packages/spack/opt/spack/linux-rhel7-x86_64/gcc-6.1.0/papi-master-ashjfzmpqkbxa6hudklfxji7oybhufb6
export PATH=${PAPI_ROOT}/bin:${PATH}

# initialize tau commander project
tau init --application-name $APPNAME --target-name centennial --mpi \
--papi=${PAPI_ROOT} --tau nightly
#--openmp

tau measurement delete sample
tau measurement copy profile uncore_imc
tau select uncore_imc
tau measurement delete profile

# debugging
#tau measurement edit profile --keep-inst-files

tau application edit hpcg --select-file `pwd`/select.tau

tau measurement edit uncore_imc --source-inst automatic --compiler-inst never \
--metrics \
PAPI_NATIVE:bdx_unc_imc0::UNC_M_CAS_COUNT:RD:cpu=0,\
PAPI_NATIVE:bdx_unc_imc0::UNC_M_CAS_COUNT:WR:cpu=0,\
PAPI_NATIVE:bdx_unc_imc1::UNC_M_CAS_COUNT:RD:cpu=0,\
PAPI_NATIVE:bdx_unc_imc1::UNC_M_CAS_COUNT:WR:cpu=0,\
PAPI_NATIVE:bdx_unc_imc4::UNC_M_CAS_COUNT:RD:cpu=0,\
PAPI_NATIVE:bdx_unc_imc4::UNC_M_CAS_COUNT:WR:cpu=0,\
PAPI_NATIVE:bdx_unc_imc5::UNC_M_CAS_COUNT:RD:cpu=0,\
PAPI_NATIVE:bdx_unc_imc5::UNC_M_CAS_COUNT:WR:cpu=0,\
PAPI_NATIVE:bdx_unc_imc0::UNC_M_CAS_COUNT:RD:cpu=1,\
PAPI_NATIVE:bdx_unc_imc0::UNC_M_CAS_COUNT:WR:cpu=1,\
PAPI_NATIVE:bdx_unc_imc1::UNC_M_CAS_COUNT:RD:cpu=1,\
PAPI_NATIVE:bdx_unc_imc1::UNC_M_CAS_COUNT:WR:cpu=1,\
PAPI_NATIVE:bdx_unc_imc4::UNC_M_CAS_COUNT:RD:cpu=1,\
PAPI_NATIVE:bdx_unc_imc4::UNC_M_CAS_COUNT:WR:cpu=1,\
PAPI_NATIVE:bdx_unc_imc5::UNC_M_CAS_COUNT:RD:cpu=1,\
PAPI_NATIVE:bdx_unc_imc5::UNC_M_CAS_COUNT:WR:cpu=1

# run complains about incompatible papi metrics, but generates results.

# use this in paraprof derived metric for bandwidth
#64*("PAPI_NATIVE:bdx_unc_imc0::UNC_M_CAS_COUNT:RD:cpu=0"+"PAPI_NATIVE:bdx_unc_imc0::UNC_M_CAS_COUNT:WR:cpu=0"+"PAPI_NATIVE:bdx_unc_imc1::UNC_M_CAS_COUNT:RD:cpu=0"+"PAPI_NATIVE:bdx_unc_imc1::UNC_M_CAS_COUNT:WR:cpu=0"+"PAPI_NATIVE:bdx_unc_imc4::UNC_M_CAS_COUNT:RD:cpu=0"+"PAPI_NATIVE:bdx_unc_imc4::UNC_M_CAS_COUNT:WR:cpu=0"+"PAPI_NATIVE:bdx_unc_imc5::UNC_M_CAS_COUNT:RD:cpu=0"+"PAPI_NATIVE:bdx_unc_imc5::UNC_M_CAS_COUNT:WR:cpu=0")/"TIME"

# NB: Using that formula accounts for the magical million that paraprof
# silently puts into the denominator. They are working on a fix for that, and
# when it is fixed one will need to put their own 1e6.


# Set up measurements of stalls to use formulas from Molka, et al.
tau measurement copy uncore_imc mem_bnd_stall_cycs
tau select mem_bnd_stall_cycs
tau measurement edit mem_bnd_stall_cycs \
--metrics \
PAPI_NATIVE:CPU_CLK_UNHALTED,\
PAPI_NATIVE:CYCLE_ACTIVITY:CYCLES_NO_EXECUTE,\
PAPI_NATIVE:RESOURCE_STALLS:SB,\
PAPI_NATIVE:CYCLE_ACTIVITY:STALLS_L1D_PENDING

tau measurement copy uncore_imc bw_lat_stall_cycs
tau select bw_lat_stall_cycs
tau measurement edit bw_lat_stall_cycs \
--metrics \
PAPI_NATIVE:RESOURCE_STALLS:SB,\
PAPI_NATIVE:CYCLE_ACTIVITY:STALLS_L1D_PENDING,\
PAPI_NATIVE:L1D_PEND_MISS:FB_FULL,\
PAPI_NATIVE:OFFCORE_REQUESTS_BUFFER:SQ_FULL

# From Molka, et al.
# Active cycles: 
#         => CPU_CLK_UNHALTED
#   Productive cycles:
#         => CPU_CLK_UNHALTED - CYCLE_ACTIVITY:CYCLES_NO_EXECUTE
#   Stall cycles:
#         => CYCLE_ACTIVITY:CYCLES_NO_EXECUTE
#     Memory bound stall cycles:
#         => max(RESOURCE_STALLS:SB, CYCLE_ACTIVITY:STALLS_L1D_PENDING)
#       Bandwidth bound stall cycles:
#         => max(RESOURCE_STALLS:SB, L1D_PEND_MISS:FB_FULL
#                + OFFCORE_REQUESTS_BUFFER:SQ_FULL)
#       Latency bound stall cycles:
#         => Memory bound cycles - Bandwidth bound cycles
#     Other stall reason cycles:
#         => Stall cycles - Memory bound stall cycles


# OMP_NUM_THREADS=1 tau numactl -C 0 -- ./xhpcg
# CPU_CLK_UNHALTED :   
# CYCLES_NO_EXECUTE:    (% cycles are stalled)
# RESOURCE_STALLS:SB:  
# STALLS_L1D_PENDING:   (% of stalled cycles are memory bound)
# FB_FULL + SQ_FULL:   
# max(SB, FB_FULL + SQ_FULL):  (number of cycles bandwidth bound)
# latency_bound = memory bound - bandwidth bound =


###############################################################################
# tau mpirun -n 400 ./xhpcg
# mean values
# CPU_CLK_UNHALTED :   
# CYCLES_NO_EXECUTE:    (% cycles are stalled)
# RESOURCE_STALLS:SB:  
# STALLS_L1D_PENDING:   (% of stalled cycles are memory bound)
# FB_FULL + SQ_FULL:   
# max(SB, FB_FULL + SQ_FULL):  (number of cycles bandwidth bound)
# latency_bound = memory bound - bandwidth bound =
