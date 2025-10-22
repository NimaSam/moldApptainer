# moldApptainer

## Introduction

This repository provides scripts to create Apptainer (formerly Singularity) containers for our in-house mold-injection solver. The goal is to package the solver and all its requirements into a single container file (`.sif`). This simplifies running simulations across different systems without worrying about dependency conflicts.

## How to Use

### Building the Container

To build the container, you need to define the OpenFOAM version. Supported versions are `OF2412`, `OF2312`, and `foam-extend`. For example:

```bash
./createApptainer.sh OF2412
```


### Running a Simulation

You can use `apptainer run` to execute the container's default runscript, or `apptainer exec` to run specific commands.

Here is a typical command for running a simulation:

```bash
apptainer run -e -c --bind /path/to/your/case:/job solver-master.sif "sh /job/path/inside/case/to/AllrunScript"
```

#### Breakdown of the Command

* **`apptainer run`**: Executes the container's default runscript. (You can also use `apptainer exec` to bypass this and run a command directly).
* **`-e (--cleanenv)`**: Cleans the environment, preventing host variables from "leaking" into the container. This is critical for reproducibility.
* **`-c (--contain)`**: Isolates the container for security and to ensure it doesn't depend on host system files.
* **`--bind /path/to/your/case:/job`**: Mounts your simulation directory from the host (`/path/to/your/case`) to a specific path inside the container (`/job`). This is how the solver accesses your case files.
* **`solver-master.sif`**: The path to your compiled Apptainer container image.
* **`"sh /job/..."`**: The command executed inside the container. Because of the `--bind` flag, `/job` points to your case directory, allowing you to run scripts from it.

