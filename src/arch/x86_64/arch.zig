pub const serial = @import("serial.zig");
pub const gdt    = @import("gdt.zig");

pub fn halt() noreturn {
    while (true) asm volatile ("hlt");
}

pub fn init() void {
    gdt.load();
    serial.init();
}