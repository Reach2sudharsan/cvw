// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_srai_test
.extern fail

.section .text.init
.globl srai_test
.type  srai_test, @function

srai_test:

    test1:
        li t0, 0x111
        srai t2, t0, 2
        li t3, 0x044
        beq t2, t3, test2
        j Fail_Srai_1

    test2:
        li t0, 0x000
        srai t2, t0, 2
        li t3, 0x000
        beq t2, t3, test3
        j Fail_Srai_2

    test3:
        li t0, 0x100
        srai t2, t0, 4
        li t3, 0x010
        beq t2, t3, test4
        j Fail_Srai_3

    test4:
        li t0, 0x080
        srai t2, t0, 3
        li t3, 0x010
        beq t2, t3, test5
        j Fail_Srai_4

    test5:
        li t0, 0x001
        srai t2, t0, 1
        li t3, 0x000
        beq t2, t3, test6
        j Fail_Srai_5

    test6:
        li t0, 0xF00
        srai t2, t0, 4
        li t3, 0x0F0
        beq t2, t3, test7
        j Fail_Srai_6

    test7:
        li t0, 0xFFFFFFFF
        srai t2, t0, 31
        li t3, 0xFFFFFFFF
        beq t2, t3, test8
        j Fail_Srai_7

    test8:
        li t0, 0x7FFFFFFF
        srai t2, t0, 1
        li t3, 0x3FFFFFFF
        beq t2, t3, test9
        j Fail_Srai_8

    test9:
        li t0, 0xAAAAAAAA
        srai t2, t0, 1
        li t3, 0xD5555555
        beq t2, t3, test10
        j Fail_Srai_9

    test10:
        li t0, 0x00000010
        srai t2, t0, 4
        li t3, 0x00000001
        beq t2, t3, pass
        j Fail_Srai_10


Fail_Srai_1:
    li gp, 371
    j fail

Fail_Srai_2:
    li gp, 372
    j fail

Fail_Srai_3:
    li gp, 373
    j fail

Fail_Srai_4:
    li gp, 374
    j fail

Fail_Srai_5:
    li gp, 375
    j fail

Fail_Srai_6:
    li gp, 376
    j fail

Fail_Srai_7:
    li gp, 377
    j fail

Fail_Srai_8:
    li gp, 378
    j fail

Fail_Srai_9:
    li gp, 379
    j fail

Fail_Srai_10:
    li gp, 380
    j fail


pass:
    j return_srai_test
