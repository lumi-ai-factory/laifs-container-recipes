# emSign CA incident hotfix (2026-10)

Patches released lumi-multitorch images so they no longer trust
`emSign ECC Root CA - G3`
(<https://emudhra.we-have-a-problem.com/#patched-bundles>): Ubuntu's
ca-certificates 20260816ubuntu0.24.04.1 in all images, and pip 26.2.2 and
certifi >= 2026.10.19 in the images with Python packages (torch, full and
plus). In images that have botocore (full and plus), it also upgrades botocore to
1.43.117 or newer, with boto3, as
[AWS security bulletin 2026-150-AWS](https://aws.amazon.com/security/security-bulletins/2026-150-aws/)
advises.

```bash
hotfixes/emsign-ca-2026-10/build-ca-fix [build-tag [image ...]]
```

The defaults patch all images (`rocm`, `libfabric`, `mpich`, `torch`, `full`
and `plus`) of release
`u24r70f21m50t210-20260807_115122`. The images are built from the release's SIF
files on the build host, in `/data/lumi-multitorch-<build-tag>/`; set
`DATA_DIR` to use another directory than `/data`. Like an official release, the patched
images get a new build tag with the same software versions digest and the
timestamp of the build, e.g. `u24r70f21m50t210-20261102_143005`; set `BUILD_ID`
to choose the timestamp. Each image's SIF, build log and SBOM go to
`builds/lumi-multitorch-<hotfix-build-tag>/`. Below, `<tag>` is
`<image>-<build-tag>`.

To list the package changes against the original release's SBOMs in
`/data/lumi-multitorch-<build-tag>/`, as Markdown next to the SIFs:

```bash
hotfixes/emsign-ca-2026-10/diff-ca-fix build-tag hotfix-build-tag [image ...]
```

To do both for the latest affected release of each variant, or for the given
releases, and write the sections of "Patched releases" below to
`builds/emsign-ca-fix-<timestamp>.md`:

```bash
hotfixes/emsign-ca-2026-10/build-all-ca-fix [build-tag ...] [image ...]
```

## Patched releases

<!-- TODO: replace the sections with the ones that build-all-ca-fix prints -->

### u24r72f21m50t211

Not patched: official release `u24r72f21m50t211-20261028_090706` fixes
`u24r72f21m50t211-20260929_104918`, with the same main component versions.

### u24r70f21m50t210

Release `u24r70f21m50t210-<build-id>` patches `u24r70f21m50t210-20260807_115122`.

| SIF file | SHA-256 |
|---|---|
| `lumi-multitorch-rocm-u24r70f21m50t210-<build-id>.sif` | |
| `lumi-multitorch-libfabric-u24r70f21m50t210-<build-id>.sif` | |
| `lumi-multitorch-mpich-u24r70f21m50t210-<build-id>.sif` | |
| `lumi-multitorch-torch-u24r70f21m50t210-<build-id>.sif` | |
| `lumi-multitorch-full-u24r70f21m50t210-<build-id>.sif` | |
| `lumi-multitorch-plus-u24r70f21m50t210-<build-id>.sif` | |

### u24r64f21m43t29

Release `u24r64f21m43t29-<build-id>` patches `u24r64f21m43t29-20260319_153422`.

| SIF file | SHA-256 |
|---|---|
| `lumi-multitorch-rocm-u24r64f21m43t29-<build-id>.sif` | |
| `lumi-multitorch-libfabric-u24r64f21m43t29-<build-id>.sif` | |
| `lumi-multitorch-mpich-u24r64f21m43t29-<build-id>.sif` | |
| `lumi-multitorch-torch-u24r64f21m43t29-<build-id>.sif` | |
| `lumi-multitorch-full-u24r64f21m43t29-<build-id>.sif` | |

### u24r64f21m43t28

Not patched: its only release, pre-release `u24r64f21m43t28-20251128_145346`,
is end of life.
