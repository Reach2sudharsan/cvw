// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_ori_test
.extern fail

    .section .text.init
    .globl ori_test
    .type  ori_test, @function

ori_test:
    test1:
        # 0x0F OR 0xF0 = 0xFF
        li   t0, 0x0F
        ori  t2, t0, 0xF0
        li   t3, 0xFF
        beq  t2, t3, test2
        j Fail_Ori_1

    test2:
        # 0x33 OR 0xCC = 0xFF
        li   t0, 0x33
        ori  t2, t0, 0xCC
        li   t3, 0xFF
        beq  t2, t3, test3
        j Fail_Ori_2

    test3:
        # 0x55 OR 0xAA = 0xFF
        li   t0, 0x55
        ori  t2, t0, 0xAA
        li   t3, 0xFF
        beq  t2, t3, test4
        j Fail_Ori_3

    test4:
        # 0x11 OR 0xEE = 0xFF
        li   t0, 0x11
        ori  t2, t0, 0xEE
        li   t3, 0xFF
        beq  t2, t3, test5
        j Fail_Ori_4

    test5:
        # 0x00 OR 0x00 = 0x00
        li   t0, 0x00
        ori  t2, t0, 0x00
        li   t3, 0x00
        beq  t2, t3, test6
        j Fail_Ori_5

    test6:
        # 0x0F OR 0x0F = 0x0F
        li   t0, 0x0F
        ori  t2, t0, 0x0F
        li   t3, 0x0F
        beq  t2, t3, test7
        j Fail_Ori_6

    test7:
        # 0xF0 OR 0x0F = 0xFF
        li   t0, 0xF0
        ori  t2, t0, 0x0F
        li   t3, 0xFF
        beq  t2, t3, test8
        j Fail_Ori_7

    test8:
        # 0xAA OR 0x55 = 0xFF
        li   t0, 0xAA
        ori  t2, t0, 0x55
        li   t3, 0xFF
        beq  t2, t3, test9
        j Fail_Ori_8

    test9:
        # 0x01 OR 0x02 = 0x03
        li   t0, 0x01
        ori  t2, t0, 0x02
        li   t3, 0x03
        beq  t2, t3, test10
        j Fail_Ori_9

    test10:
        # 0x80 OR 0x7F = 0xFF
        li   t0, 0x80
        ori  t2, t0, 0x7F
        li   t3, 0xFF
        beq  t2, t3, pass
        j Fail_Ori_10

    pass:
        j return_ori_test

Fail_Ori_1:
    li   gp, 341
    j    fail

Fail_Ori_2:
    li   gp, 342
    j    fail

Fail_Ori_3:
    li   gp, 343
    j    fail

Fail_Ori_4:
    li   gp, 344
    j    fail

Fail_Ori_5:
    li   gp, 345
    j    fail

Fail_Ori_6:
    li   gp, 346
    j    fail

Fail_Ori_7:
    li   gp, 347
    j    fail

Fail_Ori_8:
    li   gp, 348
    j    fail

Fail_Ori_9:
    li   gp, 349
    j    fail

Fail_Ori_10:
    li   gp, 350
    j    fail
