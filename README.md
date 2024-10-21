

```markdown
# Simple Port Scanner in Assembly

This project implements a simple TCP port scanner using x86_64 Assembly language on Linux. The scanner attempts to connect to a specified range of ports on a given target IP address, reporting which ports are open or closed.

## Features

- Scans a specified range of TCP ports on a target IP address.
- Reports open and closed ports.
- Written in x86_64 Assembly for Linux.

## Prerequisites

To compile and run this program, you will need:

- A Linux environment (Ubuntu, Debian, etc.)
- [NASM](https://www.nasm.us/) assembler
- [ld](https://en.wikipedia.org/wiki/GNU_Binutils) linker

## Usage

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/port-scanner.git
   cd port-scanner
   ```

2. **Edit the code:**
   Open `portscanner.asm` in a text editor and modify the `ip_address` and `sin_addr` variables to the target IP you want to scan. Adjust the `port_start` and `port_end` values to set the range of ports you wish to scan.

3. **Compile the program:**

   ```bash
   nasm -f elf64 -o portscanner.o portscanner.asm
   ld -o portscanner portscanner.o
   ```

4. **Run the program:**
   You may need root privileges to execute the port scanner.

   ```bash
   sudo ./portscanner
   ```

## Example Output

```
Port open: 20
Port closed: 21
Port closed: 22
Port open: 80
```

## Code Explanation

The port scanner works by:

- Creating a TCP socket using the `socket` syscall.
- Looping through a specified range of ports, attempting to connect using the `connect` syscall.
- Reporting the status of each port (open or closed) based on the success of the connection attempt.
- Closing the socket after each connection attempt.

## Limitations

- This port scanner is intended for educational purposes and may not work against all targets due to firewalls or other network security measures.
- Scanning certain ports or IP addresses may require permission, so ensure you have the necessary authorization before running the scanner.
