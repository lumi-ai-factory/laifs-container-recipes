# LUMI AI Factory Container Recipes

## Usage

Render a recipe from template and vars file to stdout:
```
$ scripts/j2render recipes/laifs-lumi-multi-recipe-template.yaml recipes/laifs-lumi-multi-recipe-vars.yaml | head
name: laifs-lumi-multi-recipe
steps:
  - name: ubuntu-noble-20250925-rocm-6.4.4
    file: rocm/Ubuntu2404_Rocm6
    force: False
    base: ubuntu:noble-20250925
    env:
      - ROCM_VERSION=6.4.4
      - AMDGPU_VERSION=6.4.4
  - name: ubuntu-noble-20250925-rocm-6.4.4-libfabric-1.22.0
```

Usage for build-image:
```
Usage build-image <build|dump|commands> <recipe file> [<target directory>]
```

Print commands that would be used to create images from a rendered recipe:
```
$ scripts/build-recipe commands builds/laifs-lumi-multi-recipe-20251003_115037/laifs-lumi-multi-recipe-20251003_115037.yaml | head -1
ubuntu-noble-20250925-rocm-6.4.4:20251003_120511: podman build -f containerfiles/rocm/Ubuntu2404_Rocm6 --cgroup-manager cgroupfs -t ubuntu-noble-20250925-rocm-6.4.4:20251003_120511 -t ubuntu-noble-20250925-rocm-6.4.4:latest --build-arg NPROC=8 --build-arg BASE_IMAGE=ubuntu --build-arg BASE_IMAGE_TAG=noble-20250925 --build-arg ROCM_VERSION=6.4.4 --build-arg AMDGPU_VERSION=6.4.4
```

Dump internal representation of each step from a recipe:
```
$ scripts/build-recipe dump builds/laifs-lumi-multi-recipe-20251003_115037/laifs-lumi-multi-recipe-20251003_115037.yaml

Recipe laifs-lumi-multi-recipe from file builds/laifs-lumi-multi-recipe-20251003_115037/laifs-lumi-multi-recipe-20251003_115037.yaml:

  ubuntu-noble-20250925-rocm-6.4.4
    spec: {"name":"ubuntu-noble-20250925-rocm-6.4.4","file":"rocm/Ubuntu2404_Rocm6","force":false,"base":"ubuntu:noble-20250925","env":["ROCM_VERSION=6.4.4","AMDGPU_VERSION=6.4.4"]}
    data:
      FORCE_NEW: false
      BASE_IMAGE_TAG: noble-20250925
      BUILD_COMMAND: podman build -f containerfiles/rocm/Ubuntu2404_Rocm6 --cgroup-manager cgroupfs -t ubuntu-noble-20250925-rocm-6.4.4:20251003_120618 -t ubuntu-noble-20250925-rocm-6.4.4:latest --build-arg NPROC=8 --build-arg BASE_IMAGE=ubuntu --build-arg BASE_IMAGE_TAG=noble-20250925 --build-arg ROCM_VERSION=6.4.4 --build-arg AMDGPU_VERSION=6.4.4
      CONTAINERFILE: rocm/Ubuntu2404_Rocm6
      IMAGE_NAME: ubuntu-noble-20250925-rocm-6.4.4
      BUILD_ENV: ["ROCM_VERSION=6.4.4","AMDGPU_VERSION=6.4.4"]
      EXPORT_IMAGE_NAME: 
      IMAGE_TAG: 20251003_120618
      SKIP_BUILD: true
      BASE_IMAGE: ubuntu
      EXISTING_IMAGE: ubuntu-noble-20250925-rocm-6.4.4:20251002_132141
[...]
```

Build full recipe using `build-wrapper`:
```
scripts/build-wrapper recipes/laifs-lumi-multi-recipe-template.yaml recipes/laifs-lumi-multi-recipe-vars.yaml
```

Build a recipe into selected directory:
```
$ scripts/build-recipe build builds/laifs-lumi-multi-recipe-20251003_115037/laifs-lumi-multi-recipe-20251003_115037.yaml my-tmp-dir
```
