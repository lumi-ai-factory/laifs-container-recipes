# Security policy

> [!NOTE]
> This is a draft, based on how the emSign CA incident was handled
> ([hotfixes/emsign-ca-2026-10/](hotfixes/emsign-ca-2026-10/)). The points
> marked **Open** are undecided.

This policy covers the container images built from this repository, such as
lumi-multitorch, and the recipes and scripts that build them.

## Supported releases

Each lumi-multitorch variant is identified by its software versions digest,
such as `u24r72f21m50t211`. Security fixes are made for the **latest release of
each supported variant**. A fix replaces all affected releases of its variant.

- **The newest variant** gets its fixes in a new official release, or in a
  patched release.
- **Earlier variants** get **patched releases on a best-effort basis**: when
  the fix can be applied to their latest release without rebuilding it, such
  as by upgrading a few packages. If it can't, the fix is only available in
  the newest variant, and you need to move to it.
- **Variants that are end of life** get no fixes.

| Variant | Security fixes |
|---|---|
| u24r72f21m50t211 | Yes |
| u24r70f21m50t210 | Best effort, patched releases |
| u24r64f21m43t29 | Best effort, patched releases |
| u24r64f21m43t28 | No, end of life |

## Reporting a vulnerability

Don't report vulnerabilities in public issues. Report them privately:

- **Open:** the reporting channel, e.g. GitHub's
  [private vulnerability reporting](https://github.com/lumi-ai-factory/laifs-container-recipes/security/advisories/new)
  or a security contact address.

Include the affected images or release names, e.g.
`lumi-multitorch-full-u24r70f21m50t210-20260807_115122.sif`, what is
vulnerable, and how to reproduce it, if you can.

Report elsewhere:

- **Vulnerabilities in software that the images include**, such as PyTorch or
  Python packages: report them to that project. Tell us if our images need an
  update, for example when a fixed version is released.
- **Problems with the LUMI system itself:** report them to
  [LUMI user support](https://lumi-supercomputer.eu/user-support/need-help/).

**Open:** response times.

## How vulnerabilities are fixed

1. **Assess** which releases are affected, and how serious the issue is for
   their users.
2. **Fix** the latest release of each supported variant, in one of two ways:
   - **Official release:** a new release built from the recipes, when the fix
     needs rebuilt images. Only the newest variant gets official releases.
   - **Hotfix:** when the fix is small and self-contained, such as upgrading a
     few packages, the latest release of each variant is patched, on a
     best-effort basis for the earlier variants. The **patched release** is a
     new release of its variant, with only the fix on top. See
     [hotfixes/README.md](hotfixes/README.md).
3. **Publish:**
   - **Notice for users**, in `hotfixes/<incident>/README.md`: the affected
     releases, the risk, what to do, and the fixed release of each variant.
   - **GitHub release** for a hotfix, `lumi-multitorch-<incident>`, with the
     SIF checksums and package changes of all patched releases.
   - **Images on LUMI**, in `/appl/local/laifs/containers/`.

The original releases aren't changed or removed, so their names and checksums
stay valid for reproducibility. On LUMI, their directories get a `PATCHED.md`
that points to the fixed release.

## Using the images securely

- **Use the fixed release of your variant.** On LUMI, the stable paths
  `/appl/local/laifs/containers/lumi-multitorch/<variant>/<image>.sif` will
  point to the latest fixed release of each variant.
- **Rebuild images that you have derived from ours** on top of a fixed one.
  Virtual environments with their own copies of affected packages may need
  upgrading too; the notice says how.
- **Verify the images** against their SHA-256 checksums, which are in the
  build logs of each release, and for a hotfix also in its release notes.
  Each image lists its packages in `/.sbom.json`, so you can check whether it
  has an affected version:

  ```bash
  singularity exec <image>.sif cat /.sbom.json
  ```
