def _impl(ctx):
    args = ["--cpp"] + ["-o", ctx.outputs.out.dirname] + [f.path for f in ctx.files.srcs]

    ctx.actions.run(
        inputs=ctx.files.srcs,
        outputs=[ctx.outputs.out],
        arguments=args,
        executable=ctx.executable._flatc
    )

    return [
        # create a provider which says that this
        # out file should be made available as a header
        CcInfo(compilation_context=cc_common.create_compilation_context(
            # pass out the include path for finding this header
            includes=depset([ctx.outputs.out.dirname]),
            # and the actual header here.
            headers=depset([ctx.outputs.out])
        ))
    ]

cc_flatbuffers_compile = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label(allow_files = True),
        "out": attr.output(mandatory = True),
        "_flatc": attr.label(executable = True,
                            cfg = "host",
                            allow_files = True,
                            default = Label("@flatbuffers//:flatc")),
     }
)
