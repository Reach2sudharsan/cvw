// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_lb_test
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
.globl lb_test
.type lb_test, @function

lb_test:

test1:
    la t0, test_values
    lb t1, 0(t0)
    li t2, -5
    beq t1, t2, test2
    j Fail_Lb_1

test2:
    lb t1, 1(t0)
    li t2, -4
    beq t1, t2, test3
    j Fail_Lb_2

test3:
    lb t1, 2(t0)
    li t2, -3
    beq t1, t2, test4
    j Fail_Lb_3

test4:
    lb t1, 3(t0)
    li t2, -2
    beq t1, t2, test5
    j Fail_Lb_4

test5:
    lb t1, 4(t0)
    li t2, -1
    beq t1, t2, test6
    j Fail_Lb_5

test6:
    lb t1, 5(t0)
    li t2, 0
    beq t1, t2, test7
    j Fail_Lb_6

test7:
    lb t1, 6(t0)
    li t2, 1
    beq t1, t2, test8
    j Fail_Lb_7

test8:
    lb t1, 7(t0)
    li t2, 2
    beq t1, t2, test9
    j Fail_Lb_8

test9:
    lb t1, 8(t0)
    li t2, 3
    beq t1, t2, test10
    j Fail_Lb_9

test10:
    lb t1, 9(t0)
    li t2, 4
    beq t1, t2, pass
    j Fail_Lb_10


Fail_Lb_1:
    li gp, 391
    j fail

Fail_Lb_2:
    li gp, 392
    j fail

Fail_Lb_3:
    li gp, 393
    j fail

Fail_Lb_4:
    li gp, 394
    j fail

Fail_Lb_5:
    li gp, 395
    j fail

Fail_Lb_6:
    li gp, 396
    j fail

Fail_Lb_7:
    li gp, 397
    j fail

Fail_Lb_8:
    li gp, 398
    j fail

Fail_Lb_9:
    li gp, 399
    j fail

Fail_Lb_10:
    li gp, 400
    j fail

pass:
    j return_lb_test
