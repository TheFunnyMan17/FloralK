arch := "x86_64"

qemu_bin := "qemu-system-" + arch
efi_boot  := if arch == "x86_64" { "BOOTX64.EFI" } \
        else { error("unsupported architecture: " + arch) }

build:
    zig build -Darch={{arch}} --prefix build

iso: build
    rm -rf build/iso
    mkdir -p build/iso/boot/limine build/iso/EFI/BOOT
    cp build/bin/floral-k             build/iso/boot/floral-k
    cp config/limine.conf                    build/iso/boot/limine/limine.conf
    cp /usr/share/limine/limine-bios.sys     build/iso/boot/limine/
    cp /usr/share/limine/limine-bios-cd.bin  build/iso/boot/limine/
    cp /usr/share/limine/limine-uefi-cd.bin  build/iso/boot/limine/
    cp /usr/share/limine/{{efi_boot}}         build/iso/EFI/BOOT/
    xorriso -as mkisofs \
        -b boot/limine/limine-bios-cd.bin \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        --efi-boot boot/limine/limine-uefi-cd.bin \
        -efi-boot-part --efi-boot-image --protective-msdos-label \
        build/iso/ -o build/floral-k.iso 2>/dev/null
    limine bios-install build/floral-k.iso

run: iso
    {{qemu_bin}} \
        -M q35 \
        -m 128M \
        -cdrom build/floral-k.iso \
        -serial stdio \
        -no-reboot \
        -no-shutdown \
        -display gtk

clean:
    rm -rf build .zig-cache