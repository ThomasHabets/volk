        .text
        .align 2
        .type   volk_32fc_x2_dot_prod_32fc_sifive_u74, @function
        .global volk_32fc_x2_dot_prod_32fc_sifive_u74

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

	# ft0/ft1: res

.loop:
	# load input in order of when it'll be used.
	flw  ft2,0(a1) # in0
	flw  ft4,0(a2) # tp0
	flw  ft5,4(a2) # tp1
	flw  ft3,4(a1) # in1

	fmadd.s ft0,ft2,ft4,ft0 # n0*tp0
	addi a1,a1,8
	fmadd.s ft1,ft2,ft5,ft1 # n0*tp1
	addi a2,a2,8
	fmadd.s ft7,ft3,ft4,ft7 # n1*tp0
	fnmsub.s ft8,ft3,ft5,ft8 # -in1*tp1
	
	ble a1, a5, .loop

	# TODO: branch predict assumes not taken, but almost always will.
	# Not worth optimizing?
	beq a1,a5,.done

	# Handle odd number
	flw  ft2,0(a1) # in0
	flw  ft4,0(a2) # tp0
	fmadd.s ft0,ft2,ft4,ft0
.done:
	fadd.s ft0,ft0,ft8
	fadd.s ft1,ft1,ft7
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
