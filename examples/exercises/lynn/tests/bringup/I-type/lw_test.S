// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/10/2026

.extern return_lw_test
.extern fail

.section .data
test_values:
    .word 100
    .word 200
    .word 300
    .word 400
    .word 500
    .word 600
    .word 700
    .word 800
    .word 900
    .word 1000

.section .text
.globl lw_test
.type lw_test, @function

lw_test:

test1:
    la t0, test_values
    lw t1, 0(t0)
    j pass
    li t2, 100
    beq t1, t2, pass
    j Fail_Lw_1

test2:
    lw t1, 4(t0)
    li t2, 200
    beq t1, t2, test3
    j Fail_Lw_2

test3:
    lw t1, 8(t0)
    li t2, 300
    beq t1, t2, test4
    j Fail_Lw_3

test4:
    lw t1, 12(t0)
    li t2, 400
    beq t1, t2, test5
    j Fail_Lw_4

test5:
    lw t1, 16(t0)
    li t2, 500
    beq t1, t2, test6
    j Fail_Lw_5

test6:
    lw t1, 20(t0)
    li t2, 600
    beq t1, t2, test7
    j Fail_Lw_6

test7:
    lw t1, 24(t0)
    li t2, 700
    beq t1, t2, test8
    j Fail_Lw_7

test8:
    lw t1, 28(t0)
    li t2, 800
    beq t1, t2, test9
    j Fail_Lw_8

test9:
    lw t1, 32(t0)
    li t2, 900
    beq t1, t2, test10
    j Fail_Lw_9

test10:
    lw t1, 36(t0)
    li t2, 1000
    beq t1, t2, pass
    j Fail_Lw_10


Fail_Lw_1:
    li gp, 321
    j fail

Fail_Lw_2:
    li gp, 322
    j fail

Fail_Lw_3:
    li gp, 323
    j fail

Fail_Lw_4:
    li gp, 324
    j fail

Fail_Lw_5:
    li gp, 325
    j fail

Fail_Lw_6:
    li gp, 326
    j fail

Fail_Lw_7:
    li gp, 327
    j fail

Fail_Lw_8:
    li gp, 328
    j fail

Fail_Lw_9:
    li gp, 329
    j fail

Fail_Lw_10:
    li gp, 330
    j fail

pass:
    j return_lw_test
