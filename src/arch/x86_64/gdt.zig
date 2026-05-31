// -- Types

const Entry = packed struct(u64) {
    limit_low:        u16,
    base_low:         u16,
    base_mid:         u8,
    access:           u8,
    limit_high_flags: u8, // flags[7:4] | limit_high[3:0]
    base_high:        u8,
};

const Descriptor = packed struct(u80) {
    limit: u16,
    base:  u64,
};

// -- GDT

fn makeEntry(base: u32, limit: u20, access: u8, flags: u4) Entry {
    return .{
        .limit_low        = @truncate(limit),
        .base_low         = @truncate(base),
        .base_mid         = @truncate(base >> 16),
        .access           = access,
        .limit_high_flags = (@as(u8, flags) << 4) | @as(u8, @truncate(limit >> 16)),
        .base_high        = @truncate(base >> 24),
    };
}

var gdt = [3]Entry{
    makeEntry(0, 0,       0x00, 0x0), // null
    makeEntry(0, 0xFFFFF, 0x9A, 0xA), // kernel code: present, DPL=0, execute/read, L=1, G=1
    makeEntry(0, 0xFFFFF, 0x92, 0xC), // kernel data: present, DPL=0, read/write, D=1, G=1
};

var gdtr: Descriptor = undefined;

// -- Load

pub fn load() void {
    gdtr = .{
        .limit = @sizeOf(@TypeOf(gdt)) - 1,
        .base  = @intFromPtr(&gdt),
    };

    asm volatile (
        \\lgdtq (%%rdi)
        \\pushq $0x08
        \\lea 1f(%%rip), %%rax
        \\pushq %%rax
        \\lretq
        \\1:
        \\mov $0x10, %%ax
        \\mov %%ax, %%ds
        \\mov %%ax, %%es
        \\mov %%ax, %%fs
        \\mov %%ax, %%gs
        \\mov %%ax, %%ss
        :
        : [addr] "{rdi}" (@intFromPtr(&gdtr))
        : .{ .rax = true, .rdi = true, .ds = true, .es = true, .fs = true, .gs = true, .ss = true }
    );
}
