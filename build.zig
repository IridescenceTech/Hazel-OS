const std = @import("std");
const z = std.zig;
const builtin = @import("builtin");

const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = z.CrossTarget{
        .cpu_arch = .x86_64,
        .os_tag = .freestanding,
    };

    const mode = b.standardReleaseOptions();

    const exe = b.addObject("kernel", "src/kernel.zig");
    exe.setTarget(target);
    exe.setBuildMode(builtin.Mode.ReleaseFast);
    //exe.strip = true;
    exe.setOutputDir("./obj/");

    const tests = b.addTest("src/kernel.zig");
    tests.step.dependOn(&exe.step);

    const bootstrap = b.addSystemCommand(&[_][]const u8{
        "nasm", "src/bootstrap/boot.S", "-f", "elf64", "-o", "obj/boot.o",
    });
    bootstrap.step.dependOn(&tests.step);

    const mbHeader = b.addSystemCommand(&[_][]const u8{
        "nasm", "src/bootstrap/mbheader.S", "-f", "elf64", "-o", "obj/head.o",
    });
    mbHeader.step.dependOn(&bootstrap.step);

    const stub = b.addSystemCommand(&[_][]const u8{
        "nasm", "src/bootstrap/stub.S", "-f", "elf64", "-o", "obj/stub.o",
    });
    stub.step.dependOn(&mbHeader.step);

    const linkKernel = b.addSystemCommand(&[_][]const u8{
        "ld", "-T", "link.ld", "-o", "isofiles/boot/kernel.bin", "obj/kernel.o", "obj/boot.o", "obj/head.o", "obj/stub.o",
    });
    linkKernel.step.dependOn(&stub.step);

    const mkRescue = b.addSystemCommand(&[_][]const u8{
        "grub-mkrescue", "-o", "os.iso", "isofiles",
    });
    mkRescue.step.dependOn(&linkKernel.step);

    const qemu = b.addSystemCommand(&[_][]const u8{
        "qemu-system-x86_64", "-cdrom", "os.iso",
    });
    qemu.step.dependOn(&mkRescue.step);

    const run_step = b.step("run", "Runs the OS in QEMU");
    run_step.dependOn(&qemu.step);

    b.default_step.dependOn(&mkRescue.step);
}
