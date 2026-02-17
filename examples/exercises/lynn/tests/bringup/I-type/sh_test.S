// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_sh_test
.extern fail

.section .text.init
.globl sh_test
.type  sh_test, @function

sh_test:

pretest:
    addi sp, sp, -20

    li t0, 10
    sh t0, 0(sp)
    li t0, 20
    sh t0, 2(sp)
    li t0, 30
    sh t0, 4(sp)
    li t0, 40
    sh t0, 6(sp)
    li t0, 50
    sh t0, 8(sp)
    li t0, 60
    sh t0, 10(sp)
    li t0, 70
    sh t0, 12(sp)
    li t0, 80
    sh t0, 14(sp)
    li t0, 90
    sh t0, 16(sp)
    li t0, 100
    sh t0, 18(sp)

    j test1

// ---------------- TESTS ----------------

test1:
    lh t0, 0(sp)
    li t1, 10
    beq t0, t1, test2
    j Fail_Sh_1

test2:
    lh t0, 2(sp)
    li t1, 20
    beq t0, t1, test3
    j Fail_Sh_2

test3:
    lh t0, 4(sp)
    li t1, 30
    beq t0, t1, test4
    j Fail_Sh_3

test4:
    lh t0, 6(sp)
    li t1, 40
    beq t0, t1, test5
    j Fail_Sh_4

test5:
    lh t0, 8(sp)
    li t1, 50
    beq t0, t1, test6
    j Fail_Sh_5

test6:
    lh t0, 10(sp)
    li t1, 60
    beq t0, t1, test7
    j Fail_Sh_6

test7:
    lh t0, 12(sp)
    li t1, 70
    beq t0, t1, test8
    j Fail_Sh_7

test8:
    lh t0, 14(sp)
    li t1, 80
    beq t0, t1, test9
    j Fail_Sh_8

test9:
    lh t0, 16(sp)
    li t1, 90
    beq t0, t1, test10
    j Fail_Sh_9

test10:
    lh t0, 18(sp)
    li t1, 100
    beq t0, t1, pass
    j Fail_Sh_10

// ---------------- PASS ----------------

pass:
    addi sp, sp, 20
    j return_sh_test

// ---------------- FAIL HANDLERS ----------------

Fail_Sh_1:
    li gp, 441
    j fail

Fail_Sh_2:
    li gp, 442
    j fail

Fail_Sh_3:
    li gp, 443
    j fail

Fail_Sh_4:
    li gp, 444
    j fail

Fail_Sh_5:
    li gp, 445
    j fail

Fail_Sh_6:
    li gp, 446
    j fail

Fail_Sh_7:
    li gp, 447
    j fail

Fail_Sh_8:
    li gp, 448
    j fail

Fail_Sh_9:
    li gp, 449
    j fail

Fail_Sh_10:
    li gp, 450
    j fail
