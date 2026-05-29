const PORT = 0x3F8; // COM1

// -- Initialization

pub fn init() void {
    outb(PORT + 1, 0x00); // disable interrupts
    outb(PORT + 3, 0x80); // enable DLAB (set baud rate divisor)
    outb(PORT + 0, 0x03); // set divisor low byte  → 38400 baud
    outb(PORT + 1, 0x00); // high byte
    outb(PORT + 3, 0x03); // 8 bits, no parity, one stop bit
    outb(PORT + 2, 0xC7); // enable FIFO, clear, 14-byte threshold
    outb(PORT + 4, 0x0B); // IRQs enabled, RTS/DSR set
}

// -- Write

pub fn write(byte: u8) void {
    while (inb(PORT + 5) & 0x20 == 0) {
        asm volatile ("pause");
    }
    outb(PORT, byte);
}

pub fn print(str: []const u8) void {
    for (str) |c| write(c);
}

// -- Port I/O

fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[val], %[port]"
        :: [val]  "{al}" (value),
           [port] "{dx}" (port));
}

fn inb(port: u16) u8 {
    return asm volatile ("inb %[port], %[ret]"
        : [ret]  "={al}" (-> u8)
        : [port] "{dx}" (port));
}