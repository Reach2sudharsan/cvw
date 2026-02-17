// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_sltu_test
.extern fail

    .section .text.init
    .globl sltu_test
    .type  sltu_test, @function

sltu_test:
    test1:
        # 0x05 < 0x0A = 1
        li   t0, 0x05
        li   t1, 0x0A
        sltu  t2, t0, t1
        li   t3, 1
        beq  t2, t3, test2
        j Fail_Sltu_1

    test2:
        # 0x0A < 0x05 = 0
        li   t0, 0x0A
        li   t1, 0x05
        sltu  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test3
        j Fail_Sltu_2

    test3:
        # 0x10 < 0x10 = 0
        li   t0, 0x10
        li   t1, 0x10
        sltu  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test4
        j Fail_Sltu_3

    test4:
        # 0x00 < 0x01 = 1
        li   t0, 0x00
        li   t1, 0x01
        sltu  t2, t0, t1
        li   t3, 1
        beq  t2, t3, test5
        j Fail_Sltu_4

    test5:
        # 0x01 < 0x00 = 0
        li   t0, 0x01
        li   t1, 0x00
        sltu  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test6
        j Fail_Sltu_5

    test6:
        # -1 < 0 = 1
        li   t0, -1
        li   t1, 0
        sltu  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test7
        j Fail_Sltu_6

    test7:
        # 0 < -1 = 0
        li   t0, 0
        li   t1, -1
        sltu  t2, t0, t1
        li   t3, 1
        beq  t2, t3, test8
        j Fail_Sltu_7

    test8:
        # -5 < -3 = 1
        li   t0, -5
        li   t1, -3
        sltu  t2, t0, t1
        li   t3, 1
        beq  t2, t3, test9
        j Fail_Sltu_8

    test9:
        # -3 < -5 = 0
        li   t0, -3
        li   t1, -5
        sltu  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test10
        j Fail_Sltu_9

    test10:
        # 127 < -128 = 0
        li   t0, 127
        li   t1, -128
        sltu  t2, t0, t1
        li   t3, 1
        beq  t2, t3, pass
        j Fail_Sltu_10

    pass:
        j return_sltu_test

Fail_Sltu_1:
    li   gp, 191
    j    fail

Fail_Sltu_2:
    li   gp, 192
    j    fail

Fail_Sltu_3:
    li   gp, 193
    j    fail

Fail_Sltu_4:
    li   gp, 194
    j    fail

Fail_Sltu_5:
    li   gp, 195
    j    fail

Fail_Sltu_6:
    li   gp, 196
    j    fail

Fail_Sltu_7:
    li   gp, 197
    j    fail

Fail_Sltu_8:
    li   gp, 198
    j    fail

Fail_Sltu_9:
    li   gp, 199
    j    fail

Fail_Sltu_10:
    li   gp, 200
    j    fail
