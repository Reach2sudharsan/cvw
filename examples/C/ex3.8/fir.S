// fir.S
// sgopalakrishnan@hmc.edu 5 February 2026
// FIR Lab 1 (ex. 3.8)

.section .text.init
.global fir

fir:
    // registers    a0, a1, a2, a3, a4
    // params       x,  c,  y,  n,  m

    // save saved registers and return address
    addi sp, sp, -40
    sd ra, 32(sp)
    sd s0, 24(sp)
    sd s1, 16(sp)
    sd s2, 8(sp)
    sd s3, 0(sp)

    // calculate outer loop bound = n-m+2
    sub s0, a3, a4 // s0 = n - m
    addi s0, s0, 2 // s0 = n - m + 2

    // load j = 0
    li s1, 0

for1:
    bge s1, s0, for1done // if j >= n-m+2, exit outer loop

    li s2, 0 // s2 = sum = 0
    li s3, 0 // s3 = i = 0

for2:
    bge s3, a4, for2done // if i >= m, exit inner loop

    // save registers that may be changed by upcoming function calls
    addi sp, sp, -48
    sd a0, 0(sp)
    sd a1, 8(sp)
    sd a2, 16(sp)
    sd a3, 24(sp)
    sd a4, 32(sp)
    sd s3, 40(sp)

    // calculate c[i] address
    slli t1, s3, 2 // t1 = i * 4
    add t1, a1, t1 // t1 = &c[i]
    lw t2, 0(t1) // t2 = c[i]

    // calculate x[j-i+(m-1)] address
    sub t3, s1, s3  // t3 = j-i
    add t3, t3, a4 // t3 = j-i+m
    addi t3, t3, -1 // t3 = j-i+m-1
    slli t3, t3, 2 // t3 = (j-i+m-1)*4
    add t3, a0, t3 // t3 = &x[j-i+m-1]
    lw t4, 0(t3) // t4 = x[j-i+m-1]

    // call mul_q31(c[i], x[j-i+m-1])
    mv a0, t2 // a0 = c[i]
    mv a1, t4 // a1 =  x[j-i+m-1])
    jal mul_q31

    // call add_q31(sum, result)
    mv a1, a0 // a1 = result from mul_q31
    mv a0, s2 // a0 = sum
    jal add_q31

    mv s2, a0 // sum = result from add_q31

    // restore registers
    ld a0, 0(sp)
    ld a1, 8(sp)
    ld a2, 16(sp)
    ld a3, 24(sp)
    ld a4, 32(sp)
    ld s3, 40(sp)
    addi sp, sp, 48

    addi s3, s3, 1 // i = i + 1
    j for2

for2done:
    // store sum in y
    slli t1, s1, 2 // t1 = j * 4
    add t1, a2, t1 // t1 = &y[j]
    sw s2, 0(t1) // y[j] = sum

    addi s1, s1, 1 // j = j + 1
    j for1

for1done:

    // restore saved registers and return address
    ld ra, 32(sp)
    ld s0, 24(sp)
    ld s1, 16(sp)
    ld s2, 8(sp)
    ld s3, 0(sp)
    addi sp, sp, 40
    ret
