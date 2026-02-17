// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_add_test
.extern fail

    .section .text.init
    .globl add_test
    .type  add_test, @function

add_test:
    test1:
        # 7 + 5 = 12
        li   t0, 7
        li   t1, 5
        add  t2, t0, t1
        li   t3, 12
        beq  t2, t3, test2
        j Fail_Add_1

    test2:
        # 19 + 23 = 42
        li   t0, 19
        li   t1, 23
        add  t2, t0, t1
        li   t3, 42
        beq  t2, t3, test3
        j Fail_Add_2

    test3:
        # 20 + 40 = 60
        li   t0, 20
        li   t1, 40
        add  t2, t0, t1
        li   t3, 60
        beq  t2, t3, test4
        j Fail_Add_3

    test4:
        # 100 + 200 = 300
        li   t0, 100
        li   t1, 200
        add  t2, t0, t1
        li   t3, 300
        beq  t2, t3, test5
        j Fail_Add_4

    test5:
        # 0 + 0 = 0
        li   t0, 0
        li   t1, 0
        add  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test6
        j Fail_Add_5

    test6:
        # 1 + 1 = 2
        li   t0, 1
        li   t1, 1
        add  t2, t0, t1
        li   t3, 2
        beq  t2, t3, test7
        j Fail_Add_6

    test7:
        # 127 + 1 = 128
        li   t0, 127
        li   t1, 1
        add  t2, t0, t1
        li   t3, 128
        beq  t2, t3, test8
        j Fail_Add_7

    test8:
        # 50 + 75 = 125
        li   t0, 50
        li   t1, 75
        add  t2, t0, t1
        li   t3, 125
        beq  t2, t3, test9
        j Fail_Add_8

    test9:
        # 255 + 1 = 256
        li   t0, 255
        li   t1, 1
        add  t2, t0, t1
        li   t3, 256
        beq  t2, t3, test10
        j Fail_Add_9

    test10:
        # 1000 + 2000 = 3000
        li   t0, 1000
        li   t1, 2000
        add  t2, t0, t1
        li   t3, 3000
        beq  t2, t3, pass
        j Fail_Add_10

    pass:
        j return_add_test

Fail_Add_1:
    li   gp, 101
    j    fail

Fail_Add_2:
    li   gp, 102
    j    fail

Fail_Add_3:
    li   gp, 103
    j    fail

Fail_Add_4:
    li   gp, 104
    j    fail

Fail_Add_5:
    li   gp, 105
    j    fail

Fail_Add_6:
    li   gp, 106
    j    fail

Fail_Add_7:
    li   gp, 107
    j    fail

Fail_Add_8:
    li   gp, 108
    j    fail

Fail_Add_9:
    li   gp, 109
    j    fail

Fail_Add_10:
    li   gp, 110
    j    fail
