// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_lbu_test
.extern fail

.section .data
test_values:
    .byte -5
    .byte -4
    .byte -3
    .byte -2
    .byte -1
    .byte 0
    .byte 1
    .byte 2
    .byte 3
    .byte 4

.section .text
.globl lbu_test
.type lbu_test, @function

lbu_test:

test1:
    la t0, test_values
    lbu t1, 0(t0)
    li t2, 0xFB # 0101 --> 1011
    beq t1, t2, test2
    j Fail_Lbu_1

test2:
    lbu t1, 1(t0)
    li t2, 0xFC # 1100
    beq t1, t2, test3
    j Fail_Lbu_2

test3:
    lbu t1, 2(t0)
    li t2, 0xFD # 1101
    beq t1, t2, test4
    j Fail_Lbu_3

test4:
    lbu t1, 3(t0)
    li t2, 0xFE # 1110
    beq t1, t2, test5
    j Fail_Lbu_4

test5:
    lbu t1, 4(t0)
    li t2, 0xFF # 1111
    beq t1, t2, test6
    j Fail_Lbu_5

test6:
    lbu t1, 5(t0)
    li t2, 0
    beq t1, t2, test7
    j Fail_Lbu_6

test7:
    lbu t1, 6(t0)
    li t2, 1
    beq t1, t2, test8
    j Fail_Lbu_7

test8:
    lbu t1, 7(t0)
    li t2, 2
    beq t1, t2, test9
    j Fail_Lbu_8

test9:
    lbu t1, 8(t0)
    li t2, 3
    beq t1, t2, test10
    j Fail_Lbu_9

test10:
    lbu t1, 9(t0)
    li t2, 4
    beq t1, t2, pass
    j Fail_Lbu_10


Fail_Lbu_1:
    li gp, 401
    j fail

Fail_Lbu_2:
    li gp, 402
    j fail

Fail_Lbu_3:
    li gp, 403
    j fail

Fail_Lbu_4:
    li gp, 404
    j fail

Fail_Lbu_5:
    li gp, 405
    j fail

Fail_Lbu_6:
    li gp, 406
    j fail

Fail_Lbu_7:
    li gp, 407
    j fail

Fail_Lbu_8:
    li gp, 408
    j fail

Fail_Lbu_9:
    li gp, 409
    j fail

Fail_Lbu_10:
    li gp, 410
    j fail

pass:
    j return_lbu_test
