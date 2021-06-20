# Copyright 2017 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Rules to load all dependencies of rules_docker."""

load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
    "http_file",
)
load(
    "@io_bazel_rules_docker//toolchains/docker:toolchain.bzl",
    _docker_toolchain_configure = "toolchain_configure",
)

# The release of the github.com/google/containerregistry to consume.
CONTAINERREGISTRY_RELEASE = "v0.0.38"
RULES_DOCKER_GO_BINARY_RELEASE = "aad94363e63d31d574cf701df484b3e8b868a96a"

def repositories():
    """Download dependencies of container rules."""
    excludes = native.existing_rules().keys()

    # Go binaries.
    if "containerregistry" not in excludes:
        http_archive(
            name = "containerregistry",
            sha256 = "a0c01fcc11db848212f8b11d89df168361f99a31eb7373ff60ce50c5d05cd74b",
            strip_prefix = "containerregistry-" + CONTAINERREGISTRY_RELEASE[1:],
            urls = [("https://github.com/google/containerregistry/archive/" +
                     CONTAINERREGISTRY_RELEASE + ".tar.gz")],
        )

    # TODO(mattmoor): Remove all of this (copied from google/containerregistry)
    # once transitive workspace instantiation lands.

    if "io_bazel_rules_go" not in excludes:
        http_archive(
            name = "io_bazel_rules_go",
            sha256 = "08c3cd71857d58af3cda759112437d9e63339ac9c6e0042add43f4d94caf632d",
            urls = [
                "https://storage.googleapis.com/bazel-mirror/github.com/bazelbuild/rules_go/releases/download/v0.24.2/rules_go-v0.24.2.tar.gz",
                "https://github.com/bazelbuild/rules_go/releases/download/v0.24.2/rules_go-v0.24.2.tar.gz",
            ],
        )
    if "rules_python" not in excludes:
        http_archive(
            name = "rules_python",
            url = "https://github.com/bazelbuild/rules_python/releases/download/0.1.0/rules_python-0.1.0.tar.gz",
            sha256 = "b6d46438523a3ec0f3cead544190ee13223a52f6a6765a29eae7b7cc24cc83a0",
        )

    # For packaging python tools.
    if "subpar" not in excludes:
        http_archive(
            name = "subpar",
            sha256 = "481233d60c547e0902d381cd4fb85b63168130379600f330821475ad234d9336",
            # Commit from 2019-03-07.
            strip_prefix = "subpar-9fae6b63cfeace2e0fb93c9c1ebdc28d3991b16f",
            urls = ["https://github.com/google/subpar/archive/9fae6b63cfeace2e0fb93c9c1ebdc28d3991b16f.tar.gz"],
        )

    if "structure_test_linux" not in excludes:
        http_file(
            name = "structure_test_linux",
            executable = True,
            sha256 = "9ddc0791491dc8139af5af4d894e48db4eeaca4b2cb9196293efd615bdb79122",
            urls = ["https://storage.googleapis.com/container-structure-test/v1.9.1/container-structure-test-linux-amd64"],
        )

    if "structure_test_linux_aarch64" not in excludes:
        http_file(
            name = "structure_test_linux_aarch64",
            executable = True,
            sha256 = "b8fd54ed5f3fcb65861dec8aea5ccf05856c9e030a67461e601eab64c1fe70b1",
            urls = ["https://storage.googleapis.com/container-structure-test/v1.9.1/container-structure-test-linux-arm64"],
        )

    if "structure_test_darwin" not in excludes:
        http_file(
            name = "structure_test_darwin",
            executable = True,
            sha256 = "0b8c019b5a3df1a84515b75c2eb47aaf9db51dec621a39d1c4fa31a4a8f6c855",
            urls = ["https://storage.googleapis.com/container-structure-test/v1.9.1/container-structure-test-darwin-amd64"],
        )

    if "container_diff" not in excludes:
        http_file(
            name = "container_diff",
            executable = True,
            sha256 = "65b10a92ca1eb575037c012c6ab24ae6fe4a913ed86b38048781b17d7cf8021b",
            urls = ["https://storage.googleapis.com/container-diff/v0.15.0/container-diff-linux-amd64"],
        )

    # For bzl_library.
    if "bazel_skylib" not in excludes:
        http_archive(
            name = "bazel_skylib",
            sha256 = "7ac0fa88c0c4ad6f5b9ffb5e09ef81e235492c873659e6bb99efb89d11246bcb",
            strip_prefix = "bazel-skylib-1.0.3",
            urls = ["https://github.com/bazelbuild/bazel-skylib/archive/1.0.3.tar.gz"],
        )

    if "bazel_gazelle" not in excludes:
        http_archive(
            name = "bazel_gazelle",
            sha256 = "cdb02a887a7187ea4d5a27452311a75ed8637379a1287d8eeb952138ea485f7d",
            urls = ["https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.21.1/bazel-gazelle-v0.21.1.tar.gz"],
        )

    if "rules_pkg" not in excludes:
        http_archive(
            name = "rules_pkg",
            sha256 = "aeca78988341a2ee1ba097641056d168320ecc51372ef7ff8e64b139516a4937",
            urls = ["https://github.com/bazelbuild/rules_pkg/releases/download/0.2.6-1/rules_pkg-0.2.6.tar.gz"],
        )

    native.register_toolchains(
        # Register the default docker toolchain that expects the 'docker'
        # executable to be in the PATH
        "@io_bazel_rules_docker//toolchains/docker:default_linux_toolchain",
        "@io_bazel_rules_docker//toolchains/docker:default_windows_toolchain",
        "@io_bazel_rules_docker//toolchains/docker:default_osx_toolchain",
    )

    if "docker_config" not in excludes:
        # Automatically configure the docker toolchain rule to use the default
        # docker binary from the system path
        _docker_toolchain_configure(name = "docker_config")
