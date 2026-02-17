// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/13/2026

.extern return_lui_test
.extern fail

.section .text.init
.globl lui_test
.type  lui_test, @function

lui_test:

    # Test 1: LUI + ADDI to form 0x111110FF
    test1:
        li t0, 0x111110FF
        lui t1, 0x11111
        addi t1, t1, 0xFF
        beq t0, t1, test2
        j Fail_Lui_1

    # Test 2: LUI only (lower 12 bits zero)
    test2:
        lui t0, 0x11111
        li t1, 0x11111000
        beq t0, t1, test3
        j Fail_Lui_2

    # Test 3: LUI max value (0xFFFFF << 12)
    test3:
        lui t0, 0xFFFFF
        li t1, 0xFFFFF000
        beq t0, t1, test4
        j Fail_Lui_3

    # Test 4: LUI min value (0x00000 << 12 = 0)
    test4:
        lui t0, 0x0
        li t1, 0x0
        beq t0, t1, test5
        j Fail_Lui_4

    # Test 5: LUI with negative-looking value (0x80000 << 12)
    test5:
        lui t0, 0x80000
        li t1, 0x80000000
        beq t0, t1, test6
        j Fail_Lui_5

    # Test 6: LUI + ADDI with signed lower 12-bit (0xFFF = -1)
    test6:
        lui t0, 0x12345
        addi t0, t0, -1       # 0x12344FFF
        li t1, 0x12344FFF
        beq t0, t1, test7
        j Fail_Lui_6

    # Test 7: LUI + ADDI = zero lower 12 bits
    test7:
        lui t0, 0xABCDE
        addi t0, t0, 0        # 0xABCDE000
        li t1, 0xABCDE000
        beq t0, t1, test8
        j Fail_Lui_7

    # Test 8: LUI + ADDI small positive immediate
    test8:
        lui t0, 0x1
        addi t0, t0, 0x10     # 0x00001010
        li t1, 0x00001010
        beq t0, t1, test10
        j Fail_Lui_8

    # Test 9: LUI sets upper 20 bits, ADDI adds positive lower 12-bit value
    test9:
        lui t0, 0x001F       # load upper 20 bits: 0x001F000
        addi t0, t0, 0x0F0   # add lower 12 bits: 0x0F0
        li t1, 0x001FF00     # expected value
        beq t0, t1, test10   # verify result
        j Fail_Lui_9

    # Test 10: LUI with maximum upper 20 bits + ORI to set lower 12-bit value
    test10:
        lui t0, 0xFFFFF      # load upper 20 bits: 0xFFFFF000
        ori t0, t0, 0x0FF    # set lower 12 bits: 0x0FF
        li t1, 0xFFFFF0FF    # expected value
        beq t0, t1, pass     # verify result
        j Fail_Lui_10



# ---- Pass / Fail ----

pass:
        j return_lui_test

Fail_Lui_1:
    li gp, 801
    j fail

Fail_Lui_2:
    li gp, 802
    j fail

Fail_Lui_3:
    li gp, 803
    j fail

Fail_Lui_4:
    li gp, 804
    j fail

Fail_Lui_5:
    li gp, 805
    j fail

Fail_Lui_6:
    li gp, 806
    j fail

Fail_Lui_7:
    li gp, 807
    j fail

Fail_Lui_8:
    li gp, 808
    j fail

Fail_Lui_9:
    li gp, 809
    j fail

Fail_Lui_10:
    li gp, 810
    j fail
