# zimage

Container images for the ZetaOSS MediaWiki development environment.

## Images

- `ghcr.io/zetaoss/zbase`: MediaWiki runtime and extensions
- `ghcr.io/zetaoss/zdev`: development tools and the zengine workspace, based
  on a released `zbase`

The images have independent versions in the root `versions.env` file. `zdev`
uses the exact `ZBASE_VERSION` declared in that file.

## Local builds

The root Makefile reads `versions.env` and builds `zbase` before `zdev`.

```sh
# Build the declared zbase version and then build zdev from it.
make

# Build only one image.
make zbase
make zdev

```

Running `make zdev` by itself uses the `ghcr.io/zetaoss/zbase` version declared
in `versions.env`. Running `make` first builds that base locally before building
the dependent image.

## Releases

Update the appropriate VERSION file and merge the change into `main`:

```sh
ZBASE_VERSION=0.2.0
ZDEV_VERSION=0.5.0
```

GitHub Actions checks whether the corresponding `zbase/v0.2.0` and
`zdev/v0.5.0` Git tags exist. Missing versions are built in zbase → zdev order,
published, and then tagged automatically. Each image receives the full
version, minor version, `latest`, and an immutable commit tag:

```text
ghcr.io/zetaoss/zdev:0.5.0
ghcr.io/zetaoss/zdev:0.5
ghcr.io/zetaoss/zdev:latest
ghcr.io/zetaoss/zdev:sha-<commit>
```

If a Dockerfile changes after its current release without the corresponding
version bump, the release workflow fails. A new zbase also requires a new zdev
version because changing the selected zbase version changes the resulting zdev
image.
