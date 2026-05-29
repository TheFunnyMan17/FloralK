pub const serial = @import("serial.zig");

pub fn halt() noreturn {
    while (true) asm volatile ("hlt");
}

pub fn init() void {
    serial.init();
}