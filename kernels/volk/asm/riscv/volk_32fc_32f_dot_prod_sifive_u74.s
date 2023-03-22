        .text
        .align 2
        .type   volk_32fc_32f_dot_prod_32fc_sifive_u74, @function
        .global volk_32fc_32f_dot_prod_32fc_sifive_u74

volk_32fc_32f_dot_prod_32fc_sifive_u74:
	# a0 out
	# a1 in
	# a2 taps
	# a3 num points
	andi a5,a3,3
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

	# Main loop 4x unrolled. Basically random instruction interleaving
	# empirically found to be pretty fast.
.loop:
	flw fa0,0(a2)   # t0
	flw ft8,0(a1)   # r0
	flw ft9,4(a1)   # i0
	flw fa1,4(a2)   # t1
	flw ft10,8(a1)  # r1
	flw ft11,12(a1) # i1
	fmadd.s ft0,ft8,fa0,ft0
	flw fa2,8(a2)   # t2
	flw fa4,16(a1)  # r2
	fmadd.s ft1,ft9,fa0,ft1
	flw fa3,12(a2)  # t3
	fmadd.s ft2,ft10,fa1,ft2
	flw fa5,20(a1)  # i2
	fmadd.s ft3,ft11,fa1,ft3
	flw fa6,24(a1)  # r3
	fmadd.s ft4,fa4,fa2,ft4
	flw fa7,28(a1)  # i3
	fmadd.s ft5,fa5,fa2,ft5
	addi a1,a1,32
	fmadd.s ft6,fa6,fa3,ft6
	addi a2,a2,16
	fmadd.s ft7,fa7,fa3,ft7
	bne a1,a5,.loop

	and a4,a3,2
	beqz a4,.odd

	# Do last pair.
	flw fa0,0(a2)   # t0
	flw ft8,0(a1)   # r0
	flw ft9,4(a1)   # i0
	flw fa1,4(a2)   # t1
	fmadd.s ft2,ft8,fa0,ft2
	flw ft10,8(a1)  # r1
	flw ft11,12(a1) # i1
	fmadd.s ft3,ft9,fa1,ft3
	addi a1,a1,16
	fmadd.s ft4,ft10,fa0,ft4
	addi a2,a2,8
	fmadd.s ft5,ft11,fa1,ft5
	
.odd:
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
	fadd.s ft0,ft0,ft4
	fadd.s ft1,ft1,ft5
	fadd.s ft0,ft0,ft6
	fadd.s ft1,ft1,ft7
	fsw ft0,0(a0)
	fsw ft1,4(a0)
	ret
