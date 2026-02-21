// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_sb_test
.extern fail

.section .text.init
.globl sb_test
.type  sb_test, @function

sb_test:

pretest:
    li sp, 0x807ffffc
    addi sp, sp, -10

    li t0, 1
    sb t0, 0(sp)
    li t0, 2
    sb t0, 1(sp)
    li t0, 3
    sb t0, 2(sp)
    li t0, 4
    sb t0, 3(sp)
    li t0, 5
    sb t0, 4(sp)
    li t0, 6
    sb t0, 5(sp)
    li t0, 7
    sb t0, 6(sp)
    li t0, 8
    sb t0, 7(sp)
    li t0, 9
    sb t0, 8(sp)
    li t0, 10
    sb t0, 9(sp)

    j test1

// ---------------- TESTS ----------------

test1:
    lb t0, 0(sp)
    li t1, 1
    beq t0, t1, test2
    j Fail_Sb_1

test2:
    lb t0, 1(sp)
    li t1, 2
    beq t0, t1, test3
    j Fail_Sb_2

test3:
    lb t0, 2(sp)
    li t1, 3
    beq t0, t1, test4
    j Fail_Sb_3

test4:
    lb t0, 3(sp)
    li t1, 4
    beq t0, t1, test5
    j Fail_Sb_4

test5:
    lb t0, 4(sp)
    li t1, 5
    beq t0, t1, test6
    j Fail_Sb_5

test6:
    lb t0, 5(sp)
    li t1, 6
    beq t0, t1, test7
    j Fail_Sb_6

test7:
    lb t0, 6(sp)
    li t1, 7
    beq t0, t1, test8
    j Fail_Sb_7

test8:
    lb t0, 7(sp)
    li t1, 8
    beq t0, t1, test9
    j Fail_Sb_8

test9:
    lb t0, 8(sp)
    li t1, 9
    beq t0, t1, test10
    j Fail_Sb_9

test10:
    lb t0, 9(sp)
    li t1, 10
    beq t0, t1, pass
    j Fail_Sb_10

// ---------------- PASS ----------------

pass:
    addi sp, sp, 10
    j return_sb_test

// ---------------- FAIL HANDLERS ----------------

Fail_Sb_1:
    li gp, 431
    j fail

Fail_Sb_2:
    li gp, 432
    j fail

Fail_Sb_3:
    li gp, 433
    j fail

Fail_Sb_4:
    li gp, 434
    j fail

Fail_Sb_5:
    li gp, 435
    j fail

Fail_Sb_6:
    li gp, 436
    j fail

Fail_Sb_7:
    li gp, 437
    j fail

Fail_Sb_8:
    li gp, 438
    j fail

Fail_Sb_9:
    li gp, 439
    j fail

Fail_Sb_10:
    li gp, 440
    j fail
