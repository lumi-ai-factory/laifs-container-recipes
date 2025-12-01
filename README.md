# LUMI AI Factory Container Recipes

**Container recipes and build scripts for LUMI AI Factory container images.**

This repository provides the infrastructure to build, customize, and release container images for the [LUMI AI Factory](https://lumi-ai-factory.eu/). The current images are designed for use on the [LUMI supercomputer](https://lumi-supercomputer.eu/) and will be also published on Docker Hub. The build process has been made as transparent as possible, enabling users to customize images for specific needs or fork the repository for creating images for other systems.

> **Note:** This repository and the images are currently in a **pre-release preview stage**. Official processes and support is planned to begin around **February 2026**. We welcome feedback, issues, and pull requests via [GitHub](https://github.com/lumi-ai-factory/laifs-container-recipes).

---

## Overview

**This repository contains:**

- **Scripts** to render recipes, build images, and generate documentation.
- **Recipes** for building container images, defined as Jinja2 templates and YAML variable files:
  - **Template files** filled using variable files to generate rendered recipes.
  - **Variable files** used to fill the templates and generate rendered recipes.
  - **Document templates** to generate image release documentation from rendered recipes.
- **Containerfile templates** filled and embedded into the rendered recipes.

The workflow is designed to make it easy to update software versions, rebuild images, and generate up-to-date documentation with minimal manual intervention.

---

## Repository Structure

```
.
├── builds/                  # Default build output directory (empty in git)
│   └── <recipe-name>-<build-id>/  # Example output directory, populated during build
├── containerfiles/          # Containerfile templates
│   ├── libfabric/
│   ├── mpich/
│   ├── multi/
│   ├── rocm/
│   └── torch/
├── recipes/                 # Recipe templates and variable files
│   ├── <recipe>-template.yaml
│   ├── <recipe>-vars.yaml
│   └── <recipe>-readme.j2
└── scripts/                 # Build and rendering scripts
    ├── build-images
    ├── build-wrapper
    ├── j2render
    └── render-recipe
```

---

## Key Features

- **Convenience**: Change software versions or build parameters by editing the YAML variable files. The build process regenerates all images and documentation automatically.
- **Transparency**: Every build produces a complete record of the recipe, Containerfiles, logs, and SBOMs.
- **Reproducibility**: The rendered recipe includes all necessary information to rebuild the images.
- **Integration**: Designed for easy integration with CI/CD pipelines for automated building and testing.

---

## Dependencies

The build environment requires:
- **Ubuntu 24.04 LTS**
- **Packages**:
  - `buildah`
  - `jq`
  - `podman`
  - `python3-ruamel.yaml`
  - `singularity-container`
  - `yq`
- **For ARM builds on x86 hosts**:
  - `qemu-user-static`

---

## Usage

### Render a Recipe

Render a recipe from a template and variable file:
```bash
scripts/render-recipe $(date +"%Y%m%d_%H%M%S") \
  recipes/<recipe>-template.yaml \
  recipes/<recipe>-vars.yaml \
  > <recipe>-rendered.yaml
```

### Create a README.md file

Render a README.md file for a recipe build using a rendered recipe file and a documentation template file:
```bash
scripts/j2render recipes/<recipe>-readme.j2 <recipe>-rendered.yaml > <recipe>-readme.md
```

### Build Images

Use the `build-wrapper` script to render, build, and document a recipe:
```bash
scripts/build-wrapper \
  recipes/<recipe>-template.yaml \
  recipes/<recipe>-vars.yaml \
  recipes/<recipe>-readme.j2
```
This is the de-facto way for building a release and will:
- Create a timestamped build directory in `builds/`.
- Render the recipe and documentation.
- Build all images defined in the recipe.
- Generate per-image documentation and SBOM files.

### 3. Build Commands

The `build-images` script can be also used  directly:
```bash
# Dry run: show build commands
scripts/build-images commands builds/<recipe>-<build-id>/<recipe>-<build-id>.yaml

# Build images
scripts/build-images build builds/<recipe>-<build-id>/<recipe>-<build-id>.yaml [target-dir]

# Dump internal representation of a recipe
scripts/build-images dump builds/<recipe>-<build-id>/<recipe>-<build-id>.yaml
```

---

## Outputs

A build produces:
- A **rendered recipe** (`<recipe>-<build-id>.yaml`).
- **Release documentation** (Markdown files).
- **SBOM files** (JSON format) for quick version checks.
- **Build logs** and **Singularity image files** (`.sif`).

All outputs are saved in `builds/<recipe-name>-<build-id>/`.

---

## Contributing

We welcome contributions! Please open an [issue](https://github.com/lumi-ai-factory/laifs-container-recipes/issues) or submit a pull request.

---

## License

This project is licensed under the [MIT License](LICENSE).

