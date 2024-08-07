const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "libmagic",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.addIncludePath(b.path("luna-config"));
    // macos has strlcpy
    var c_files = std.ArrayList([]const u8).init(b.allocator);
    for ([_][]const u8{
        "src/buffer.c",
        "src/magic.c",
        "src/apprentice.c",
        "src/softmagic.c",
        "src/ascmagic.c",
        "src/encoding.c",
        "src/compress.c",
        "src/is_csv.c",
        "src/is_json.c",
        "src/is_tar.c",
        "src/readelf.c",
        "src/print.c",
        "src/fsmagic.c",
        "src/funcs.c",
        "src/apptype.c",
        "src/der.c",
        "src/cdf.c",
        "src/cdf_time.c",
        "src/readcdf.c",
        "src/fmtcheck.c",
    }) |c_file| try c_files.append(c_file);
    if (target.result.os.tag != .macos) {
        try c_files.append("src/strlcpy.c");
    }
    lib.addCSourceFiles(.{
        .files = c_files.items,
        .flags = &.{"-DHAVE_CONFIG_H=1"},
    });
    lib.addIncludePath(b.path("."));
    lib.installHeader(b.path("luna-config/magic.h"), "magic.h");
    b.installArtifact(lib);
}
