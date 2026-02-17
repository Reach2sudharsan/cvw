// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_jalr_test
.extern fail

.section .text.init
.globl jalr_test
.type  jalr_test, @function

.section .data
test_values:
    .word go1
    .word go2
    .word go3
    .word go4
    .word go5

.section .text.init

jalr_test:

    # Test 1: jalr → go1
    test1:
        li t1, 0
        lw t0, test_values
        jalr ra, 0(t0)
        li t2, 1
        beq t1, t2, test2
        j Fail_Jalr_1

    # Test 2: jalr → go2
    test2:
        li t1, 0
        jalr ra, 8(t0)
        li t2, 2
        beq t1, t2, test3
        j Fail_Jalr_2

    # Test 3: direct address load → go3
    test3:
        li t1, 0
        la t0, go3
        jalr ra, 0(t0)
        li t2, 3
        beq t1, t2, test4
        j Fail_Jalr_3

    # Test 4: nested jump (go4 → go1)
    test4:
        li t1, 0
        la t0, go4
        jalr ra, 0(t0)
        li t2, 1
        beq t1, t2, test5
        j Fail_Jalr_4

    # Test 5: verify ra overwritten correctly
    test5:
        li t1, 0
        la t0, go1
        jalr ra, 0(t0)
        mv t3, ra
        bne t3, zero, test6
        j Fail_Jalr_5

    # Test 6: multiple consecutive jalr calls
    test6:
        li t1, 0
        la t0, go2
        jalr ra, 0(t0)
        jalr ra, 0(t0)
        li t2, 2
        beq t1, t2, test7
        j Fail_Jalr_6

    # Test 7: computed offset jump
    test7:
        li t1, 0
        lw t0, test_values
        addi t0, t0, 16     # move to go3
        jalr ra, 0(t0)
        li t2, 3
        beq t1, t2, test8
        j Fail_Jalr_7

    # Test 8: jump using different link register
    test8:
        li t1, 0
        la t0, go5
        jalr t4, 0(t0)      # link into t4 instead of ra
        li t2, 1
        beq t1, t2, test9
        j Fail_Jalr_8

    # Test 9: jump to go2 via la
    test9:
        li t1, 0
        la t0, go2
        jalr ra, 0(t0)
        li t2, 2
        beq t1, t2, test10
        j Fail_Jalr_9

    # Test 10: final confirmation jump
    test10:
        li t1, 0
        la t0, go3
        jalr ra, 0(t0)
        li t2, 3
        beq t1, t2, pass
        j Fail_Jalr_10


# ---- Target Functions ----

go1:
    li t1, 1
    ret

go2:
    li t1, 2
    ret

go3:
    li t1, 3
    ret

go4:
    la t0, go1
    addi sp, sp, -8
    sw ra, 0(sp)
    jalr ra, 0(t0)
    lw ra, 0(sp)
    addi sp, sp, 8
    ret

go5:
    li t1, 1
    jalr x0, 0(t4)   # return using t4



# ---- Pass / Fail ----

pass:
    j return_jalr_test

Fail_Jalr_1:
    li gp, 451
    j fail

Fail_Jalr_2:
    li gp, 452
    j fail

Fail_Jalr_3:
    li gp, 453
    j fail

Fail_Jalr_4:
    li gp, 454
    j fail

Fail_Jalr_5:
    li gp, 455
    j fail

Fail_Jalr_6:
    li gp, 456
    j fail

Fail_Jalr_7:
    li gp, 457
    j fail

Fail_Jalr_8:
    li gp, 458
    j fail

Fail_Jalr_9:
    li gp, 459
    j fail

Fail_Jalr_10:
    li gp, 460
    j fail
