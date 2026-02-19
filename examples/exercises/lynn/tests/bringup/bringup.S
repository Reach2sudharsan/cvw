// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

# R-type
.extern lw_test
.extern sw_test
.extern add_test
.extern sub_test
.extern slt_test
.extern xor_test
.extern or_test
.extern and_test

.extern sll_test
.extern srl_test
.extern sra_test
.extern sltu_test

# I-type
.extern addi_test
.extern slti_test
.extern xori_test
.extern ori_test
.extern andi_test
.extern slli_test
.extern srli_test
.extern srai_test
.extern sltui_test
.extern lb_test
.extern lbu_test
.extern lh_test
.extern lhu_test
.extern sb_test
.extern sh_test
.extern jalr_test

# B-type
.extern beq_test
.extern bne_test
.extern blt_test
.extern bltu_test
.extern bge_test
.extern bgeu_test

# J-type
.extern jal_test

# U-type
.extern lui_test
.extern auipc_test

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

    .globl return_sll_test
    .globl return_srl_test
    .globl return_sra_test
    .globl return_sltu_test

    # I-type
    .globl return_addi_test
    .globl return_slti_test
    .globl return_xori_test
    .globl return_ori_test
    .globl return_andi_test
    .globl return_slli_test
    .globl return_srli_test
    .globl return_srai_test
    .globl return_sltui_test
    .globl return_lb_test
    .globl return_lbu_test
    .globl return_lh_test
    .globl return_lhu_test
    .globl return_sb_test
    .globl return_sh_test
    .globl return_jalr_test

    # B-type
    .globl return_beq_test
    .globl return_bne_test
    .globl return_blt_test
    .globl return_bltu_test
    .globl return_bge_test
    .globl return_bgeu_test

    # J-type
    .globl return_jal_test

    # U-type
    .globl return_lui_test
    .globl return_auipc_test

    .type  main, @function

main:
    j lw_test // put which ever test you want --> if you run too many tests, then there will be memory overload

    return_lw_test:
        j pass


# # R-type

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
#         j sll_test

#     return_sll_test:
#         j srl_test

#     return_srl_test:
#         j sra_test

#     return_sra_test:
#         j sltu_test

#     return_sltu_test:
#         j addi_test

# # I-type
#     return_addi_test:
#         j slti_test

#     return_slti_test:
#         j xori_test

#     return_xori_test:
#         j ori_test

#     return_ori_test:
#         j andi_test

#     return_andi_test:
#         j beq_test

#     return_slli_test:
#         j beq_test

#     return_srli_test:
#         j srai_test

#     return_srai_test:
#         j sltui_test

#     return_sltui_test:
#         j lb_test

#     return_lb_test:
#         j lbu_test

#     return_lbu_test:
#         j lh_test

#     return_lh_test:
#         j lhu_test

#     return_lhu_test:
#         j sb_test

#     return_sb_test:
#         j sh_test

#     return_sh_test:
#         j jalr_test

#     return_jalr_test:
#         j beq_test


# # B-type
#     return_beq_test:
#         j bne_test

#     return_bne_test:
#         j blt_test

#     return_blt_test:
#         j bltu_test

#     return_bltu_test:
#         j bge_test

#     return_bge_test:
#         j bgeu_test

#     return_bgeu_test:
#         j pass

# # J-type
#     return_jal_test:
#         j lui_test

# # U-type
#     return_lui_test:
#         j auipc_test

#     return_auipc_test:
#         j pass
