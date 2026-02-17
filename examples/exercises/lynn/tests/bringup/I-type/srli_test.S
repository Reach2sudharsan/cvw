// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_srli_test
.extern fail

.section .text.init
.globl srli_test
.type  srli_test, @function

srli_test:

    test1:
        li t0, 0x111
        srli t2, t0, 2
        li t3, 0x044
        beq t2, t3, test2
        j Fail_Srli_1

    test2:
        li t0, 0x000
        srli t2, t0, 2
        li t3, 0x000
        beq t2, t3, test3
        j Fail_Srli_2

    test3:
        li t0, 0x100
        srli t2, t0, 4
        li t3, 0x010
        beq t2, t3, test4
        j Fail_Srli_3

    test4:
        li t0, 0x080
        srli t2, t0, 3
        li t3, 0x010
        beq t2, t3, test5
        j Fail_Srli_4

    test5:
        li t0, 0x001
        srli t2, t0, 1
        li t3, 0x000
        beq t2, t3, test6
        j Fail_Srli_5

    test6:
        li t0, 0xF00
        srli t2, t0, 4
        li t3, 0x0F0
        beq t2, t3, test7
        j Fail_Srli_6

    test7:
        li t0, 0xFFFFFFFF
        srli t2, t0, 31
        li t3, 0x001
        beq t2, t3, test8
        j Fail_Srli_7

    test8:
        li t0, 0x7FFFFFFF
        srli t2, t0, 1
        li t3, 0x3FFFFFFF
        beq t2, t3, test9
        j Fail_Srli_8

    test9:
        li t0, 0xAAAAAAAA
        srli t2, t0, 1
        li t3, 0x55555555
        beq t2, t3, test10
        j Fail_Srli_9

    test10:
        li t0, 0x00000010
        srli t2, t0, 4
        li t3, 0x00000001
        beq t2, t3, pass
        j Fail_Srli_10


Fail_Srli_1:
    li gp, 361
    j fail

Fail_Srli_2:
    li gp, 362
    j fail

Fail_Srli_3:
    li gp, 363
    j fail

Fail_Srli_4:
    li gp, 364
    j fail

Fail_Srli_5:
    li gp, 365
    j fail

Fail_Srli_6:
    li gp, 366
    j fail

Fail_Srli_7:
    li gp, 367
    j fail

Fail_Srli_8:
    li gp, 368
    j fail

Fail_Srli_9:
    li gp, 369
    j fail

Fail_Srli_10:
    li gp, 370
    j fail


pass:
    j return_srli_test
