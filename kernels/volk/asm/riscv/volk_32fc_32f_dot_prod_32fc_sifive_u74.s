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

	fmv.w.x ft0,zero
	fmv.w.x ft1,zero
	fmv.w.x ft7,zero
	fmv.w.x ft8,zero

	fmv.w.x ft11,zero

	# ft0/ft1 and ft8/ft7: res
	# split into two to avoid write-read stall in inner loop.

.loop:
	# Load input in order of when it'll be used.
	# flw has 2 cycle latency, 1 cycle repeat.
	flw  ft2,0(a1) # in0
	flw  ft4,0(a2) # tp0
	flw  ft5,4(a2) # tp1
	flw  ft3,4(a1) # in1

	# None of the fused multiple-adds have a write-read stall.
	# FMA, like mul and add, have 5 cycle latency, 1 cycle repeat.
	fmadd.s ft0,ft2,ft4,ft0  # n0*tp0
	addi a1,a1,8             # free ride in pipeline A.
	fmadd.s ft1,ft2,ft5,ft1  # n0*tp1
	addi a2,a2,8             # free ride in pipeline A.
	fmadd.s ft7,ft3,ft4,ft7  # n1*tp0
	fnmsub.s ft8,ft3,ft5,ft8 # -in1*tp1
	
	ble a1, a5, .loop

	# TODO: branch predict assumes not taken, but almost always will.
	# Not worth optimizing since only one mispredict per call?
	beq a1,a5,.done

	# Handle odd number
	flw  ft2,0(a1) # in0
	flw  ft4,0(a2) # tp0
	fmadd.s ft0,ft2,ft4,ft0
.done:
	# Some one-time stalling here.
	# Latency 5, repeat 1.
	fadd.s ft0,ft0,ft8
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
