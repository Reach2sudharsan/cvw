// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_xori_test
.extern fail

    .section .text.init
    .globl xori_test
    .type  xori_test, @function

xori_test:
    test1:
        # 0x00 XOR 0x00 = 0x00
        li   t0, 0x00
        xori t2, t0, 0x00
        li   t3, 0x00
        beq  t2, t3, test2
        j Fail_Xori_1

    test2:
        # 0x0F XOR 0xF0 = 0xFF
        li   t0, 0x0F
        xori t2, t0, 0xF0
        li   t3, 0xFF
        beq  t2, t3, test3
        j Fail_Xori_2

    test3:
        # 0x33 XOR 0xCC = 0xFF
        li   t0, 0x33
        xori t2, t0, 0xCC
        li   t3, 0xFF
        beq  t2, t3, test4
        j Fail_Xori_3

    test4:
        # 0x55 XOR 0xAA = 0xFF
        li   t0, 0x55
        xori t2, t0, 0xAA
        li   t3, 0xFF
        beq  t2, t3, test5
        j Fail_Xori_4

    test5:
        # 0x11 XOR 0xEE = 0xFF
        li   t0, 0x11
        xori t2, t0, 0xEE
        li   t3, 0xFF
        beq  t2, t3, test6
        j Fail_Xori_5

    test6:
        # 0x0F XOR 0x0F = 0x00
        li   t0, 0x0F
        xori t2, t0, 0x0F
        li   t3, 0x00
        beq  t2, t3, test7
        j Fail_Xori_6

    test7:
        # 0xFF XOR 0xFF = 0x00
        li   t0, 0xFF
        xori t2, t0, 0xFF
        li   t3, 0x00
        beq  t2, t3, test8
        j Fail_Xori_7

    test8:
        # 0xAA XOR 0x55 = 0xFF
        li   t0, 0xAA
        xori t2, t0, 0x55
        li   t3, 0xFF
        beq  t2, t3, test9
        j Fail_Xori_8

    test9:
        # 0x01 XOR 0x02 = 0x03
        li   t0, 0x01
        xori t2, t0, 0x02
        li   t3, 0x03
        beq  t2, t3, test10
        j Fail_Xori_9

    test10:
        # 0x80 XOR 0x7F = 0xFF
        li   t0, 0x80
        xori t2, t0, 0x7F
        li   t3, 0xFF
        beq  t2, t3, pass
        j Fail_Xori_10

pass:
        j return_xori_test

Fail_Xori_1:
    li   gp, 411
    j    fail

Fail_Xori_2:
    li   gp, 412
    j    fail

Fail_Xori_3:
    li   gp, 413
    j    fail

Fail_Xori_4:
    li   gp, 414
    j    fail

Fail_Xori_5:
    li   gp, 415
    j    fail

Fail_Xori_6:
    li   gp, 416
    j    fail

Fail_Xori_7:
    li   gp, 417
    j    fail

Fail_Xori_8:
    li   gp, 418
    j    fail

Fail_Xori_9:
    li   gp, 419
    j    fail

Fail_Xori_10:
    li   gp, 420
    j    fail
