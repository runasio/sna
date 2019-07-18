# Travis CI Configuration for Elixir Project

Our team is actually programming SNA project on Fedora and
OpenBSD. Unfortunately, Travis CI doesn't support these OS.

## FAQ

### How to configure Travis CI?

By put a `.travis.yml` at the root of your project. You can find more
information in the official tutorial:
https://docs.travis-ci.com/user/tutorial/

### How to switch to another OS?

 * https://docs.travis-ci.com/user/multi-os/

### How to configure PostgreSQL

 * https://docs.travis-ci.com/user/database-setup/#postgresql

### How to check if an Erlang/OTP version is available?

You can search for Erlang/OTP official release
(https://www.erlang.org/downloads) and verify if those packages are
available on the travis-ci package cache with `curl` command.

```
HOST="https://storage.googleapis.com"
LINUX="ubuntu"
VERSION="16.04"
ARCH="x86_64"
TARGET="${HOST}/travis-ci-language-archives/erlang/binaries/${LINUX}/${VERSION}/${ARCH}"
ERLANG_RELEASE="19.3"
curl -I "${TARGET}/erlang-${ERLANG_RELEASE}-nonroot.tar.bz2"
```

If the package exist, you should have a HTTP 200 code else a 404 not
found. You can also use https://pkgs.org/ to find packages from
different OS.

### How to check if an Elixir rlease is available?

With the brute force approach, you can check directly from this URL:

```
HOST="https://repo.hex.pm"
ELIXIR_RELEASE="1.8"
MAJOR_OTP_RELEASE="20"
TARGET="${HOST}/builds/elixir/v${ELIXIR_RELEASE}-otp-${MAJOR_OTP_RELEASE}.zip"
curl -I "${TARGET}"
```

### How to configure testing for Elixir projects?

Actually, you can use `mix` command.

```
mix test
```

## Resources

 * https://docs.travis-ci.com/user/languages/elixir/
 * https://docs.travis-ci.com/user/languages/erlang/
