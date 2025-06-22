; Copyright (c) Salmon 2025 under the Hippocratic 3.0 license.
; If your copy of this program doesn't include the license, it is
; available to read at:
;
;     <https://firstdonoharm.dev/version/3/0/core.txt>

[org 0x7c00]

boot_start:
    ; prepare stack and boot drive
    mov [BOOT_DRIVE], dl
    mov bp, [STACK_OFFSET]
    mov sp, bp

    ; real mode msg
    mov bx, MSG_REAL_MODE
    call print
    call print_nl

    call load_kernel

    call switch_to_pm
    mov ebx, MSG_PROT_MODE
    call print_string_pm

    call enter_kernel
    jmp $ ; for safety lol

%include "boot/boot_sect_disk.asm"
%include "boot/print/boot_sect_print.asm"
%include "boot/print/boot_sect_print_hex.asm"
%include "boot/b32/32bit-gdt.asm"
%include "boot/b32/32bit-print.asm"
%include "boot/b32/32bit-switch.asm"

[bits 16]
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print
    call print_nl

    mov bx, KERNEL_OFFSET ; Read from disk and store in 0x1000
    mov dh, [KERNEL_SIZE]
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret

[bits 32]
enter_kernel:
    call KERNEL_OFFSET ; Call kernel_entry
    mov ebx, MSG_CRASH_KERNEL
    call print_string_pm
    jmp $ ; if the kernel crashes

BOOT_DRIVE db 0
%include "boot/config.asm"

; padding
times 510 - ($-$$) db 0
dw 0xaa55
