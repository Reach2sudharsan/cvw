// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/11/2026

.extern return_xor_test
.extern fail

    .section .text.init
    .globl xor_test
    .type  xor_test, @function

xor_test:
    test1:
        # 0x00 XOR 0x00 = 0x00
        li   t0, 0x00
        li   t1, 0x00
        xor  t2, t0, t1
        li   t3, 0x00
        beq  t2, t3, test2
        j Fail_Xor_1

    test2:
        # 0x0F XOR 0xF0 = 0xFF
        li   t0, 0x0F
        li   t1, 0xF0
        xor  t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, test3
        j Fail_Xor_2

    test3:
        # 0x33 XOR 0xCC = 0xFF
        li   t0, 0x33      # 00110011
        li   t1, 0xCC      # 11001100
        xor  t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, test4
        j Fail_Xor_3

    test4:
        # 0x55 XOR 0xAA = 0xFF
        li   t0, 0x55
        li   t1, 0xAA
        xor  t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, test5
        j Fail_Xor_4

    test5:
        # 0x11 XOR 0xEE = 0xFF
        li   t0, 0x11
        li   t1, 0xEE
        xor  t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, test6
        j Fail_Xor_5

    test6:
        # 0x0F XOR 0x0F = 0x00
        li   t0, 0x0F
        li   t1, 0x0F
        xor  t2, t0, t1
        li   t3, 0x00
        beq  t2, t3, test7
        j Fail_Xor_6

    test7:
        # 0xFF XOR 0xFF = 0x00
        li   t0, 0xFF
        li   t1, 0xFF
        xor  t2, t0, t1
        li   t3, 0x00
        beq  t2, t3, test8
        j Fail_Xor_7

    test8:
        # 0xAA XOR 0x55 = 0xFF
        li   t0, 0xAA
        li   t1, 0x55
        xor  t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, test9
        j Fail_Xor_8

    test9:
        # 0x01 XOR 0x02 = 0x03
        li   t0, 0x01
        li   t1, 0x02
        xor  t2, t0, t1
        li   t3, 0x03
        beq  t2, t3, test10
        j Fail_Xor_9

    test10:
        # 0x80 XOR 0x7F = 0xFF
        li   t0, 0x80
        li   t1, 0x7F
        xor  t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, pass
        j Fail_Xor_10

    pass:
        j return_xor_test

Fail_Xor_1:
    li   gp, 401
    j    fail

Fail_Xor_2:
    li   gp, 402
    j    fail

Fail_Xor_3:
    li   gp, 403
    j    fail

Fail_Xor_4:
    li   gp, 404
    j    fail

Fail_Xor_5:
    li   gp, 405
    j    fail

Fail_Xor_6:
    li   gp, 406
    j    fail

Fail_Xor_7:
    li   gp, 407
    j    fail

Fail_Xor_8:
    li   gp, 408
    j    fail

Fail_Xor_9:
    li   gp, 409
    j    fail

Fail_Xor_10:
    li   gp, 410
    j    fail
