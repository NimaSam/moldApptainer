#!/bin/bash

git clone https://github.com/FoamScience/openfoam-apptainer-packaging.git  myTmp
git clone git@bitbucket.org:hmarschall/pucoupledinterdymfoam.git ../solver

#install required packages to build apptainer, you need to have root access
#sudo apt install -y apptainer python3.10 python3.10-venv 

#create virtual environment
python3.10 -m venv myTmp/venv

#activate virtual environment
source myTmp/venv/bin/activate

#install required packages
python -m pip install ansible


#build apptainer container
cp -r defs/foam-extend-5.def myTmp/basic/foam-extend-5.def
ansible-playbook myTmp/build.yaml --extra-vars "original_dir=$PWD" --extra-vars "@config.yaml"


#test
#apptainer shell -C containers/projects/solver-master.sif
#which blockUCoupledIMFoam
#apptainer run containers/projects/solver-master.sif solids4Foam

