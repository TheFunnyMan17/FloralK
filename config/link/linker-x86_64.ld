OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

/* Limine loads higher-half kernels at the -2 GiB mark */
KERNEL_BASE = 0xffffffff80000000;

SECTIONS {
    . = KERNEL_BASE;

    /* Limine protocol request records — must not be stripped */
    .limine_requests : {
        KEEP(*(.limine_requests_start))
        KEEP(*(.limine_requests))
        KEEP(*(.limine_requests_end))
    }

    . = ALIGN(CONSTANT(MAXPAGESIZE));

    .text : {
        *(.text .text.*)
    }

    . = ALIGN(CONSTANT(MAXPAGESIZE));

    .rodata : {
        *(.rodata .rodata.*)
    }

    . = ALIGN(CONSTANT(MAXPAGESIZE));

    . = ALIGN(CONSTANT(MAXPAGESIZE));
    .data : {
        *(.data .data.*)
    }

    /* ↓ Give TLS its own page-aligned region */
    . = ALIGN(CONSTANT(MAXPAGESIZE));
    .tdata : {
        _tdata_start = .;
        *(.tdata .tdata.*)
        _tdata_end = .;
    }
    .tbss : {
        _tbss_start = .;
        *(.tbss .tbss.*)
        _tbss_end = .;
    }

    . = ALIGN(CONSTANT(MAXPAGESIZE));
    .bss : {
        *(.bss .bss.*)
        *(COMMON)
    }

    . = ALIGN(CONSTANT(MAXPAGESIZE));

    /* Discard unwanted sections */
    /DISCARD/ : {
        *(.eh_frame)
        *(.eh_frame_hdr)
        *(.note .note.*)
    }
}