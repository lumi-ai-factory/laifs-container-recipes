# Old lumi-multitorch containers trust a compromised root certificate

> [!NOTE]
> This is a draft.

All lumi-multitorch images released before **20261028_090706**, and the older image `laifs-lumi-multi-20250728_103251.sif`, trust the root certificate **emSign ECC Root CA - G3**. After the eMudhra intermediate CA compromise ([incident page](https://emudhra.we-have-a-problem.com/)), that root must no longer be trusted. The images keep working and nothing has been removed, but their secure connections are less trustworthy than they should be.

## Affected images

All images (rocm, libfabric, mpich, torch, full and, from u24r70f21m50t210-20260415_130625 on, plus) of all releases of the variants u24r64f21m43t28, u24r64f21m43t29 and u24r70f21m50t210, and of u24r72f21m50t211-20260929_104918. Also affected is `laifs-lumi-multi-20250728_103251.sif`, an image from before lumi-multitorch.

<details>
<summary>Affected releases and the versions of their CA stores</summary>

| Release | System CA store (`ca-certificates`) | `certifi` | `pip` |
|---|---|---|---|
| laifs-lumi-multi-20250728_103251 (end of life) | 20240203 | 2025.7.14 | 24.0 |
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

</details>

**Fixed in:** `u24r72f21m50t211-20261028_090706`, with `ca-certificates` 20260816ubuntu0.24.04.1, `certifi` 2026.10.23 and `pip` 26.2.2. The earlier variants have patched releases; see [Containers](#containers).

The rocm, libfabric and mpich images have only Ubuntu's Python and `pip`, which use the system CA store, so only their system CA store is affected.

## What the risk is

An image trusts the root in three separate CA stores:

- **The system CA store**, used by `curl`, `wget`, `git` and Python's `ssl` module.
- **`certifi`**, used by `requests`, `huggingface_hub`, `vllm`, `botocore` and many other Python libraries.
- **`pip`'s own bundled copy of `certifi`.**

Anyone who can get certificates issued under the compromised CA could pretend to be any HTTPS server to software in these containers. **To do that, they would also need to be in the network path between LUMI and that server. For a typical job this is unlikely, but the impact would be serious**:

- **Tampered downloads:** packages installed with `pip install`, models and datasets from the Hugging Face Hub, or code fetched with `git clone` could be replaced. A model in pickle format (`.bin`, `.pt`, `.ckpt`) can run arbitrary code when it's loaded.
- **Stolen credentials:** access tokens sent over HTTPS could be read, for example `HF_TOKEN`, Weights & Biases API keys, GitHub tokens and API keys for external model services.
- **Leaked data:** prompts, outputs and training data sent to or from external services could be read or changed.

**Not affected:**

- Work that doesn't connect to the internet, such as training on data already on LUMI's file systems.
- Files whose checksums you verify against a source you trust.

## What to do

### Containers

Switch to the **fixed release** of your variant: the official release [u24r72f21m50t211-20261028_090706](https://github.com/lumi-ai-factory/laifs-container-recipes/releases/tag/lumi-multitorch-u24r72f21m50t211-20261028_090706) for u24r72f21m50t211, and for the earlier variants a **patched release**, which is the variant's latest release with the fix on top. A fixed release has the same Ubuntu, ROCm, libfabric, MPICH and PyTorch versions as the releases it replaces, so most jobs only need the image path changed. Other packages, e.g. vLLM and transformers, are those of the variant's latest release, so they can be newer than in your release. The [release notes](https://github.com/lumi-ai-factory/laifs-container-recipes/releases/tag/lumi-multitorch-emsign-ca-2026-10) list the fixed release of each variant, the releases it replaces, and the checksums and package changes of the patched releases.

**End of life:** u24r64f21m43t28 and `laifs-lumi-multi-20250728_103251.sif` get no fixed release. Move to a supported variant, e.g. the full image of u24r72f21m50t211-20261028_090706. Other packages, and the ROCm and PyTorch versions, can differ from the old image, so check that your jobs work with it.

On LUMI, each release has its own directory, e.g. `/appl/local/laifs/containers/lumi-multitorch-u24r72f21m50t211-20261028_090706/`. `/appl/local/laifs/containers/lumi-multitorch-latest.sif` already points to the full image of the fixed release u24r72f21m50t211-20261028_090706.

Rebuild container images that you have derived from an old image on top of a fixed one.

<details>
<summary>Check what an image trusts</summary>

To check what the software in an image actually trusts, connect to the test hosts listed on the [incident page](https://emudhra.we-have-a-problem.com/), which use certificates issued under the compromised CA. A certificate error means that the software doesn't trust them; a successful connection means that it does:

```bash
# System CA store, used by curl, git and Python's ssl module
singularity exec <image>.sif curl -sS https://dv-g3b-emudhra.we-have-a-problem.com/
singularity exec <image>.sif curl -sS https://dv-g3b-aaa-emudhra.we-have-a-problem.com/

# certifi, used by requests, huggingface_hub and other Python libraries (images that have requests)
singularity exec <image>.sif python3 -c "import requests; requests.get('https://dv-g3b-emudhra.we-have-a-problem.com/')" 2>&1 | tail -1

# pip, which uses both
singularity exec <image>.sif python3 -m pip install --retries 0 https://dv-g3b-emudhra.we-have-a-problem.com/
```

In a fixed image, all of these fail with a certificate error (`unable to get local issuer certificate` or `CERTIFICATE_VERIFY_FAILED`). Run the same commands in your virtual environments and in images you have derived from ours. If the `requests` check prints nothing, it connected successfully. `pip` reports `Cannot determine archive format` if it connects successfully, because the test host doesn't serve a package.

</details>

<details>
<summary>Keep using an old image for now</summary>

If you have to keep an old image for now, pass it a CA bundle that no longer trusts the root, for example the one from the fixed image, and an empty certificate directory in place of the image's own:

```bash
singularity exec /appl/local/laifs/containers/lumi-multitorch-u24r72f21m50t211-20261028_090706/lumi-multitorch-full-u24r72f21m50t211-20261028_090706.sif \
    cat /etc/ssl/certs/ca-certificates.crt > $HOME/ca-certificates.crt
mkdir -p $HOME/empty-ca-dir

export SINGULARITYENV_SSL_CERT_FILE=$HOME/ca-certificates.crt
export SINGULARITYENV_SSL_CERT_DIR=$HOME/empty-ca-dir
export SINGULARITYENV_REQUESTS_CA_BUNDLE=$HOME/ca-certificates.crt
export SINGULARITYENV_PIP_CERT=$HOME/ca-certificates.crt
export SINGULARITYENV_GIT_SSL_CAINFO=$HOME/ca-certificates.crt
export SINGULARITYENV_GIT_SSL_CAPATH=$HOME/empty-ca-dir
export SINGULARITYENV_AWS_CA_BUNDLE=$HOME/ca-certificates.crt
```

This covers most tools, but not libraries that load `certifi`'s bundle directly without checking these variables. Moving to the fixed release is the only complete fix.

</details>

### Virtual environments

**In short:** virtual environments that you make on top of the image's Python and run in the torch, full and plus images use the image's `pip` and `certifi`, however they were made, so switching to a fixed image is enough. In other cases, the easiest and safest fix is to **recreate the environment on a fixed image**, with no old `certifi` pinned in its requirements.

Upgrading an environment in place is a worse option, only for environments you can't recreate: it takes more steps, depends on what the environment has, and is easy to leave half done.

<details>
<summary>Check and upgrade an environment in place</summary>

This matters in the rocm, libfabric and mpich images, or in any image with `PYTHONPATH` unset. Do it in the fixed image: `pip` 24.2 and later also trust the system CA store of the image, and an old image's store contains the root ([pip documentation](https://pip.pypa.io/en/stable/topics/https-certificates/)). Activate the environment, if you use one, and run:

```bash
python3 -c "import pip; from pip._vendor import certifi; print('pip', pip.__file__, certifi.where())"
python3 -c "import certifi; print('certifi', certifi.__file__)"
```

Then do everything that applies:

| The check prints | What to do |
|---|---|
| Paths in `/opt/venv` | Nothing: these are the image's copies, which come first on `PYTHONPATH` |
| `pip` with `/etc/ssl/certs/ca-certificates.crt` | Nothing: Ubuntu's `pip`, from `python3 -m venv`, uses the system CA store |
| `pip` with a path in the environment | Its own `pip`, with an old copy of `certifi`: upgrade it (1) |
| `certifi` with a path in the environment | Its own `certifi`: upgrade it (2), after `pip` |
| `certifi` in `~/.local` | Installed with `pip install --user`: upgrade it (3) |
| `No module named 'certifi'` | Nothing: the environment has no `certifi` of its own |

1. Install the new `pip` from its wheel, whose SHA-256 hash `pip` checks:

   ```bash
   python3 -m pip install "pip @ https://files.pythonhosted.org/packages/3f/06/3e4420302363fbb71be3c7f35ce042f54bfca330e3e66b3a2e3c4cca579f/pip-26.2.2-py3-none-any.whl#sha256=fd7f4dfa8190e014013b9f08f3e973f4e4c26ffd179a204895533a7254813a70"
   ```

2. Upgrade the environment's `certifi`:

   ```bash
   python3 -m pip install --upgrade "certifi>=2026.10.19"
   ```

3. Upgrade a `certifi` installed with `--user`, which only Ubuntu's `python3` allows:

   ```bash
   python3 -m pip install --user --break-system-packages --upgrade "certifi>=2026.10.19"
   ```

</details>

### Tokens and downloads

1. **Rotate tokens that old images used.** Do this if you used tokens over the network from an old image, especially where traffic left LUMI through networks you don't control. This is a precaution; we aren't aware of any misuse.
2. **Prefer `safetensors` model files**, and pin Hugging Face downloads to a specific commit (`revision=`).

## More information

- [eMudhra incident page](https://emudhra.we-have-a-problem.com/), with the patched versions of CA bundles and libraries
- [Information for Python users regarding the eMudhra emSign CA certificate security incident](https://discuss.python.org/t/information-for-python-users-regarding-emudhra-emsign-ca-certificate-security-incident/109576) (Python Discourse)
- [eMudhra CA compromise: fixes available](https://ubuntu.com/blog/emudhra-ca-compromise-fixes-available) (Ubuntu blog)
- [AWS security bulletin 2026-150-AWS](https://aws.amazon.com/security/security-bulletins/2026-150-aws/) (`botocore`)
- [HTTPS certificates](https://pip.pypa.io/en/stable/topics/https-certificates/) (pip documentation), on which CA stores `pip` trusts

