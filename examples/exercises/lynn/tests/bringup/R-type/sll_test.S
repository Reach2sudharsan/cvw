// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_sll_test
.extern fail

    .section .text.init
    .globl sll_test
    .type  sll_test, @function

sll_test:
    test1:
        li t0, 0x001
        li t1, 4
        sll t2, t0, t1
        li t3, 0x010
        beq t2, t3, test2
        j Fail_Sll_1

    test2:
        li t0, 0x002
        li t1, 2
        sll t2, t0, t1
        li t3, 0x008
        beq t2, t3, test3
        j Fail_Sll_2

    test3:
        li t0, 0x004
        li t1, 1
        sll t2, t0, t1
        li t3, 0x008
        beq t2, t3, test4
        j Fail_Sll_3

    test4:
        li t0, 0x003
        li t1, 1
        sll t2, t0, t1
        li t3, 0x006
        beq t2, t3, test5
        j Fail_Sll_4

    test5:
        li t0, 0x005
        li t1, 2
        sll t2, t0, t1
        li t3, 0x014
        beq t2, t3, test6
        j Fail_Sll_5

    test6:
        li t0, 0x00F
        li t1, 1
        sll t2, t0, t1
        li t3, 0x01E
        beq t2, t3, test7
        j Fail_Sll_6

    test7:
        li t0, 0x008
        li t1, 3
        sll t2, t0, t1
        li t3, 0x040
        beq t2, t3, test8
        j Fail_Sll_7

    test8:
        li t0, 0x001
        li t1, 4
        sll t2, t0, t1
        li t3, 0x010
        beq t2, t3, test9
        j Fail_Sll_8

    test9:
        li t0, 0x002
        li t1, 3
        sll t2, t0, t1
        li t3, 0x010
        beq t2, t3, test10
        j Fail_Sll_9

    test10:
        li t0, 0x007
        li t1, 1
        sll t2, t0, t1
        li t3, 0x00E
        beq t2, t3, pass
        j Fail_Sll_10

    // If any test fails, jump to the corresponding Fail label
Fail_Sll_1:
    li   gp, 161
    j    fail

Fail_Sll_2:
    li   gp, 162
    j    fail

Fail_Sll_3:
    li   gp, 163
    j    fail

Fail_Sll_4:
    li   gp, 164
    j    fail

Fail_Sll_5:
    li   gp, 165
    j    fail

Fail_Sll_6:
    li   gp, 166
    j    fail

Fail_Sll_7:
    li   gp, 167
    j    fail

Fail_Sll_8:
    li   gp, 168
    j    fail

Fail_Sll_9:
    li   gp, 169
    j    fail

Fail_Sll_10:
    li   gp, 170
    j    fail

pass:
    j return_sll_test
