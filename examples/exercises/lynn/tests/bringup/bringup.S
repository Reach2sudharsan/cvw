// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/20/2026

# R-type
.extern add_test
.extern sub_test
.extern slt_test
.extern xor_test
.extern or_test
.extern and_test
.extern sub_test
.extern beq_test
.extern slt_test

    .section .text.init
    .globl main


    # R-type
    .globl return_add_test
    .globl return_sub_test
    .globl return_slt_test
    .globl return_xor_test
    .globl return_or_test
    .globl return_and_test
    .globl return_sub_test
    .globl return_beq_test
    .globl return_slt_test
    .type  main, @function

main:
    j beq_test // put which ever test you want --> if you run too many tests, then there will be memory overload


# R-type

    # return_add_test:
    #     j sub_test

return_sub_test:
    j beq_test

return_beq_test:
    j slt_test

return_slt_test:
    j pass
