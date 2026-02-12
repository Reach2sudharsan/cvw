// C Runtime entry point
// Sudharsan Gopalakrishnan
// 2/12/2026

.extern return_jal_test
.extern fail

.section .text.init
.globl jal_test
.type  jal_test, @function

jal_test:
    lui  sp, 0x80002     # initialize stack pointer to 0x80002000

# Test 1: basic jal jump + return
test1:
    la   t0, after1     # expected return address
    jal  ra, target1    # jump
after1:
    beq  ra, t0, test2  # if ra == expected, pass test
    j    Fail_Jal_1     # otherwise, fail

target1:
    ret

# Test 2: nested jal calls
test2:
    la   t0, after2     # expected return address of test2
    addi sp, sp, -4     # allocate stack space
    sw   t0, 0(sp)      # save expected address
    jal  ra, target2a   # first jump
after2:
    lw   t0, 0(sp)      # restore expected address
    addi sp, sp, 4      # deallocate stack space
    beq  ra, t0, test3
    j    Fail_Jal_2

target2a:
    addi sp, sp, -4     # save ra before nested call
    sw   ra, 0(sp)
    jal  ra, target2b   # nested jump
    lw   ra, 0(sp)      # restore ra
    addi sp, sp, 4
    ret

target2b:
    li   t1, 42         # arbitrary operation
    ret

# Test 3: nested jal
test3:
    jal  ra, target3a
after3:
    j    test4

target3a:
    addi sp, sp, -4     # make space on stack
    sw   ra, 0(sp)      # save ra
    jal  ra, target3b   # nested call
    lw   ra, 0(sp)      # restore ra
    addi sp, sp, 4      # restore stack
    ret

target3b:
    li   t0, 123
    ret

# Test 4: jal over code

test4:
    li   t0, 0          # initialize t0 to 0
    jal  ra, target4
    li   t0, 0xDEAD     # this line is never executed
after4:                 # return lands here
    beq  t0, x0, test5  # if t0 still 0, pass
    j    Fail_Jal_4

target4:
    j    after4         # jump directly to after4, skipping the 0xDEAD line

# Test 5: consecutive jals
test5:
    addi sp, sp, -4     # save ra for outer call
    sw   ra, 0(sp)
    jal  ra, target5a
    lw   ra, 0(sp)      # restore ra
    addi sp, sp, 4
after5:
    li   t1, 0x55
    beq  t0, t1, test6  # check if t0 was set correctly
    j    Fail_Jal_5

target5a:
    addi sp, sp, -4     # save ra for nested call
    sw   ra, 0(sp)
    jal  ra, target5b
    lw   ra, 0(sp)      # restore ra
    addi sp, sp, 4
    ret

target5b:
    li   t0, 0x55
    ret

# Test 6: jal with dummy instruction in between
test6:
    li   t0, 0          # initialize t0
    nop
    jal  ra, target6
after6:
    li   t1, 0x42
    beq  t0, t1, test7  # check if t0 was modified
    j    Fail_Jal_6

target6:
    li   t0, 0x42
    ret


# Test 7: backward jump (negative offset)
test7:
    j    test7_start    # jump forward to start

test7_target:           # target is BEFORE the call site
    li   t0, 0x77       # set a marker value
    ret

test7_start:
    li   t0, 0          # initialize t0
    jal  ra, test7_target   # jump BACKWARD to test7_target
after7:
    li   t1, 0x77
    beq  t0, t1, test8  # if t0 was set to 0x77, pass
    j    Fail_Jal_7

# Test 8: jal modifies t0 in target
test8:
    li   t0, 0
    jal  ra, target8
after8:
    li   t1, 99
    beq  t0, t1, test9
    j    Fail_Jal_8

target8:
    li   t0, 99
    ret

# Test 9: jal to same target multiple times
test9:
    jal  ra, target9
    jal  ra, target9
after9:
    beq  t0, x0, test10
    j    Fail_Jal_9

target9:
    li   t0, 0
    ret

# Test 10: jal with t0 and t1 set before return
test10:
    li   t0, 1
    li   t1, 2
    jal  ra, target10
after10:
    li   t1, 3          # expected result
    beq  t0, t1, pass
    j    Fail_Jal_10

target10:
    add  t0, t0, t1     # t0 = 1 + 2 = 3
    ret

# Pass / Fail
pass:
    j return_jal_test

Fail_Jal_1:
    li gp, 801
    j fail

Fail_Jal_2:
    li gp, 802
    j fail

Fail_Jal_3:
    li gp, 803
    j fail

Fail_Jal_4:
    li gp, 804
    j fail

Fail_Jal_5:
    li gp, 805
    j fail

Fail_Jal_6:
    li gp, 806
    j fail

Fail_Jal_7:
    li gp, 807
    j fail

Fail_Jal_8:
    li gp, 808
    j fail

Fail_Jal_9:
    li gp, 809
    j fail

Fail_Jal_10:
    li gp, 810
    j fail
