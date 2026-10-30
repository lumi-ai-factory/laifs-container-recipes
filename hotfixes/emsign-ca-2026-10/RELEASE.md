# emSign CA incident hotfix (2026-10)

Patches released lumi-multitorch images so they no longer trust
`emSign ECC Root CA - G3`
(<https://emudhra.we-have-a-problem.com/#patched-bundles>): pip 26.2.2,
certifi >= 2026.10.19 and Ubuntu's ca-certificates 20260816ubuntu0.24.04.1.

```bash
hotfixes/emsign-ca-2026-10/build-ca-fix [build-tag [image ...]]
```

The defaults patch the `torch`, `full` and `plus` images of release
`u24r72f21m50t211-20260929_104918`. Each image's SIF, build log and SBOM go to
`builds/lumi-multitorch-<build-tag>/hotfixes/`. Below, `<tag>` is
`<image>-<build-tag>`.

To list the package changes against the release's SBOMs in
`releases/lumi-multitorch-<build-tag>/`, as `<name>-ca-fix.md` next to the SIFs:

```bash
hotfixes/emsign-ca-2026-10/diff-ca-fix [build-tag [image ...]]
```

If the release's SBOM isn't in `releases/`, get it from the image:

```bash
singularity exec docker://docker.io/lumiaifactory/lumi-multitorch:<tag> \
    cat /.sbom.json > releases/lumi-multitorch-<build-tag>/lumi-multitorch-<tag>.json
```

## Patched releases

| Release tag | SIF SHA-256 |
|---|---|
| `torch-u24r72f21m50t211-20260929_104918` | `a33c53dccbe499d7b3c93e36b6c47b6045e8d1aecfac4c33617628c54432739d` |
| `full-u24r72f21m50t211-20260929_104918` | `df1c381c50bf12d27263f9c63e2c36ceefdc2af6a20ea39c32fa2bb4aa6b5389` |
| `plus-u24r72f21m50t211-20260929_104918` | `a16c86949f7b364ae11b20fccffb0eb93f725bdacfc9a5c2e22798c97c24e354` |
| `torch-u24r70f21m50t210-20260807_115122` | `22c36d303d5877c7b3d964d1773121181534b4a61fe663710174f89351ff2fcb` |
| `full-u24r70f21m50t210-20260807_115122` | `42ae15180a38b1e9b183343e76180adaa6a7057460e1f29bc3a8d855eb2e2ec9` |
| `plus-u24r70f21m50t210-20260807_115122` | `6a2f6ec0592fe27d52bb3c93005ab02adff333023b669bc450d6ef2a6a4a614d` |
| `torch-u24r70f21m50t210-20260513_121430` | `39d5f2345d7e63611d780287260865773fb5b437437af7842093a62ad5713ae1` |
| `full-u24r70f21m50t210-20260513_121430` | `9460ccfaf92dbfc3679b23c881fcf94c6176a8d20e80a157bc6b7f27d02c3e32` |
| `plus-u24r70f21m50t210-20260513_121430` | `4e2d0e4ee61dc9a86aaf0b0ac7a59231469774fe3f89e3f5c0c2ce76a62227d8` |
| `torch-u24r70f21m50t210-20260415_130625` | `0562432ee8ef36d1693b660abb5bb3386d5708067ca4765da35d2096db900f2d` |
| `full-u24r70f21m50t210-20260415_130625` | `ed5665b0e57b3c6f7e9ccaf03544dd5d1894f599a4713ef6cb6a7b2dcf0f4bc6` |
| `plus-u24r70f21m50t210-20260415_130625` | `15651a6e21cbec972dd21c89291f3961a5ac3bef1b838377ac5ceb7d11c3838c` |
