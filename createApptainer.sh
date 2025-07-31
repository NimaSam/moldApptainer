#!/bin/bash

set -e

# -------- CONFIG --------
TMP_DIR="tmp"
VENV_DIR="$TMP_DIR/venv"
PACKAGING_REPO="https://github.com/FoamScience/openfoam-apptainer-packaging.git"
SOLVER_REPO="git@bitbucket.org:hmarschall/pucoupledinterdymfoam.git"
SOLIDS_REPO="git@bitbucket.org:hmarschall/solids4foamlib.git"
# ------------------------

# -------- FUNCTIONS --------

print_usage() {
  echo "Usage: $0 [OF2312 | foam-extend]"
  exit 1
}

setup_common() {
  rm -rf "$TMP_DIR"
  mkdir -p "$TMP_DIR"

  echo "[INFO] Cloning packaging repo..."
  git clone "$PACKAGING_REPO" "$TMP_DIR/apptainer"

  echo "[INFO] Setting up Python virtual environment..."
  python3.10 -m venv "$VENV_DIR"
  source "$VENV_DIR/bin/activate"
  python -m pip install ansible
}

build_container() {
  cp "$1" "$TMP_DIR/apptainer/basic/$(basename "$1")"
  ansible-playbook "$TMP_DIR/apptainer/build.yaml" --extra-vars "original_dir=$PWD" --extra-vars "@config.yaml"
}

build_OF2312() {
  echo "[INFO] Building for OpenFOAM 2312..."

  git clone --branch feature-esi --single-branch "$SOLVER_REPO" "$TMP_DIR/solver"
  git clone --branch feature-moldInjection --single-branch "$SOLIDS_REPO" "$TMP_DIR/solids4Foam"

  rm -rf "$TMP_DIR/solver/thirdParty" "$TMP_DIR/solver/run"
  rm -rf "$TMP_DIR/solids4Foam/tutorials"
  cp -r config-openfoam-2312.yaml config.yaml 

  build_container defs/com-openfoam.def
}

build_foam_extend() {
  echo "[INFO] Building for foam-extend..."

  git clone "$SOLVER_REPO" "$TMP_DIR/solver"
  cp -r config-foam-extend-5.yaml config.yaml
  build_container defs/foam-extend-5.def
}

# -------- MAIN --------

if [[ $# -ne 1 ]]; then
  print_usage
fi

VERSION="$1"
setup_common

case "$VERSION" in
  OF2312)
    build_OF2312
    ;;
  foam-extend)
    build_foam_extend
    ;;
  *)
    echo "[ERROR] Unknown version: $VERSION"
    print_usage
    ;;
esac

echo "[DONE] You can now run:"
echo "  apptainer shell -C containers/projects/solver-master.sif"
echo "  which blockUCoupledIMFoam or IMFoam"
echo "  apptainer run containers/projects/solver-master.sif solids4Foam"
