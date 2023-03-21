        .text
        .align 2
        .type   volk_32fc_x2_dot_prod_32fc_sifive_u74, @function
        .global volk_32fc_x2_dot_prod_32fc_sifive_u74

	#
	# RISC-V implementation using only I and F sets.
	# About 24% faster than GCC.
	#
	# The generic C code is 2x unrolled, but its main flaw
	# seems to be not properly fusing into fmadd and fnmsub.
	#
volk_32fc_x2_dot_prod_32fc_sifive_u74:
	# a0: out
	# a1: in
	# a2: taps
	# a3: points
	beqz a3, .empty

	slli a5,a3,3
	add  a5,a5,a1

	# a5: one past the end of input

	# Output regs.
	fmv.w.x ft0,zero
	fmv.w.x ft1,zero
	fmv.w.x ft2,zero
	fmv.w.x ft3,zero
	fmv.w.x ft4,zero
	fmv.w.x ft5,zero
	fmv.w.x ft6,zero
	fmv.w.x ft7,zero

	addi     a1,a1,16          # free ride in pipeline A.
	addi     a2,a2,16          # free ride in pipeline A.
	bgt      a1,a5,.endloop

	# Main loop two complexes at a time.
.loop:
	# Load input in order of when it'll be used.
	# flw has 2 cycle latency, 1 cycle repeat.
	flw  ft8,-16(a1) # in0
	flw  ft9,-16(a2) # tp0
	flw  ft10,-12(a2) # tp1
	flw  ft11,-12(a1) # in1

	# None of the fused multiple-adds have a write-read stall.
	# FMA, like mul and add, have 5 cycle latency, 1 cycle repeat.
	fmadd.s  ft0,ft8, ft9, ft0 # in0*tp0
	flw  fa0,-8(a1)            # in0
	fmadd.s  ft1,ft8, ft10,ft1 # in0*tp1
	flw  fa1,-8(a2)            # tp0
	fmadd.s  ft2,ft11,ft9, ft2 # in1*tp0
	flw  fa2,-4(a2)            # tp1
	fnmsub.s ft3,ft11,ft10,ft3 # -in1*tp1
	flw  fa3,-4(a1)            # in1

	fmadd.s  ft4,fa0,fa1,ft4   # in0*tp0
	addi     a1,a1,16          # free ride in pipeline A.
	fmadd.s  ft5,fa0,fa2,ft5   # in0*tp1
	addi     a2,a2,16          # free ride in pipeline A.
	fmadd.s  ft6,fa3,fa1,ft6   # in1*tp0
	fnmsub.s ft7,fa3,fa2,ft7   # -in1*tp1
	blt a1,a5,.loop

.endloop:
	beq a1,a5, .done

	# Do one more complex.
	addi     a4, a1, -12
	addi     a1, a1, -16
	
	bge      a4, a5, .oddcheck

	flw  fa0,0(a1) # in0
	flw  fa1,0(a2) # tp0
	flw  fa2,4(a2) # tp1
	flw  fa3,4(a1) # in1

	fmadd.s  ft4,fa0,fa1,ft4   # in0*tp0
	fmadd.s  ft5,fa0,fa2,ft5   # in0*tp1
	fmadd.s  ft6,fa3,fa1,ft6   # in1*tp0
	fnmsub.s ft7,fa3,fa2,ft7   # -in1*tp1
	addi a1,a1,8
	
.oddcheck:
	beq  a1,a5, .done

	# Handle odd number
	flw  ft2,0(a1) # in0
	flw  ft4,0(a2) # tp0
	fmadd.s ft0,ft2,ft4,ft0
.done:
	# Some one-time stalling here.
	# Latency 5, repeat 1.
	fadd.s ft0,ft0,ft2
	fadd.s ft1,ft1,ft3
	fadd.s ft0,ft0,ft4
	fadd.s ft1,ft1,ft5
	fadd.s ft0,ft0,ft6
	fadd.s ft1,ft1,ft7
	# fsw has latency 4, repeat 1.
	fsw ft0,0(a0)
	fsw ft1,4(a0)
	ret
.empty:
	fmv.w.x ft0, zero
	fsw ft8,0(a0)
	fsw ft1,4(a0)
	ret
#volk_32fc_32f_dot_prod_32fc_a:
#volk_32fc_32f_dot_prod_32fc_a:
#volk_32fc_32f_dot_prod_32fc_a_sifive_u74:	
#volk_32fc_x2_dot_prod_32fc_a:
#volk_32f_x2_dot_prod_16i_a:	
#volk_32f_x2_dot_prod_16i_a_sifive_u74:
#volk_32f_x2_dot_prod_32f_a:	
