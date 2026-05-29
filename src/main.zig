const arch = @import("arch/arch.zig").arch;
const limine = @import("boot/limine.zig");

export var requests_start: limine.RequestsStartMarker linksection(".limine_requests_start_marker") = .{};
export var base_revision:  limine.BaseRevision        linksection(".limine_requests")              = .{ .revision = 3 };
export var requests_end:   limine.RequestsEndMarker   linksection(".limine_requests_end_marker")   = .{};

export fn _start() callconv(.c) noreturn {
    if (!base_revision.isValid()) arch.halt();

    arch.init();
    arch.serial.print("hi :3");
    arch.halt();
}