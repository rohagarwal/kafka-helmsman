#!/bin/bash
echo -ne "\033[0;32m"
echo 'Updating bazel dependencies. This will take about five minutes.'
echo -ne "\033[0m"
set -e

BAZEL_DEPS_VERSION="v0.1-52"

PLATFORM="$(uname -s)"

if [ $PLATFORM == "Linux" ]; then
  BAZEL_DEPS_URL="https://github.com/johnynek/bazel-deps/releases/download/${BAZEL_DEPS_VERSION}/bazel-deps-linux"
  BAZEL_DEPS_SHA256=bf9395f2d664cb4871fc48a1062e0b2e7d6cf0c0e442e115f654d275c5e6560e
elif [ $PLATFORM == "Darwin" ]; then
  BAZEL_DEPS_URL="https://github.com/johnynek/bazel-deps/releases/download/${BAZEL_DEPS_VERSION}/bazel-deps-macos"
  BAZEL_DEPS_SHA256=a37ebb76fefc3961c5c1cf5461395dcd18694f200ea12ea140947838d1946d19
else
  echo "Your platform '$PLATFORM' is unsupported, sorry"
  exit 1
fi

# This is some bash snippet designed to find the location of the script.
# we operate under the presumption this script is checked into the repo being operated on
# so we goto the script location, then use git to find the repo root.
SCRIPT_LOCATION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_LOCATION

REPO_ROOT=$(git rev-parse --show-toplevel)

BAZEL_DEPS_DIR="$HOME/.bazel-deps-cache"
BAZEL_DEPS_PATH="${BAZEL_DEPS_DIR}/${BAZEL_DEPS_VERSION}"
echo "Installing bazel-deps into $BAZEL_DEPS_PATH"

if [ ! -f ${BAZEL_DEPS_PATH} ]; then
  ( # Opens a subshell
    set -e
    echo "Fetching bazel deps."
    curl -L -o /tmp/bazel-deps-bin $BAZEL_DEPS_URL

    GENERATED_SHA_256=$(shasum -a 256 /tmp/bazel-deps-bin | awk '{print $1}')

    if [ "$GENERATED_SHA_256" != "$BAZEL_DEPS_SHA256" ]; then
      echo "Sha 256 does not match, expected: $BAZEL_DEPS_SHA256"
      echo "But found $GENERATED_SHA_256"
      echo "You may need to update the sha in this script, or the download was corrupted."
      exit 1
    fi

    chmod +x /tmp/bazel-deps-bin
    mkdir -p ${BAZEL_DEPS_DIR}
    mv /tmp/bazel-deps-bin ${BAZEL_DEPS_PATH}
  )
fi

cd $REPO_ROOT
set +e
$BAZEL_DEPS_PATH generate -r $REPO_ROOT -s 3rdparty/workspace.bzl -d dependencies.yaml
RET_CODE=$?
set -e

if [ $RET_CODE == 0 ]; then
  echo "Success, going to format files"
else
  echo "Failure, reverting 3rdparty/jvm"
  cd $REPO_ROOT
  git checkout 3rdparty/jvm 3rdparty/workspace.bzl
  exit $RET_CODE
fi

$BAZEL_DEPS_PATH format-deps -d $REPO_ROOT/dependencies.yaml -o

# Formatting bazel files - use local installation of buildifier if available, fallback to Bazel
if [[ -x "$(command -v buildifier)" ]]; then
  BUILDIFIER="buildifier"
else
  BUILDIFIER="bazel run //tools:buildifier --"
fi

$BUILDIFIER -r .
