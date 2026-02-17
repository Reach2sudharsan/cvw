// C Runtime entry point
// Sudharsan Gopalakrishnan
// 2/12/2026

.extern return_slli_test
.extern fail

    .section .text.init
    .globl slli_test
    .type  slli_test, @function

slli_test:

    test1:
        li t0, 0x001
        slli t2, t0, 4
        li t3, 0x010
        beq t2, t3, test2
        j Fail_Slli_1

    test2:
        li t0, 0x002
        slli t2, t0, 2
        li t3, 0x008
        beq t2, t3, test3
        j Fail_Slli_2

    test3:
        li t0, 0x004
        slli t2, t0, 1
        li t3, 0x008
        beq t2, t3, test4
        j Fail_Slli_3

    test4:
        li t0, 0x003
        slli t2, t0, 1
        li t3, 0x006
        beq t2, t3, test5
        j Fail_Slli_4

    test5:
        li t0, 0x005
        slli t2, t0, 2
        li t3, 0x014
        beq t2, t3, test6
        j Fail_Slli_5

    test6:
        li t0, 0x00F
        slli t2, t0, 1
        li t3, 0x01E
        beq t2, t3, test7
        j Fail_Slli_6

    test7:
        li t0, 0x008
        slli t2, t0, 3
        li t3, 0x040
        beq t2, t3, test8
        j Fail_Slli_7

    test8:
        li t0, 0x001
        slli t2, t0, 4
        li t3, 0x010
        beq t2, t3, test9
        j Fail_Slli_8

    test9:
        li t0, 0x002
        slli t2, t0, 3
        li t3, 0x010
        beq t2, t3, test10
        j Fail_Slli_9

    test10:
        li t0, 0x007
        slli t2, t0, 1
        li t3, 0x00E
        beq t2, t3, pass
        j Fail_Slli_10

Fail_Slli_1:
    li gp, 351
    j fail

Fail_Slli_2:
    li gp, 352
    j fail

Fail_Slli_3:
    li gp, 353
    j fail

Fail_Slli_4:
    li gp, 354
    j fail

Fail_Slli_5:
    li gp, 355
    j fail

Fail_Slli_6:
    li gp, 356
    j fail

Fail_Slli_7:
    li gp, 357
    j fail

Fail_Slli_8:
    li gp, 358
    j fail

Fail_Slli_9:
    li gp, 359
    j fail

Fail_Slli_10:
    li gp, 360
    j fail

pass:
    j return_slli_test
