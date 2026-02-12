// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/10/2026

.extern return_sw_test
.extern fail

.section .text.init
.globl sw_test
.type  sw_test, @function

sw_test:

pretest:
    addi sp, sp, -80

    li t0, 100
    sw t0, 0(sp)
    li t0, 200
    sw t0, 8(sp)
    li t0, 300
    sw t0, 16(sp)
    li t0, 400
    sw t0, 24(sp)
    li t0, 500
    sw t0, 32(sp)
    li t0, 600
    sw t0, 40(sp)
    li t0, 700
    sw t0, 48(sp)
    li t0, 800
    sw t0, 56(sp)
    li t0, 900
    sw t0, 64(sp)
    li t0, 1000
    sw t0, 72(sp)

    j test1

// ---------------- TESTS ----------------

test1:
    lw t0, 0(sp)
    li t1, 100
    beq t0, t1, test2
    j Fail_Sw_1

test2:
    lw t0, 8(sp)
    li t1, 200
    beq t0, t1, test3
    j Fail_Sw_2

test3:
    lw t0, 16(sp)
    li t1, 300
    beq t0, t1, test4
    j Fail_Sw_3

test4:
    lw t0, 24(sp)
    li t1, 400
    beq t0, t1, test5
    j Fail_Sw_4

test5:
    lw t0, 32(sp)
    li t1, 500
    beq t0, t1, test6
    j Fail_Sw_5

test6:
    lw t0, 40(sp)
    li t1, 600
    beq t0, t1, test7
    j Fail_Sw_6

test7:
    lw t0, 48(sp)
    li t1, 700
    beq t0, t1, test8
    j Fail_Sw_7

test8:
    lw t0, 56(sp)
    li t1, 800
    beq t0, t1, test9
    j Fail_Sw_8

test9:
    lw t0, 64(sp)
    li t1, 900
    beq t0, t1, test10
    j Fail_Sw_9

test10:
    lw t0, 72(sp)
    li t1, 1000
    beq t0, t1, pass
    j Fail_Sw_10

// ---------------- PASS ----------------

pass:
    addi sp, sp, 80
    j return_sw_test

// ---------------- FAIL HANDLERS ----------------

Fail_Sw_1:
    li gp, 311
    j fail

Fail_Sw_2:
    li gp, 312
    j fail

Fail_Sw_3:
    li gp, 313
    j fail

Fail_Sw_4:
    li gp, 314
    j fail

Fail_Sw_5:
    li gp, 315
    j fail

Fail_Sw_6:
    li gp, 316
    j fail

Fail_Sw_7:
    li gp, 317
    j fail

Fail_Sw_8:
    li gp, 318
    j fail

Fail_Sw_9:
    li gp, 319
    j fail

Fail_Sw_10:
    li gp, 320
    j fail
