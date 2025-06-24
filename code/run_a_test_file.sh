#!/bin/bash

# Usage: ./run_test.sh tb/test_myfeature.sv

TESTBENCH=$1
RTL_DIR=rtl
TB_DIR=tb
RUN_DIR=run_dir
SIM_EXEC=simv

# Validate input
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <testbench_file>"
  exit 1
fi

if [ ! -f "$TESTBENCH" ]; then
  echo "Error: Testbench file '$TESTBENCH' not found!"
  exit 2
fi

# Prepare run directory
rm -rf $RUN_DIR
mkdir -p $RUN_DIR


# Compile inside run_dir
vcs -full64 -sverilog -debug_access+all \
  +incdir+$RTL_DIR +incdir+$TB_DIR \
  +define+UVM_NO_DEPRECATED +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
  $TESTBENCH -o $RUN_DIR/$SIM_EXEC \
  -Mdir=$RUN_DIR/csrc \
  -l $RUN_DIR/compile.log \
  -ntb_opts uvm


# Run the simulation (if compile succeeded)
if [ $? -eq 0 ]; then
  pushd $RUN_DIR > /dev/null
  ./$SIM_EXEC | tee sim.log
  popd > /dev/null
fi

# Optional: Uncomment to delete run_dir after simulation
# rm -rf $RUN_DIR
