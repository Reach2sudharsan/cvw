// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/11/2026

# R-type
.extern lw_test
.extern sw_test
.extern add_test
.extern sub_test
.extern slt_test
.extern xor_test
.extern or_test
.extern and_test

# I-type
.extern addi_test
.extern slti_test
.extern xori_test
.extern andi_test

# B-type
.extern beq_test

# J-type
.extern jal_test

    .section .text.init
    .globl main


    # R-type
    .global return_lw_test
    .global return_sw_test
    .globl return_add_test
    .globl return_sub_test
    .globl return_slt_test
    .globl return_xor_test
    .globl return_or_test
    .globl return_and_test

    # I-type
    .globl return_addi_test
    .globl return_slti_test
    .globl return_xori_test
    .globl return_andi_test

    # B-type
    .globl return_beq_test

    # J-type
    .globl return_jal_test

    .type  main, @function

main:
    j beq_test // put which ever test you want --> if you run too many tests, then there will be memory overload



# R-type

#     return_lw_test:
#         j sw_test

#     return_sw_test:
#         j add_test

#     return_add_test:
#         j sub_test

#     return_sub_test:
#         j slt_test

#     return_slt_test:
#         j xor_test

#     return_xor_test:
#         j or_test

#     return_or_test:
#         j and_test

#     return_and_test:
#         j addi_test

# # I-type
#     return_addi_test:
#         j slti_test

#     return_slti_test:
#         j xori_test

#     return_xori_test:
#         j andi_test

#     return_andi_test:
#         j beq_test

# B-type
    # return_beq_test:
    #     j jal_test

# J-type
    # return_jal_test:
    #     j pass
