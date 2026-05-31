# Building

## Note

Currently only the x86_64 architecture is supported.

## Prerequisites

- Zig 0.16.0
- just
- limine (files expected at `/usr/share/limine/`)
- xorriso
- QEMU


## Commands

| Command | Effect |
|---------|--------|
| `just build` | Compile kernel → `build/bin/floral-k` |
| `just iso` | Build + create bootable ISO → `build/floral-k.iso` |
| `just run` | Build ISO + launch in QEMU |
| `just clean` | Delete `build/` and `.zig-cache/` |

## What happens under the hood

**`zig build`** compiles the kernel (`src/main.zig`) as a freestanding x86_64 ELF object with SSE/AVX/MMX disabled, soft float and kernel code model enabled, and no red zone. It then links it with a custom linker script (`config/link/linker-x86_64.ld`).

**`just iso`** assembles a hybrid BIOS+UEFI bootable ISO using Limine as the bootloader and the kernel config from `config/limine.conf`.

**`just run`** passes the ISO to QEMU (`q35`, 128 MB RAM, serial → stdout).
