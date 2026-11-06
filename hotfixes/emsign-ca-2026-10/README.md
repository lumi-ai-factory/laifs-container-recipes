# Old lumi-multitorch containers trust a compromised root certificate

> [!NOTE]
> This is a draft.

All lumi-multitorch images released before **20261028_090706** trust the root certificate **emSign ECC Root CA - G3**. After the eMudhra intermediate CA compromise ([incident page](https://emudhra.we-have-a-problem.com/)), that root must no longer be trusted. The images keep working and nothing has been removed, but their secure connections are less trustworthy than they should be.

## Affected images

All images (rocm, libfabric, mpich, torch, full and, from 20260415_130625 on, plus) of these releases:

| Release | System CA store (`ca-certificates`) | `certifi` | `pip` |
|---|---|---|---|
| u24r64f21m43t28-20251128_145346 (end of life) | 20240203 | 2025.11.12 | 24.0 |
| u24r64f21m43t29-20251209_134408 | 20240203 | 2025.11.12 | 24.0 |
| u24r64f21m43t29-20260124_092648 | 20240203 | 2026.1.4 | 24.0 |
| u24r64f21m43t29-20260216_093549 | 20240203 | 2026.1.4 | 24.0 |
| u24r64f21m43t29-20260225_144743 | 20240203 | 2026.2.25 | 24.0 |
| u24r64f21m43t29-20260319_153422 | 20240203 | 2026.2.25 | 24.0 |
| u24r70f21m50t210-20260415_130625 | 20240203 | 2026.2.25 | 24.0 |
| u24r70f21m50t210-20260513_121430 | 20240203 | 2026.4.22 | 24.0 |
| u24r70f21m50t210-20260731_122833 | 20260601~24.04.1 | 2026.7.22 | 24.0 |
| u24r70f21m50t210-20260807_115122 | 20260601~24.04.1 | 2026.7.22 | 24.0 |
| u24r72f21m50t211-20260929_104918 | 20260601~24.04.1 | 2026.7.22 | 24.0 |

**Fixed in:** `u24r72f21m50t211-20261028_090706`, with `ca-certificates` 20260816ubuntu0.24.04.1, `certifi` 2026.10.23 and `pip` 26.2.2. The earlier variants have patched releases; see [Containers](#containers).

The rocm, libfabric and mpich images have no Python packages, so only their system CA store is affected.

## What the risk is

An image trusts the root in three separate CA stores:

- **The system CA store**, used by `curl`, `wget`, `git` and Python's `ssl` module.
- **`certifi`**, used by `requests`, `huggingface_hub`, `vllm`, `botocore` and many other Python libraries.
- **`pip`'s own bundled copy of `certifi`.**

Anyone holding a certificate issued under the compromised CA could pretend to be any HTTPS server to software in these containers. **To do that, they would also need to be in the network path between LUMI and that server. For a typical job this is unlikely, but the impact would be serious**:

- **Tampered downloads:** packages installed with `pip install`, models and datasets from the Hugging Face Hub, or code fetched with `git clone` could be replaced. A model in pickle format (`.bin`, `.pt`, `.ckpt`) can run arbitrary code when it's loaded.
- **Stolen credentials:** access tokens sent over HTTPS could be read, for example `HF_TOKEN`, Weights & Biases API keys, GitHub tokens and API keys for external model services.
- **Leaked data:** prompts, outputs and training data sent to or from external services could be read or changed.

**Not affected:**

- Work that doesn't connect to the internet, such as training on data already on LUMI's file systems.
- Files whose checksums you verify against a source you trust.

## What to do

### Containers

Switch to the **fixed release** of the variant you use, the release whose images no longer trust the root. For u24r72f21m50t211 it's the official release 20261028_090706. For the earlier variants it's a **patched release**, which we made by patching the variant's latest release. Each fixed release replaces all affected releases of its variant. All releases of a variant have the same Ubuntu, ROCm, libfabric, MPICH and PyTorch versions, so most jobs only need the image path changed, but other packages can be newer than in the earlier releases. The fixed release of each variant, and the releases it replaces, are listed in the [release notes](https://github.com/lumi-ai-factory/laifs-container-recipes/releases/tag/lumi-multitorch-emsign-ca-2026-10#fixed-releases).

The patched releases are built on u24r70f21m50t210-20260807_115122 and u24r64f21m43t29-20260319_153422, with only the fixed CA stores, `pip`, `certifi` and `botocore`, with `boto3`, installed on top. Apart from these, they have the same package versions as the release they're built on.

On LUMI, each release has its own directory, e.g. `/appl/local/laifs/containers/lumi-multitorch-u24r72f21m50t211-20261028_090706/`. See also the [upcoming stable paths](#upcoming-change-stable-paths-on-lumi), which will point to the fixed release of each variant.

Rebuild container images that you have derived from an old image on top of a fixed one.

To check what the software in an image actually trusts, connect to the test hosts listed on the [incident page](https://emudhra.we-have-a-problem.com/), which use certificates issued under the compromised CA. A certificate error means that the software doesn't trust them; a successful connection means that it does:

```bash
# System CA store, used by curl, git and Python's ssl module
singularity exec <image>.sif curl -sS https://dv-g3b-emudhra.we-have-a-problem.com/
singularity exec <image>.sif curl -sS https://dv-g3b-aaa-emudhra.we-have-a-problem.com/

# certifi, used by requests, huggingface_hub and other Python libraries (images that have requests)
singularity exec <image>.sif python -c "import requests; requests.get('https://dv-g3b-emudhra.we-have-a-problem.com/')" 2>&1 | tail -1

# pip, which uses both
singularity exec <image>.sif python -m pip install --retries 0 https://dv-g3b-emudhra.we-have-a-problem.com/
```

In a fixed image, all of these fail with a certificate error (`unable to get local issuer certificate` or `CERTIFICATE_VERIFY_FAILED`). Run the same commands in your virtual environments and in images you have derived from ours. If the `requests` check prints nothing, it connected successfully. `pip` reports `Cannot determine archive format` if it connects successfully, because the test host doesn't serve a package.

If you have to keep an old image for now, pass it a CA bundle that no longer trusts the root, for example the one from the fixed image:

```bash
singularity exec /appl/local/laifs/containers/lumi-multitorch-u24r72f21m50t211-20261028_090706/lumi-multitorch-full-u24r72f21m50t211-20261028_090706.sif \
    cat /etc/ssl/certs/ca-certificates.crt > $HOME/ca-certificates.crt

export SINGULARITYENV_SSL_CERT_FILE=$HOME/ca-certificates.crt
export SINGULARITYENV_REQUESTS_CA_BUNDLE=$HOME/ca-certificates.crt
export SINGULARITYENV_PIP_CERT=$HOME/ca-certificates.crt
export SINGULARITYENV_CURL_CA_BUNDLE=$HOME/ca-certificates.crt
export SINGULARITYENV_GIT_SSL_CAINFO=$HOME/ca-certificates.crt
export SINGULARITYENV_AWS_CA_BUNDLE=$HOME/ca-certificates.crt
```

This covers most tools, but not libraries that load `certifi`'s bundle directly without checking these variables. Moving to the fixed release is the only complete fix.

### Virtual environments

**In short:** in the torch, full and plus images, environments use the image's `pip` and `certifi`, so switching to a fixed image is enough. In other cases, upgrade `certifi` in the environment as shown below, or recreate the environment on a fixed image, with no old `certifi` pinned in its requirements.

The torch, full and plus images put their Python packages in `/opt/venv` on `PYTHONPATH`, which Python searches before the packages of a virtual environment. So a virtual environment used in these images always uses the image's `pip` and `certifi`, even if it has its own copies:

- **Switching to a fixed image fixes them.** You don't need to rebuild or upgrade the environment.
- **Upgrading them in the environment while using an old image has no effect.** `pip` installs the new copies into the environment, but Python keeps using the image's old ones.

To check which copies an environment uses, activate it in the image you use, i.e. the fixed image once you've switched, and run:

```bash
python -c "import certifi, pip; print('certifi', certifi.__version__, certifi.__file__); print('pip', pip.__version__, pip.__file__)"
```

If the printed paths aren't in `/opt/venv`, the environment has its own copies. These are, for example, environments made on the rocm, libfabric or mpich images, which have no `/opt/venv`, or used with `PYTHONPATH` unset. If the environment has no `certifi` of its own, the command fails with `ModuleNotFoundError: No module named 'certifi'`; then only its `pip` matters.

With the environment activated in a fixed image, check which CA bundle its `pip` uses:

```bash
python -c "from pip._vendor import certifi; print(certifi.where())"
```

- **`/etc/ssl/certs/ca-certificates.crt`:** the environment has Ubuntu's `pip`, which uses the image's system CA store, so switching to a fixed image fixes it. Environments made with `python3 -m venv` in the rocm, libfabric and mpich images have this `pip`.
- **A path in the environment:** its `pip` uses its own copy of `certifi`, which stays old even after you switch images and trusts the root. Install the new `pip` from its wheel with the wheel's SHA-256 hash, which `pip` checks:

  ```bash
  python -m pip install "pip @ https://files.pythonhosted.org/packages/3f/06/3e4420302363fbb71be3c7f35ce042f54bfca330e3e66b3a2e3c4cca579f/pip-26.2.2-py3-none-any.whl#sha256=fd7f4dfa8190e014013b9f08f3e973f4e4c26ffd179a204895533a7254813a70"
  ```

A `certifi` of the environment's own stays old even after you switch images. Once its `pip` is fixed, upgrade it normally:

```bash
python -m pip install --upgrade "certifi>=2026.10.19"
```

The same applies to packages installed with `pip install --user`, which only Ubuntu's `python3` allows, with `--break-system-packages`. In the torch, full and plus images, `/opt/venv` comes before them, so the image's copies are used. In the rocm, libfabric and mpich images, or with `PYTHONPATH` unset, a `certifi` installed with `--user` is used and stays old. Ubuntu's `pip` uses the system CA store, so with a fixed image you can upgrade it directly:

```bash
python3 -m pip install --user --break-system-packages --upgrade "certifi>=2026.10.19"
```

> [!NOTE]
> When you upgrade an environment's own copies, upgrading `pip` is not enough if the environment runs on an old image: `pip` 24.2 and later also trust the system CA store of that image, which contains the root ([pip documentation](https://pip.pypa.io/en/stable/topics/https-certificates/)).

### Tokens and downloads

1. **Rotate tokens that old images used.** Do this if you used tokens over the network from an old image, especially where traffic left LUMI through networks you don't control. This is a precaution; we aren't aware of any misuse.
2. **Prefer `safetensors` model files**, and pin Hugging Face downloads to a specific commit (`revision=`).

## Upcoming change: stable paths on LUMI

We'll add a stable path for each variant, which points to its latest fixed release, and `latest`, which points to the newest variant:

```text
/appl/local/laifs/containers/lumi-multitorch/<variant>/<image>.sif
/appl/local/laifs/containers/lumi-multitorch/latest/<image>.sif
```

where `<image>` is `rocm`, `libfabric`, `mpich`, `torch`, `full` or `plus`, for example `/appl/local/laifs/containers/lumi-multitorch/u24r72f21m50t211/full.sif`. Once they're in place, use these paths to get future fixes without changing your job scripts. To see which release a path points to:

```bash
readlink -f /appl/local/laifs/containers/lumi-multitorch/u24r72f21m50t211/full.sif
```

The release directories stay as they are. If you need an exact release for reproducibility, keep using its directory.

## More information

- [eMudhra incident page](https://emudhra.we-have-a-problem.com/), with the patched versions of CA bundles and libraries
- [Information for Python users regarding the eMudhra emSign CA certificate security incident](https://discuss.python.org/t/information-for-python-users-regarding-emudhra-emsign-ca-certificate-security-incident/109576) (Python Discourse)
- [eMudhra CA compromise: fixes available](https://ubuntu.com/blog/emudhra-ca-compromise-fixes-available) (Ubuntu blog)
- [AWS security bulletin 2026-150-AWS](https://aws.amazon.com/security/security-bulletins/2026-150-aws/) (`botocore`)
- [HTTPS certificates](https://pip.pypa.io/en/stable/topics/https-certificates/) (pip documentation), on which CA stores `pip` trusts

