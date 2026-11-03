# Building the emSign CA incident hotfix (2026-10)

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
to choose the timestamp. Each image's SIF, definition file (with the source
image filled in), build log and SBOM go to
`builds/lumi-multitorch-emsign-ca-2026-10-<build-id>/lumi-multitorch-<hotfix-build-tag>/`,
with the checksums of the SIFs in
`lumi-multitorch-<hotfix-build-tag>.sha256`. The build logs also record the
source image's checksum and this repository's commit.

To list the package changes against the original release's SBOMs in
`/data/lumi-multitorch-<build-tag>/`, as `<image-name>-changes.md` next to the
SIFs:

```bash
hotfixes/emsign-ca-2026-10/diff-ca-fix build-tag hotfix-build-tag [image ...]
```

All patched releases are published as one GitHub release,
`lumi-multitorch-emsign-ca-2026-10`. To prepare its assets after building and
diffing the patched releases of a build ID:

```bash
hotfixes/emsign-ca-2026-10/release-ca-fix build-id
```

It finds the patched releases in
`builds/lumi-multitorch-emsign-ca-2026-10-<build-id>/`, reads their original
releases from the build logs, and writes:

- the release notes,
  `builds/lumi-multitorch-emsign-ca-2026-10-<build-id>/lumi-multitorch-emsign-ca-2026-10-<build-id>-release.md`:
  release links, what the hotfix changes, the patched releases with their SIF
  checksums, and the package changes of all images,
- each patched release's directory without the SIFs,
  `builds/lumi-multitorch-emsign-ca-2026-10-<build-id>/lumi-multitorch-<hotfix-build-tag>-release.tgz`.

The release notes are rendered from the Jinja template
[release-notes.md.j2](release-notes.md.j2), which needs `jinja2` from the
repository's [requirements.txt](../../requirements.txt). Edit the template to
change their text.

To build, diff and prepare the release for the latest affected release of each
variant, or for the given releases. All patched releases get the same build ID,
so only one release of each variant can be given:

```bash
hotfixes/emsign-ca-2026-10/build-all-ca-fix [build-tag ...] [image ...]
```
