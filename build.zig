const std = @import("std");
const z = std.zig;
const builtin = @import("builtin");

const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = z.CrossTarget{
        .cpu_arch = .i386,
        .os_tag = .freestanding,
    };

    const mode = b.standardReleaseOptions();

    const exe = b.addObject("kernel", "src/kernel.zig");
    exe.setTarget(target);
    exe.strip = true;
    exe.setBuildMode(builtin.Mode.ReleaseSmall);
    exe.setOutputDir("./obj/");

    const tests = b.addTest("src/kernel.zig");
    tests.step.dependOn(&exe.step);

    const bootstrap = b.addSystemCommand(&[_][]const u8{
        "nasm", "src/bootstrap/boot.S", "-f", "elf32", "-o", "obj/boot.o",
    });
    bootstrap.step.dependOn(&tests.step);

    const mbHeader = b.addSystemCommand(&[_][]const u8{
        "nasm", "src/bootstrap/mbheader.S", "-f", "elf32", "-o", "obj/head.o",
    });
    mbHeader.step.dependOn(&bootstrap.step);

    const linkKernel = b.addSystemCommand(&[_][]const u8{
        "ld", "-T", "link.ld", "-melf_i386", "-o", "isofiles/boot/kernel.bin", "obj/kernel.o", "obj/boot.o", "obj/head.o",
    });
    linkKernel.step.dependOn(&mbHeader.step);

    const mkRescue = b.addSystemCommand(&[_][]const u8{
        "grub-mkrescue", "-o", "os.iso", "isofiles",
    });
    mkRescue.step.dependOn(&linkKernel.step);

    const qemu = b.addSystemCommand(&[_][]const u8{
        "qemu-system-i386", "-cdrom", "os.iso",
    });
    qemu.step.dependOn(&mkRescue.step);

    const run_step = b.step("run", "Runs the OS in QEMU");
    run_step.dependOn(&qemu.step);

    b.default_step.dependOn(&mkRescue.step);
}
