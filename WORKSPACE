load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("//3rdparty:workspace.bzl", "maven_dependencies")

#-- Skylib begin --#
http_archive(
    name = "bazel_skylib",
    sha256 = "f7be3474d42aae265405a592bb7da8e171919d74c16f082a5457840f06054728",
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
#-- Skylib end --#

#-- Maven start --#
maven_dependencies()

git_repository(
    name = "com_github_johnynek_bazel_jar_jar",
    commit = "171f268569384c57c19474b04aebe574d85fde0d",
    remote = "https://github.com/johnynek/bazel_jar_jar.git",
    shallow_since = "1594234634 -1000",
)

load("@com_github_johnynek_bazel_jar_jar//:jar_jar.bzl", "jar_jar_repositories")

jar_jar_repositories()
#-- Maven end --#

#-- Build tools start --#
http_file(
    name = "buildifier_linux",
    executable = True,
    sha256 = "6e6aea35b2ea2b4951163f686dfbfe47b49c840c56b873b3a7afe60939772fc1",
    urls = ["https://github.com/bazelbuild/buildtools/releases/download/0.25.0/buildifier"],
)

http_file(
    name = "buildifier_mac",
    executable = True,
    sha256 = "677a4e6dd247bee0ea336e7bdc94bc0b62d8f92c9f6a2f367b9a3ae1468b27ac",
    urls = ["https://github.com/bazelbuild/buildtools/releases/download/0.25.0/buildifier.mac"],
)
#-- Build tools end --#

#-- Scala begin --#
# version of the rules themselves, update this as needed to match the bazel version,
# based on https://github.com/bazelbuild/rules_scala#bazel-compatible-versions
http_archive(
    name = "io_bazel_rules_scala",
    sha256 = "9a23058a36183a556a9ba7229b4f204d3e68c8c6eb7b28260521016b38ef4e00",
    strip_prefix = "rules_scala-6.4.0",
    url = "https://github.com/bazelbuild/rules_scala/releases/download/v6.4.0/rules_scala-v6.4.0.tar.gz",
)

load("@io_bazel_rules_scala//:scala_config.bzl", "scala_config")

scala_config(scala_version = "2.12.18")

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")

scala_repositories()

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")

scala_register_toolchains()

load("@io_bazel_rules_scala//testing:scalatest.bzl", "scalatest_repositories", "scalatest_toolchain")

scalatest_repositories()

scalatest_toolchain()
#-- Scala end --#

#-- Protobuf begin --#
RULES_PROTO_VERSION = "c0b62f2f46c85c16cb3b5e9e921f0d00e3101934"

http_archive(
    name = "rules_proto",
    sha256 = "84a2120575841cc99789353844623a2a7b51571a54194a54fc41fb0a51454069",
    strip_prefix = "rules_proto-%s" % RULES_PROTO_VERSION,
    url = "https://github.com/bazelbuild/rules_proto/archive/%s.zip" % RULES_PROTO_VERSION,
)

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")

rules_proto_dependencies()

rules_proto_toolchains()
#-- Protobuf end --#
