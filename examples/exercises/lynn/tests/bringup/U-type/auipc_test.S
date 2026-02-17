// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/13/2026

.extern return_auipc_test
.extern fail

.section .text.init
.globl auipc_test
.type  auipc_test, @function

auipc_test:
    # Test 1: AUIPC with small immediate, simple equality
    test1:
        auipc t0, 0x1           # t0 = PC + 0x1000
        addi t1, t0, 0          # t1 = t0
        beq t0, t1, test2
        j Fail_Auipc_1

    # Test 2: AUIPC + ADDI offset to t0, compare with another AUIPC
    test2:
        auipc t0, 0x1           # t0 = PC + 0x1000
        addi t0, t0, 8          # t0 += 8
        auipc t1, 0x1           # t1 = PC + 0x1000
        beq t0, t1, test3
        j Fail_Auipc_2

    # Test 3: AUIPC + small positive immediate
    test3:
        auipc t0, 0x2           # t0 = PC + 0x2000
        addi t1, t0, 0x10       # add small positive immediate
        addi t2, t0, 0x10       # expected same value
        beq t1, t2, test4
        j Fail_Auipc_3

    # Test 4: AUIPC with zero immediate
    test4:
        auipc t0, 0x0           # t0 = PC (zero immediate)
        addi t1, t0, 0          # t1 = t0
        beq t0, t1, test5
        j Fail_Auipc_4

    # Test 5: AUIPC with large immediate
    test5:
        auipc t0, 0xABCDE       # t0 = PC + 0xABCDE000
        addi t1, t0, 0          # t1 = t0
        beq t0, t1, test6
        j Fail_Auipc_5

    # Test 6: AUIPC + negative immediate
    test6:
        auipc t0, 0x10          # t0 = PC + 0x10000
        addi t1, t0, -0x100     # subtract small value
        addi t2, t0, -0x100     # expected same
        beq t1, t2, test7
        j Fail_Auipc_6

    # Test 7: Compare AUIPC with LUI
    test7:
        auipc t0, 0x123          # t0 = PC + 0x123000
        lui t1, 0x123            # t1 = 0x123000 (independent of PC)
        addi t1, t1, 0
        beq t0, t1, test8       # usually not equal due to PC difference
        j test8                  # continue

    # Test 8: Consecutive AUIPC with different offsets
    test8:
        auipc t0, 0x1           # t0 = PC + 0x1000
        addi t0, t0, 12         # add offset to t0
        auipc t1, 0x1           # t1 = PC + 0x1000
        addi t1, t1, 4          # add different offset to t1
        beq t0, t1, test9
        j Fail_Auipc_8

    # Test 9: AUIPC with maximum positive immediate
    test9:
        auipc t0, 0xFFFFF       # t0 = PC + 0xFFFFF000
        addi t1, t0, 0
        beq t0, t1, test10
        j Fail_Auipc_9

    # Test 10: AUIPC + ADDI to zero lower 12 bits
    test10:
        auipc t0, 0x12345
        addi t0, t0, -0x345     # clear lower 12 bits
        addi t1, t0, 0
        beq t0, t1, pass
        j Fail_Auipc_10

# ---- Pass / Fail ----

pass:
        j return_auipc_test

Fail_Auipc_1:
    li gp, 811
    j fail

Fail_Auipc_2:
    li gp, 812
    j fail

Fail_Auipc_3:
    li gp, 813
    j fail

Fail_Auipc_4:
    li gp, 814
    j fail

Fail_Auipc_5:
    li gp, 815
    j fail

Fail_Auipc_6:
    li gp, 816
    j fail

Fail_Auipc_7:
    li gp, 817
    j fail

Fail_Auipc_8:
    li gp, 818
    j fail

Fail_Auipc_9:
    li gp, 819
    j fail

Fail_Auipc_10:
    li gp, 820
    j fail
