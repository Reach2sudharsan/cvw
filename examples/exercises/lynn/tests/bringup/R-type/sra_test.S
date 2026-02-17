// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_sra_test
.extern fail

.section .text.init
.globl sra_test
.type  sra_test, @function

sra_test:

    test1:
        li t0, 0x111
        li t1, 2
        sra t2, t0, t1
        li t3, 0x044
        beq t2, t3, test2
        j Fail_Sra_1

    test2:
        li t0, 0x000
        li t1, 2
        sra t2, t0, t1
        li t3, 0x000
        beq t2, t3, test3
        j Fail_Sra_2

    test3:
        li t0, 0x100
        li t1, 4
        sra t2, t0, t1
        li t3, 0x010
        beq t2, t3, test4
        j Fail_Sra_3

    test4:
        li t0, 0x080
        li t1, 3
        sra t2, t0, t1
        li t3, 0x010
        beq t2, t3, test5
        j Fail_Sra_4

    test5:
        li t0, 0x001
        li t1, 1
        sra t2, t0, t1
        li t3, 0x000
        beq t2, t3, test6
        j Fail_Sra_5

    test6:
        li t0, 0xF00
        li t1, 4
        sra t2, t0, t1
        li t3, 0x0F0
        beq t2, t3, test7
        j Fail_Sra_6

    test7:
        li t0, 0xFFFFFFFF
        li t1, 31
        sra t2, t0, t1
        li t3, 0xFFFFFFFF
        beq t2, t3, test8
        j Fail_Sra_7

    test8:
        li t0, 0x7FFFFFFF
        li t1, 1
        sra t2, t0, t1
        li t3, 0x3FFFFFFF
        beq t2, t3, test9
        j Fail_Sra_8

    test9:
        li t0, 0xAAAAAAAA
        li t1, 1
        sra t2, t0, t1
        li t3, 0xD5555555
        beq t2, t3, test10
        j Fail_Sra_9

    test10:
        li t0, 0x00000010
        li t1, 4
        sra t2, t0, t1
        li t3, 0x00000001
        beq t2, t3, pass
        j Fail_Sra_10


Fail_Sra_1:
    li gp, 181
    j fail

Fail_Sra_2:
    li gp, 182
    j fail

Fail_Sra_3:
    li gp, 183
    j fail

Fail_Sra_4:
    li gp, 184
    j fail

Fail_Sra_5:
    li gp, 185
    j fail

Fail_Sra_6:
    li gp, 186
    j fail

Fail_Sra_7:
    li gp, 187
    j fail

Fail_Sra_8:
    li gp, 188
    j fail

Fail_Sra_9:
    li gp, 189
    j fail

Fail_Sra_10:
    li gp, 190
    j fail



pass:
    j return_sra_test
