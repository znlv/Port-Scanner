section .data
    ip_address db '192.168.1.1', 0 ; Target IP address (change this)
    sin_family dw 2                 ; AF_INET (IPv4)
    sin_port   dw 0                 ; Port number (will be set dynamically)
    sin_addr   dd 0x0101A8C0        ; 192.168.1.1 in hex (change this to match ip_address)
    port_start dw 20                ; Start scanning from port 20
    port_end   dw 25                ; End scanning at port 25
    success_msg db 'Port open: ', 0
    closed_msg db 'Port closed: ', 0
    newline db 0xA, 0

section .bss
    sockfd resd 1
    port resw 1
    port_str resb 6 ; For storing port number as string

section .text
    global _start

_start:
    ; Loop through ports from port_start to port_end
    movzx   eax, word [port_start]
scan_loop:
    cmp     eax, [port_end]
    jg      scan_done

    ; Create a TCP socket
    mov     rax, 41              ; syscall: socket
    mov     rdi, 2               ; AF_INET (IPv4)
    mov     rsi, 1               ; SOCK_STREAM (TCP)
    xor     rdx, rdx             ; protocol 0
    syscall
    test    rax, rax
    js      scan_done            ; If socket creation failed
    mov     [sockfd], eax        ; Save socket file descriptor

    ; Set the port number (convert from host to network byte order)
    mov     [port], ax           ; Set port number
    rol     ax, 8                ; Convert little endian to big endian
    mov     [sin_port], ax

    ; Connect to the target IP address on the specified port
    mov     rax, 42              ; syscall: connect
    mov     rdi, [sockfd]        ; Socket file descriptor
    lea     rsi, [sin_family]     ; Pointer to sockaddr_in struct
    mov     rdx, 16              ; sizeof(struct sockaddr_in)
    syscall
    test    rax, rax
    js      port_closed          ; If connection failed, port is closed

    ; Print success message (Port open)
    mov     rax, 1               ; syscall: write
    mov     rdi, 1               ; File descriptor (stdout)
    mov     rsi, success_msg     ; Message: "Port open: "
    mov     rdx, 12              ; Length of the message
    syscall

    ; Print the port number
    call    print_port

    ; Close the socket
    jmp     close_socket

port_closed:
    ; Print closed message (Port closed)
    mov     rax, 1               ; syscall: write
    mov     rdi, 1               ; File descriptor (stdout)
    mov     rsi, closed_msg      ; Message: "Port closed: "
    mov     rdx, 13              ; Length of the message
    syscall

    ; Print the port number
    call    print_port

close_socket:
    ; Close the socket
    mov     rax, 3               ; syscall: close
    mov     rdi, [sockfd]        ; Socket file descriptor
    syscall

    ; Increment port and repeat
    inc     eax
    jmp     scan_loop

scan_done:
    ; Exit the program
    mov     rax, 60              ; syscall: exit
    xor     rdi, rdi             ; Status code 0
    syscall

; Function to print the port number (simple integer to string conversion)
print_port:
    mov     rdi, port_str        ; Destination buffer for the port string
    mov     rsi, eax             ; Port number to convert
    call    int_to_str
    mov     rax, 1               ; syscall: write
    mov     rdi, 1               ; File descriptor (stdout)
    mov     rdx, 5               ; Length of port string
    syscall
    ; Print newline
    mov     rax, 1               ; syscall: write
    mov     rdi, 1               ; File descriptor (stdout)
    mov     rsi, newline         ; Newline character
    mov     rdx, 1
    syscall
    ret

; Function to convert an integer to string (stored in rsi, result in rdi)
int_to_str:
    mov     rcx, 5               ; Max digits for port number
    mov     rbx, 10              ; Divisor (base 10)
convert_loop:
    xor     rdx, rdx
    div     rbx
    add     dl, '0'
    dec     rcx
    mov     [rdi+rcx], dl
    test    rax, rax
    jnz     convert_loop
    ret
