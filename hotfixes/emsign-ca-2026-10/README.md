# Old lumi-multitorch containers trust a compromised root certificate

All lumi-multitorch images released before **20261028_090706** still trust the root certificate **emSign ECC Root CA - G3**. After the eMudhra intermediate CA compromise ([incident page](https://emudhra.we-have-a-problem.com/)), that root must no longer be trusted. The images keep working and nothing has been removed, but their secure connections are less trustworthy than they should be.

## Affected images

All images (rocm, libfabric, mpich, torch, full and plus) of these releases:

| Release | System CA store (`ca-certificates`) | `certifi` | `pip` |
|---|---|---|---|
| u24r70f21m50t210-20260415_130625 | 20240203 | 2026.2.25 | 24.0 |
| u24r70f21m50t210-20260513_121430 | 20240203 | 2026.4.22 | 24.0 |
| u24r70f21m50t210-20260731_122833 | 20260601~24.04.1 | 2026.7.22 | 24.0 |
| u24r70f21m50t210-20260807_115122 | 20260601~24.04.1 | 2026.7.22 | 24.0 |
| u24r72f21m50t211-20260929_104918 | 20260601~24.04.1 | 2026.7.22 | 24.0 |

**Fixed in:** `u24r72f21m50t211-20261028_090706`, with `ca-certificates` 20260816ubuntu0.24.04.1, `certifi` 2026.10.23 and `pip` 26.2.2.

The rocm, libfabric and mpich images have no Python packages, so only their system CA store is affected.

## What the risk is

An image trusts the root in three separate CA stores:

- **The system CA store**, used by `curl`, `wget`, `git` and Python's `ssl` module.
- **`certifi`**, used by `requests`, `huggingface_hub`, `vllm` and many other Python libraries.
- **`pip`'s own bundled copy of `certifi`.**

Anyone holding a certificate issued under the compromised CA could pretend to be any HTTPS server to software in these containers. **To do that, they would also need to be in the network path between LUMI and that server. For a typical job this is unlikely, but the impact would be serious**:

- **Tampered downloads:** packages installed with `pip install`, models and datasets from the Hugging Face Hub, or code fetched with `git clone` could be replaced. A model in pickle format (`.bin`, `.pt`, `.ckpt`) can run arbitrary code when it's loaded.
- **Stolen credentials:** access tokens sent over HTTPS could be read, for example `HF_TOKEN`, Weights & Biases API keys, GitHub tokens and API keys for external model services.
- **Leaked data:** prompts, outputs and training data sent to or from external services could be read or changed.

Not affected:

- Work that doesn't connect to the internet, such as training on data already on LUMI's file systems.
- Files whose checksums you verify against a source you trust.

## What to do

### Containers

Switch to `lumi-multitorch-*-u24r72f21m50t211-20261028_090706`. It has the same ROCm, PyTorch and other main component versions as 20260929_104918, so most jobs only need the image path changed. Rebuild container images that you have derived from an old image on top of the fixed one.

To check whether an image still trusts the root (the file exists only in affected images):

```bash
singularity exec <image>.sif ls /etc/ssl/certs/emSign_ECC_Root_CA_-_G3.pem
```

If you have to keep an old image for now, pass it a CA bundle that no longer trusts the root, for example the one from the fixed image:

```bash
singularity exec lumi-multitorch-full-u24r72f21m50t211-20261028_090706.sif \
    cat /etc/ssl/certs/ca-certificates.crt > $HOME/ca-certificates.crt

export SINGULARITYENV_SSL_CERT_FILE=$HOME/ca-certificates.crt
export SINGULARITYENV_REQUESTS_CA_BUNDLE=$HOME/ca-certificates.crt
export SINGULARITYENV_PIP_CERT=$HOME/ca-certificates.crt
export SINGULARITYENV_CURL_CA_BUNDLE=$HOME/ca-certificates.crt
export SINGULARITYENV_GIT_SSL_CAINFO=$HOME/ca-certificates.crt
```

This covers most tools, but not libraries that load `certifi`'s bundle directly without checking these variables. Moving to the fixed release is the only complete fix.

### Virtual environments

Virtual environments made on top of an old image, e.g. with `--system-site-packages`, and packages installed with `pip install --user` can have their own copies of `certifi` and `pip`. These copies stay old even after you switch images. Rebuild such environments on the fixed image, or upgrade the packages in them while using the fixed image.

The environment's old `pip` still trusts the root, so install the new `pip` from its wheel with the wheel's SHA-256 hash, which `pip` checks. The new `pip` no longer trusts the root, so it can then upgrade `certifi` normally:

```bash
python -m pip install "pip @ https://files.pythonhosted.org/packages/3f/06/3e4420302363fbb71be3c7f35ce042f54bfca330e3e66b3a2e3c4cca579f/pip-26.2.2-py3-none-any.whl#sha256=fd7f4dfa8190e014013b9f08f3e973f4e4c26ffd179a204895533a7254813a70"
python -m pip install --upgrade "certifi>=2026.10.19"
```

> [!NOTE]
> Upgrading `pip` in a virtual environment is not enough if the environment still runs on an old image: `pip` 24.2 and later also trust the system CA store of that image, which still contains the root.

To check the versions that an environment uses:

```bash
python -c "import certifi, pip; print('certifi', certifi.__version__, 'pip', pip.__version__)"
```

### Tokens and downloads

1. **Rotate tokens that old images used.** Do this if you used tokens over the network from an old image, especially where traffic left LUMI through networks you don't control. This is a precaution; we aren't aware of any misuse.
2. **Prefer `safetensors` model files**, and pin Hugging Face downloads to a specific commit (`revision=`).

<!-- Optional: patched copies of earlier releases (`-ca-fix`) are available at <LOCATION> -->
