// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_lhu_test
.extern fail

.section .data
test_values:
    .half -50
    .half -40
    .half -30
    .half -20
    .half -10
    .half 0
    .half 10
    .half 20
    .half 30
    .half 40

.section .text
.globl lhu_test
.type lhu_test, @function

lhu_test:

test1:
    la t0, test_values
    lhu t1, 0(t0)
    li t2, 0xFFCE
    beq t1, t2, test2
    j Fail_Lhu_1

test2:
    lhu t1, 2(t0)
    li t2, 0xFFD8
    beq t1, t2, test3
    j Fail_Lhu_2

test3:
    lhu t1, 4(t0)
    li t2, 0xFFE2
    beq t1, t2, test4
    j Fail_Lhu_3

test4:
    lhu t1, 6(t0)
    li t2, 0xFFEC
    beq t1, t2, test5
    j Fail_Lhu_4

test5:
    lhu t1, 8(t0)
    li t2, 0xFFF6
    beq t1, t2, test6
    j Fail_Lhu_5

test6:
    lhu t1, 10(t0)
    li t2, 0
    beq t1, t2, test7
    j Fail_Lhu_6

test7:
    lhu t1, 12(t0)
    li t2, 10
    beq t1, t2, test8
    j Fail_Lhu_7

test8:
    lhu t1, 14(t0)
    li t2, 20
    beq t1, t2, test9
    j Fail_Lhu_8

test9:
    lhu t1, 16(t0)
    li t2, 30
    beq t1, t2, test10
    j Fail_Lhu_9

test10:
    lhu t1, 18(t0)
    li t2, 40
    beq t1, t2, pass
    j Fail_Lhu_10


Fail_Lhu_1:
    li gp, 421
    j fail

Fail_Lhu_2:
    li gp, 422
    j fail

Fail_Lhu_3:
    li gp, 423
    j fail

Fail_Lhu_4:
    li gp, 424
    j fail

Fail_Lhu_5:
    li gp, 425
    j fail

Fail_Lhu_6:
    li gp, 426
    j fail

Fail_Lhu_7:
    li gp, 427
    j fail

Fail_Lhu_8:
    li gp, 428
    j fail

Fail_Lhu_9:
    li gp, 429
    j fail

Fail_Lhu_10:
    li gp, 430
    j fail

pass:
    j return_lhu_test
