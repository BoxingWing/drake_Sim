# -*- mode: python -*-

"""
On Ubuntu, pkg-config is used to locate the msgpack headers. On macOS,
no pkg-config file is installed, but the msgpack headers are always
located at /usr/local/opt/msgpack-cxx/include.
"""

load(
    "@drake//tools/workspace:pkg_config.bzl",
    "setup_pkg_config_repository",
)
load(
    "@drake//tools/workspace:os.bzl",
    "determine_os",
)

def _impl(repo_ctx):
    os_result = determine_os(repo_ctx)
    if os_result.error != None:
        fail(os_result.error)

    if os_result.is_ubuntu:
        error = setup_pkg_config_repository(repo_ctx).error
        if error != None:
            fail(error)
    else:
        prefix = "/usr/local/opt/msgpack-cxx/"
        repo_ctx.symlink("{}/include".format(prefix), "msgpack")

        hdrs_patterns = ["msgpack/**/*.hpp"]

        file_content = """# -*- python -*-

# DO NOT EDIT: generated by msgpack_repository()

licenses(["notice"])  # Boost-1.0

cc_library(
    name = "msgpack",
    hdrs = glob({}),
    includes = ["msgpack"],
    visibility = ["//visibility:public"],
    deps = ["@boost//:boost_headers"],

)
    """.format(hdrs_patterns)

        repo_ctx.file(
            "BUILD.bazel",
            content = file_content,
            executable = False,
        )

msgpack_repository = repository_rule(
    attrs = {
        "modname": attr.string(default = "msgpack"),
        "licenses": attr.string_list(default = ["notice"]),  # Boost-1.0
    },
    local = True,
    configure = True,
    implementation = _impl,
)