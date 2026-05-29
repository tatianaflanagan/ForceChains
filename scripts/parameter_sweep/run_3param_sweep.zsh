#!/bin/zsh
# ---------------------------------------------
# run_3param_sweep.zsh
#
# Runs a 3-parameter sweep over:
#   mu       sliding friction
#   muroll   rolling friction
#   mutwist  twisting friction
#
# Usage:
#   chmod +x run_3param_sweep.zsh
#   ./run_3param_sweep.zsh
#
# Optional:
#   LMP_BIN=lmp_mpi ./run_3param_sweep.zsh
# ---------------------------------------------

set -euo pipefail

LMP_BIN="${LMP_BIN:-lmp_serial}"
INPUT_FILE="in.3param_sweep"

mus=(0.1 0.3 0.5 0.7)
murolls=(0.0 0.05 0.1)
mutwists=(0.0 0.05 0.1)

nmu=${#mus[@]}
nmur=${#murolls[@]}
nmut=${#mutwists[@]}
total_runs=$(( nmu * nmur * nmut ))

echo "LAMMPS binary : ${LMP_BIN}"
echo "Input file    : ${INPUT_FILE}"
echo "Total runs    : ${total_runs}"
echo

if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "Error: ${INPUT_FILE} not found in the current directory."
  exit 1
fi

if ! command -v "${LMP_BIN}" >/dev/null 2>&1; then
  echo "Error: could not find '${LMP_BIN}' in PATH."
  exit 1
fi

mkdir -p logs

run_index=0

for mu in "${mus[@]}"; do
  for mur in "${murolls[@]}"; do
    for mut in "${mutwists[@]}"; do
      run_index=$(( run_index + 1 ))

      tag="mu${mu}_mur${mur}_mut${mut}"
      logfile="logs/out_${tag}.txt"

      echo "[$run_index/$total_runs] Running ${tag}"

      start_time=$(date +%s)

      /usr/bin/time -p "${LMP_BIN}"         -var mu "${mu}"         -var muroll "${mur}"         -var mutwist "${mut}"         -in "${INPUT_FILE}"         > "${logfile}" 2>&1

      end_time=$(date +%s)
      elapsed=$(( end_time - start_time ))

      echo "Completed ${tag} in ${elapsed} s"
      echo
    done
  done
done

echo "All runs finished."
echo "Summary file: pileheight_3param.dat"
echo "Logs folder : logs/"
