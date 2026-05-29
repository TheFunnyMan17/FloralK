const std = @import("std");

const Arch = enum {
    x86_64,

    fn toCpuArch(self: @This()) std.Target.Cpu.Arch {
        return switch (self) {
            .x86_64 => .x86_64,
        };
    }

};

fn getTargetQuery(arch: Arch) std.Target.Query {
    var query = std.Target.Query{
        .cpu_arch = arch.toCpuArch(),
        .os_tag = .freestanding,
        .abi = .none,
    };

    switch (arch) {
        .x86_64 => {
            const x86 = std.Target.x86;
            query.cpu_features_add = x86.featureSet(&.{
                .soft_float,
            });
            query.cpu_features_sub = x86.featureSet(&.{
                // SIMD/FPU extensions
                .mmx,
                .sse,
                .sse2,
                .sse3,
                .ssse3,
                .sse4_1,
                .sse4_2,
                // AVX extensions
                .avx,
                .avx2,
                .avx512f,
                .avx512bw,
                .avx512cd,
                .avx512dq,
                .avx512vl,
                // Dead AMD extensions: no benefit
                .@"3dnow",
                .@"3dnowa",
            });
        },
    }

    return query;
}

pub fn build(b: *std.Build) void {
    const arch = b.option(Arch, "arch", "Architecture to build kernel for") orelse .x86_64;
    const optimize = b.standardOptimizeOption(.{});
    const target = b.resolveTargetQuery(getTargetQuery(arch));

    // Kernel module
    const kernel_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    switch (arch) {
        .x86_64 => {
            kernel_mod.red_zone = false;
            kernel_mod.code_model = .kernel;
        },
    }

    // Kernel object
    const kernel_obj = b.addObject(.{
        .name = "floral-k",
        .root_module = kernel_mod,
    });

    // Link step
    const linker_script = b.path(b.fmt("config/link/linker-{s}.ld", .{@tagName(arch)}));

    const link = b.addSystemCommand(&.{ "zig", "cc" });
    link.addArgs(&.{ "-target", b.fmt("{s}-freestanding-none", .{@tagName(arch)}) });
    switch (arch) {
        .x86_64 => link.addArgs(&.{"-mcmodel=kernel"}),
    }
    link.addArgs(&.{"-T"});
    link.addFileArg(linker_script);
    link.addArgs(&.{ "-nostdlib", "-static", "-s", "-Wl,-e,_start", "-o" });

    const elf = link.addOutputFileArg("floral-k");
    link.addFileArg(kernel_obj.getEmittedBin());
    link.setCwd(b.path("."));
    link.step.dependOn(&kernel_obj.step);

    // Install
    b.getInstallStep().dependOn(&b.addInstallBinFile(elf, "floral-k").step);
}