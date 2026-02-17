// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_lh_test
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
.globl lh_test
.type lh_test, @function

lh_test:

test1:
    la t0, test_values
    lh t1, 0(t0)
    li t2, -50
    beq t1, t2, test2
    j Fail_Lh_1

test2:
    lh t1, 2(t0)
    li t2, -40
    beq t1, t2, test3
    j Fail_Lh_2

test3:
    lh t1, 4(t0)
    li t2, -30
    beq t1, t2, test4
    j Fail_Lh_3

test4:
    lh t1, 6(t0)
    li t2, -20
    beq t1, t2, test5
    j Fail_Lh_4

test5:
    lh t1, 8(t0)
    li t2, -10
    beq t1, t2, test6
    j Fail_Lh_5

test6:
    lh t1, 10(t0)
    li t2, 0
    beq t1, t2, test7
    j Fail_Lh_6

test7:
    lh t1, 12(t0)
    li t2, 10
    beq t1, t2, test8
    j Fail_Lh_7

test8:
    lh t1, 14(t0)
    li t2, 20
    beq t1, t2, test9
    j Fail_Lh_8

test9:
    lh t1, 16(t0)
    li t2, 30
    beq t1, t2, test10
    j Fail_Lh_9

test10:
    lh t1, 18(t0)
    li t2, 40
    beq t1, t2, pass
    j Fail_Lh_10


Fail_Lh_1:
    li gp, 411
    j fail

Fail_Lh_2:
    li gp, 412
    j fail

Fail_Lh_3:
    li gp, 413
    j fail

Fail_Lh_4:
    li gp, 414
    j fail

Fail_Lh_5:
    li gp, 415
    j fail

Fail_Lh_6:
    li gp, 416
    j fail

Fail_Lh_7:
    li gp, 417
    j fail

Fail_Lh_8:
    li gp, 418
    j fail

Fail_Lh_9:
    li gp, 419
    j fail

Fail_Lh_10:
    li gp, 420
    j fail

pass:
    j return_lh_test
