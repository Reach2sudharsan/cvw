// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/11/2026

.extern return_addi_test
.extern fail

    .section .text.init
    .globl addi_test
    .type  addi_test, @function

addi_test:
    test1:
        li   t0, 7
        addi t2, t0, 5        # 7 + 5 = 12
        li   t3, 12
        beq  t2, t3, test2
        j Fail_Addi_1

    test2:
        li   t0, 19
        addi t2, t0, 23       # 19 + 23 = 42
        li   t3, 42
        beq  t2, t3, test3
        j Fail_Addi_2

    test3:
        li   t0, 20
        addi t2, t0, 40       # 20 + 40 = 60
        li   t3, 60
        beq  t2, t3, test4
        j Fail_Addi_3

    test4:
        li   t0, 100
        addi t2, t0, 200      # 100 + 200 = 300
        li   t3, 300
        beq  t2, t3, test5
        j Fail_Addi_4

    test5:
        li   t0, 0
        addi t2, t0, 0        # 0 + 0 = 0
        li   t3, 0
        beq  t2, t3, test6
        j Fail_Addi_5

    test6:
        li   t0, 1
        addi t2, t0, 1        # 1 + 1 = 2
        li   t3, 2
        beq  t2, t3, test7
        j Fail_Addi_6

    test7:
        li   t0, 127
        addi t2, t0, 1        # 127 + 1 = 128
        li   t3, 128
        beq  t2, t3, test8
        j Fail_Addi_7

    test8:
        li   t0, 50
        addi t2, t0, 75       # 50 + 75 = 125
        li   t3, 125
        beq  t2, t3, test9
        j Fail_Addi_8

    test9:
        li   t0, 255
        addi t2, t0, 1        # 255 + 1 = 256
        li   t3, 256
        beq  t2, t3, test10
        j Fail_Addi_9

    test10:
        li   t0, 1000
        addi t2, t0, 2000     # 1000 + 2000 = 3000
        li   t3, 3000
        beq  t2, t3, pass
        j Fail_Addi_10

pass:
        j return_addi_test

Fail_Addi_1:
    li   gp, 311
    j    fail

Fail_Addi_2:
    li   gp, 312
    j    fail

Fail_Addi_3:
    li   gp, 313
    j    fail

Fail_Addi_4:
    li   gp, 314
    j    fail

Fail_Addi_5:
    li   gp, 315
    j    fail

Fail_Addi_6:
    li   gp, 316
    j    fail

Fail_Addi_7:
    li   gp, 317
    j    fail

Fail_Addi_8:
    li   gp, 318
    j    fail

Fail_Addi_9:
    li   gp, 319
    j    fail

Fail_Addi_10:
    li   gp, 320
    j    fail
