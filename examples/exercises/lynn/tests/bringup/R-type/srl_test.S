// C Runtime entry point
// Sudharsan Gopalakrishnan
// 2/12/2026

.extern return_srl_test
.extern fail

.section .text.init
.globl srl_test
.type  srl_test, @function

srl_test:

    test1:
        li t0, 0x111
        li t1, 2
        srl t2, t0, t1
        li t3, 0x044
        beq t2, t3, test2
        j Fail_Srl_1

    test2:
        li t0, 0x000
        li t1, 2
        srl t2, t0, t1
        li t3, 0x000
        beq t2, t3, test3
        j Fail_Srl_2

    test3:
        li t0, 0x100
        li t1, 4
        srl t2, t0, t1
        li t3, 0x010
        beq t2, t3, test4
        j Fail_Srl_3

    test4:
        li t0, 0x080
        li t1, 3
        srl t2, t0, t1
        li t3, 0x010
        beq t2, t3, test5
        j Fail_Srl_4

    test5:
        li t0, 0x001
        li t1, 1
        srl t2, t0, t1
        li t3, 0x000
        beq t2, t3, test6
        j Fail_Srl_5

    test6:
        li t0, 0xF00
        li t1, 4
        srl t2, t0, t1
        li t3, 0x0F0
        beq t2, t3, test7
        j Fail_Srl_6

    test7:
        li t0, 0xFFFFFFFF
        li t1, 31
        srl t2, t0, t1
        li t3, 0x001
        beq t2, t3, test8
        j Fail_Srl_7

    test8:
        li t0, 0x7FFFFFFF
        li t1, 1
        srl t2, t0, t1
        li t3, 0x3FFFFFFF
        beq t2, t3, test9
        j Fail_Srl_8

    test9:
        li t0, 0xAAAAAAAA
        li t1, 1
        srl t2, t0, t1
        li t3, 0x55555555
        beq t2, t3, test10
        j Fail_Srl_9

    test10:
        li t0, 0x00000010
        li t1, 4
        srl t2, t0, t1
        li t3, 0x00000001
        beq t2, t3, pass
        j Fail_Srl_10


Fail_Srl_1:
    li gp, 171
    j fail

Fail_Srl_2:
    li gp, 172
    j fail

Fail_Srl_3:
    li gp, 173
    j fail

Fail_Srl_4:
    li gp, 174
    j fail

Fail_Srl_5:
    li gp, 175
    j fail

Fail_Srl_6:
    li gp, 176
    j fail

Fail_Srl_7:
    li gp, 177
    j fail

Fail_Srl_8:
    li gp, 178
    j fail

Fail_Srl_9:
    li gp, 179
    j fail

Fail_Srl_10:
    li gp, 180
    j fail


pass:
    j return_srl_test
