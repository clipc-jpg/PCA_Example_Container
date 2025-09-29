# PCA_Example

This repository contains a minimal example that is used for documentation.
It shows how a small script may get containerized, so that it interoperates with ColonyLauncher.

## Build Process

The build process is straightforward, and only consists of the containerization step.

```
sudo singularity build run_pca_script.sif run_pca_script.def
```

## License
This project is MIT licensed

## Project status
The project is complete, and is subject of the tutorial at Colony's project page at [Colony Website](https://clipc-jpg.github.io/ColonyWebsite/).
Please have a look at the developer's section, section 3 "Creating a minimal Example container".
