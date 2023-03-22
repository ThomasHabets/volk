        .text
        .align 2
        .type   volk_32fc_32f_dot_prod_32fc_sifive_u74, @function
        .global volk_32fc_32f_dot_prod_32fc_sifive_u74

volk_32fc_32f_dot_prod_32fc_sifive_u74:
	# a0 out
	# a1 in
	# a2 taps
	# a3 num points
	andi a5,a3,1
	xor  a5,a5,a3
	slli a5,a5,3
	add  a5,a5,a1

	fmv.w.x ft0,zero
	fmv.w.x ft1,zero
	fmv.w.x ft2,zero
	fmv.w.x ft3,zero
	fmv.w.x ft4,zero
	fmv.w.x ft5,zero
	fmv.w.x ft6,zero
	fmv.w.x ft7,zero
.loop:
	flw fa0,0(a2)   # t0
	flw ft8,0(a1)   # r0
	flw ft9,4(a1)   # i0
	flw fa1,4(a2)   # t1
	flw ft10,8(a1)  # r1
	fmadd.s ft0,ft8,fa0,ft0
	flw ft11,12(a1)  # i1

	fmadd.s ft1,ft9,fa0,ft1
	addi a1,a1,16
	fmadd.s ft2,ft10,fa1,ft2
	addi a2,a2,8
	fmadd.s ft3,ft11,fa1,ft3

	bne a1,a5,.loop

	and a4,a3,1
	beqz a4,.done

	# Do last one.
	flw fa0,0(a2)   # t0
	flw ft8,0(a1)   # r0
	flw ft9,0(a1)   # i0
	fmadd.s ft0,ft8,fa0,ft0
	fmadd.s ft1,ft9,fa0,ft1

.done:
	fadd.s ft0,ft0,ft2
	fadd.s ft1,ft1,ft3
	fsw ft0,0(a0)
	fsw ft1,4(a0)
	ret
