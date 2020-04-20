; z80dasm 1.1.6
; command line: z80dasm -c -l -t --origin=55040 bios.bin
;
; Original disassembly of the Lifeboat BIOS from LIFEBOAT.DSK
; provided by Mike Douglas at deramp.com
;

	org	0d700h

	jmp	ld782h		;d700	c3 82 d7 	. . . 
ld703h:
	jmp	ld78ch		;d703	c3 8c d7 	. . . 
	jmp	ldc06h		;d706	c3 06 dc 	. . . 
	jmp	0d8c9h		;d709	c3 c9 d8 	. . . 
	jmp	ldc0ch		;d70c	c3 0c dc 	. . . 
	jmp	ldc0fh		;d70f	c3 0f dc 	. . . 
	jmp	ldc12h		;d712	c3 12 dc 	. . . 
	jmp	ldc15h		;d715	c3 15 dc 	. . . 
	jmp	ld88dh		;d718	c3 8d d8 	. . . 
	jmp	ld86bh		;d71b	c3 6b d8 	. k . 
	jmp	ld88fh		;d71e	c3 8f d8 	. . . 
	jmp	ld894h		;d721	c3 94 d8 	. . . 
	jmp	ld899h		;d724	c3 99 d8 	. . . 
	jmp	ld8d7h		;d727	c3 d7 d8 	. . . 
	jmp	ld8e3h		;d72a	c3 e3 d8 	. . . 
	jmp	ldc18h		;d72d	c3 18 dc 	. . . 
	jmp	ld89fh		;d730	c3 9f d8 	. . . 
ld733h:
	dcr	c			;d733	0d 	. 
	ldax	b			;d734	0a 	. 
	mov	b,e			;d735	43 	C 
	mov	d,b			;d736	50 	P 
	cma			;d737	2f 	/ 
	mov	c,l			;d738	4d 	M 
	sta	06f20h		;d739	32 20 6f 	2   o 
	mov	l,m			;d73c	6e 	n 
	dw	$+67		;d73d	20 41 	  A 
	mov	l,h			;d73f	6c 	l 
	mov	m,h			;d740	74 	t 
	mov	h,c			;d741	61 	a 
	mov	l,c			;d742	69 	i 
	mov	m,d			;d743	72 	r 
	dcr	c			;d744	0d 	. 
	ldax	b			;d745	0a 	. 
	dcr	m			;d746	35 	5 
	mvi	m,04bh		;d747	36 4b 	6 K 
	dw	$+88		;d749	20 56 	  V 
	mov	h,l			;d74b	65 	e 
	mov	m,d			;d74c	72 	r 
	mov	m,e			;d74d	73 	s 
	dw	ld782h		;d74e	20 32 	  2 
	mvi	l,032h		;d750	2e 32 	. 2 
	dw	ld774h		;d752	30 20 	0   
	dw	ld763h		;d754	20 0d 	  . 
	ldax	b			;d756	0a 	. 
	dw	ld7bch		;d757	28 63 	( c 
	dad	h			;d759	29 	) 
	dw	$+51		;d75a	20 31 	  1 
	dad	sp			;d75c	39 	9 
	dw	$+51		;d75d	38 31 	8 1 
	dw	$+78		;d75f	20 4c 	  L 
	mov	l,c			;d761	69 	i 
	mov	h,m			;d762	66 	f 
ld763h:
	mov	h,l			;d763	65 	e 
	mov	h,d			;d764	62 	b 
	mov	l,a			;d765	6f 	o 
	mov	h,c			;d766	61 	a 
	mov	m,h			;d767	74 	t 
	dw	ld7abh		;d768	20 41 	  A 
	mov	m,e			;d76a	73 	s 
	mov	m,e			;d76b	73 	s 
	mov	l,a			;d76c	6f 	o 
	mov	h,e			;d76d	63 	c 
	mov	l,c			;d76e	69 	i 
	mov	h,c			;d76f	61 	a 
	mov	m,h			;d770	74 	t 
	mov	h,l			;d771	65 	e 
	mov	m,e			;d772	73 	s 
	inr	h			;d773	24 	$ 
ld774h:
	mov	a,m			;d774	7e 	~ 
	cpi	024h		;d775	fe 24 	. $ 
	rz			;d777	c8 	. 
	mov	c,m			;d778	4e 	N 
	inx	h			;d779	23 	# 
	push	h			;d77a	e5 	. 
	call	ldc0ch		;d77b	cd 0c dc 	. . . 
	pop	h			;d77e	e1 	. 
	jmp	ld774h		;d77f	c3 74 d7 	. t . 
ld782h:
	xra	a			;d782	af 	. 
	sta	00004h		;d783	32 04 00 	2 . . 
	call	sdc00h		;d786	cd 00 dc 	. . . 
	jmp	ld7aeh		;d789	c3 ae d7 	. . . 
ld78ch:
	lxi	sp,00100h		;d78c	31 00 01 	1 . . 
	call	sdb95h		;d78f	cd 95 db 	. . . 
	xra	a			;d792	af 	. 
	sta	0df95h		;d793	32 95 df 	2 . . 
	sta	0df96h		;d796	32 96 df 	2 . . 
	lxi	h,0bf80h		;d799	21 80 bf 	. . . 
	inr	a			;d79c	3c 	< 
	call	sd7e8h		;d79d	cd e8 d7 	. . . 
	mvi	a,001h		;d7a0	3e 01 	> . 
	sta	0df96h		;d7a2	32 96 df 	2 . . 
	lxi	h,0cf80h		;d7a5	21 80 cf 	. . . 
	call	sd7e8h		;d7a8	cd e8 d7 	. . . 
ld7abh:
	call	sdc03h		;d7ab	cd 03 dc 	. . . 
ld7aeh:
	mvi	a,0c3h		;d7ae	3e c3 	> . 
	sta	00000h		;d7b0	32 00 00 	2 . . 
	sta	00005h		;d7b3	32 05 00 	2 . . 
	lxi	h,ld703h		;d7b6	21 03 d7 	. . . 
	shld	00001h		;d7b9	22 01 00 	" . . 
ld7bch:
	lxi	h,0c906h		;d7bc	21 06 c9 	. . . 
	shld	00006h		;d7bf	22 06 00 	" . . 
	lxi	h,0df9dh		;d7c2	21 9d df 	. . . 
	mov	a,m			;d7c5	7e 	~ 
	ora	a			;d7c6	b7 	. 
	mvi	m,001h		;d7c7	36 01 	6 . 
	push	psw			;d7c9	f5 	. 
	lxi	h,ld733h		;d7ca	21 33 d7 	. 3 . 
	cz	ld774h		;d7cd	cc 74 d7 	. t . 
	pop	psw			;d7d0	f1 	. 
	lxi	h,00004h		;d7d1	21 04 00 	. . . 
	mov	c,m			;d7d4	4e 	N 
	lda	ldbffh		;d7d5	3a ff db 	: . . 
	jz	ld7e0h		;d7d8	ca e0 d7 	. . . 
	ani	002h		;d7db	e6 02 	. . 
	jmp	ld7e2h		;d7dd	c3 e2 d7 	. . . 
ld7e0h:
	ani	001h		;d7e0	e6 01 	. . 
ld7e2h:
	jz	0c103h		;d7e2	ca 03 c1 	. . . 
	jmp	0c100h		;d7e5	c3 00 c1 	. . . 
sd7e8h:
	sta	0df97h		;d7e8	32 97 df 	2 . . 
	shld	0df98h		;d7eb	22 98 df 	" . . 
	mov	a,h			;d7ee	7c 	| 
	cpi	0d7h		;d7ef	fe d7 	. . 
	jnc	ld7ffh		;d7f1	d2 ff d7 	. . . 
	cpi	0c1h		;d7f4	fe c1 	. . 
	jc	ld7ffh		;d7f6	da ff d7 	. . . 
	call	ld8d7h		;d7f9	cd d7 d8 	. . . 
	jnz	ld78ch		;d7fc	c2 8c d7 	. . . 
ld7ffh:
	lhld	0df98h		;d7ff	2a 98 df 	* . . 
	lxi	d,00100h		;d802	11 00 01 	. . . 
	dad	d			;d805	19 	. 
	lda	0df97h		;d806	3a 97 df 	: . . 
	adi	002h		;d809	c6 02 	. . 
	cpi	021h		;d80b	fe 21 	. . 
	jc	sd7e8h		;d80d	da e8 d7 	. . . 
	sui	01fh		;d810	d6 1f 	. . 
	lxi	d,0f080h		;d812	11 80 f0 	. . . 
	dad	d			;d815	19 	. 
	cpi	003h		;d816	fe 03 	. . 
	jnz	sd7e8h		;d818	c2 e8 d7 	. . . 
	ret			;d81b	c9 	. 
ld81ch:
	xra	c			;d81c	a9 	. 
	rc			;d81d	d8 	. 
	nop			;d81e	00 	. 
	nop			;d81f	00 	. 
	nop			;d820	00 	. 
	nop			;d821	00 	. 
	nop			;d822	00 	. 
	nop			;d823	00 	. 
	adc	c			;d824	89 	. 
	sbi	05ch		;d825	de 5c 	. \ 
	rc			;d827	d8 	. 
	inr	e			;d828	1c 	. 
	rst	3			;d829	df 	. 
	dad	b			;d82a	09 	. 
	rst	3			;d82b	df 	. 
	xra	c			;d82c	a9 	. 
	rc			;d82d	d8 	. 
	nop			;d82e	00 	. 
	nop			;d82f	00 	. 
	nop			;d830	00 	. 
	nop			;d831	00 	. 
	nop			;d832	00 	. 
	nop			;d833	00 	. 
	adc	c			;d834	89 	. 
	sbi	05ch		;d835	de 5c 	. \ 
	rc			;d837	d8 	. 
	cmc			;d838	3f 	? 
	rst	3			;d839	df 	. 
	inr	l			;d83a	2c 	, 
	rst	3			;d83b	df 	. 
	xra	c			;d83c	a9 	. 
	rc			;d83d	d8 	. 
	nop			;d83e	00 	. 
	nop			;d83f	00 	. 
	nop			;d840	00 	. 
	nop			;d841	00 	. 
	nop			;d842	00 	. 
	nop			;d843	00 	. 
	adc	c			;d844	89 	. 
	sbi	05ch		;d845	de 5c 	. \ 
	rc			;d847	d8 	. 
	mov	h,d			;d848	62 	b 
	rst	3			;d849	df 	. 
	mov	c,a			;d84a	4f 	O 
	rst	3			;d84b	df 	. 
	xra	c			;d84c	a9 	. 
	rc			;d84d	d8 	. 
	nop			;d84e	00 	. 
	nop			;d84f	00 	. 
	nop			;d850	00 	. 
	nop			;d851	00 	. 
	nop			;d852	00 	. 
	nop			;d853	00 	. 
	adc	c			;d854	89 	. 
	sbi	05ch		;d855	de 5c 	. \ 
	rc			;d857	d8 	. 
	add	l			;d858	85 	. 
	rst	3			;d859	df 	. 
	mov	m,d			;d85a	72 	r 
	rst	3			;d85b	df 	. 
	dw	ld85eh		;d85c	20 00 	  . 
ld85eh:
	inr	b			;d85e	04 	. 
	rrc			;d85f	0f 	. 
	nop			;d860	00 	. 
	sub	l			;d861	95 	. 
	nop			;d862	00 	. 
	cmc			;d863	3f 	? 
	nop			;d864	00 	. 
	add	b			;d865	80 	. 
	nop			;d866	00 	. 
	dw	ld869h		;d867	10 00 	. . 
ld869h:
	stax	b			;d869	02 	. 
	nop			;d86a	00 	. 
ld86bh:
	mov	a,c			;d86b	79 	y 
	ani	07fh		;d86c	e6 7f 	.  
	lxi	h,ldbfbh		;d86e	21 fb db 	. . . 
	cmp	m			;d871	be 	. 
	jnc	ld884h		;d872	d2 84 d8 	. . . 
	sta	0df95h		;d875	32 95 df 	2 . . 
	mvi	h,000h		;d878	26 00 	& . 
	mov	l,a			;d87a	6f 	o 
	dad	h			;d87b	29 	) 
	dad	h			;d87c	29 	) 
	dad	h			;d87d	29 	) 
	dad	h			;d87e	29 	) 
	lxi	d,ld81ch		;d87f	11 1c d8 	. . . 
	dad	d			;d882	19 	. 
	ret			;d883	c9 	. 
ld884h:
	lxi	h,00000h		;d884	21 00 00 	. . . 
	xra	a			;d887	af 	. 
	sta	00004h		;d888	32 04 00 	2 . . 
	inr	a			;d88b	3c 	< 
	ret			;d88c	c9 	. 
ld88dh:
	mvi	c,000h		;d88d	0e 00 	. . 
ld88fh:
	mov	a,c			;d88f	79 	y 
	sta	0df96h		;d890	32 96 df 	2 . . 
	ret			;d893	c9 	. 
ld894h:
	mov	a,c			;d894	79 	y 
	sta	0df97h		;d895	32 97 df 	2 . . 
	ret			;d898	c9 	. 
ld899h:
	mov	h,b			;d899	60 	` 
	mov	l,c			;d89a	69 	i 
	shld	0df98h		;d89b	22 98 df 	" . . 
	ret			;d89e	c9 	. 
ld89fh:
	lxi	h,ld8a9h		;d89f	21 a9 d8 	. . . 
	mvi	b,000h		;d8a2	06 00 	. . 
	dad	b			;d8a4	09 	. 
	mov	l,m			;d8a5	6e 	n 
	mvi	h,000h		;d8a6	26 00 	& . 
	ret			;d8a8	c9 	. 
ld8a9h:
	lxi	b,01109h		;d8a9	01 09 11 	. . . 
	dad	d			;d8ac	19 	. 
	inx	b			;d8ad	03 	. 
	dcx	b			;d8ae	0b 	. 
	inx	d			;d8af	13 	. 
	dcx	d			;d8b0	1b 	. 
	dcr	b			;d8b1	05 	. 
	dcr	c			;d8b2	0d 	. 
	dcr	d			;d8b3	15 	. 
	dcr	e			;d8b4	1d 	. 
	rlc			;d8b5	07 	. 
	rrc			;d8b6	0f 	. 
	ral			;d8b7	17 	. 
	rar			;d8b8	1f 	. 
	stax	b			;d8b9	02 	. 
	ldax	b			;d8ba	0a 	. 
	stax	d			;d8bb	12 	. 
	ldax	d			;d8bc	1a 	. 
	inr	b			;d8bd	04 	. 
	inr	c			;d8be	0c 	. 
	inr	d			;d8bf	14 	. 
	inr	e			;d8c0	1c 	. 
	mvi	b,00eh		;d8c1	06 0e 	. . 
	mvi	d,01eh		;d8c3	16 1e 	. . 
	dw	08h			;d8c5	08 	. 
	dw	ld8e0h		;d8c6	10 18 	. . 
	dw	$-49		;d8c8	20 cd 	  . 
	sub	b			;d8ca	90 	. 
	in	0c3h		;d8cb	db c3 	. . 
	dad	b			;d8cd	09 	. 
	cc	0cdc5h		;d8ce	dc c5 cd 	. . . 
	sub	b			;d8d1	90 	. 
	in	0c1h		;d8d2	db c1 	. . 
	jmp	ldc0fh		;d8d4	c3 0f dc 	. . . 
ld8d7h:
	mvi	a,001h		;d8d7	3e 01 	> . 
	call	sd911h		;d8d9	cd 11 d9 	. . . 
	di			;d8dc	f3 	. 
	call	sd95fh		;d8dd	cd 5f d9 	. _ . 
ld8e0h:
	jmp	ld901h		;d8e0	c3 01 d9 	. . . 
ld8e3h:
	xra	a			;d8e3	af 	. 
	call	sd911h		;d8e4	cd 11 d9 	. . . 
	di			;d8e7	f3 	. 
	call	sda22h		;d8e8	cd 22 da 	. " . 
	jnz	ld901h		;d8eb	c2 01 d9 	. . . 
	lda	ldbffh		;d8ee	3a ff db 	: . . 
	ani	040h		;d8f1	e6 40 	. @ 
	jz	ld901h		;d8f3	ca 01 d9 	. . . 
	mvi	a,001h		;d8f6	3e 01 	> . 
	call	sd911h		;d8f8	cd 11 d9 	. . . 
	lxi	h,lde00h		;d8fb	21 00 de 	. . . 
	call	sd95fh		;d8fe	cd 5f d9 	. _ . 
ld901h:
	push	psw			;d901	f5 	. 
	lda	ldbffh		;d902	3a ff db 	: . . 
	ani	010h		;d905	e6 10 	. . 
	jz	ld90bh		;d907	ca 0b d9 	. . . 
	ei			;d90a	fb 	. 
ld90bh:
	pop	psw			;d90b	f1 	. 
	mvi	a,000h		;d90c	3e 00 	> . 
	rz			;d90e	c8 	. 
	inr	a			;d90f	3c 	< 
	ret			;d910	c9 	. 
sd911h:
	sta	0df9ah		;d911	32 9a df 	2 . . 
	lda	0df95h		;d914	3a 95 df 	: . . 
	mov	c,a			;d917	4f 	O 
	call	sd926h		;d918	cd 26 d9 	. & . 
	mov	a,c			;d91b	79 	y 
	sta	0df95h		;d91c	32 95 df 	2 . . 
	lhld	0df96h		;d91f	2a 96 df 	* . . 
	mov	c,l			;d922	4d 	M 
	dcr	h			;d923	25 	% 
	mov	b,h			;d924	44 	D 
	ret			;d925	c9 	. 
sd926h:
	lda	ldbffh		;d926	3a ff db 	: . . 
	ani	004h		;d929	e6 04 	. . 
	rz			;d92b	c8 	. 
	lxi	h,0d950h		;d92c	21 50 d9 	. P . 
	mov	a,c			;d92f	79 	y 
	adi	041h		;d930	c6 41 	. A 
	cmp	m			;d932	be 	. 
	jz	ld940h		;d933	ca 40 d9 	. @ . 
	mov	m,a			;d936	77 	w 
	lxi	h,ld943h		;d937	21 43 d9 	. C . 
	call	ld774h		;d93a	cd 74 d7 	. t . 
	call	sdc09h		;d93d	cd 09 dc 	. . . 
ld940h:
	mvi	c,000h		;d940	0e 00 	. . 
	ret			;d942	c9 	. 
ld943h:
	dcr	c			;d943	0d 	. 
	ldax	b			;d944	0a 	. 
	mov	c,l			;d945	4d 	M 
	mov	l,a			;d946	6f 	o 
	mov	m,l			;d947	75 	u 
	mov	l,m			;d948	6e 	n 
	mov	m,h			;d949	74 	t 
	dw	$+102		;d94a	20 64 	  d 
	mov	l,c			;d94c	69 	i 
	mov	m,e			;d94d	73 	s 
	mov	l,e			;d94e	6b 	k 
	dw	ld992h		;d94f	20 41 	  A 
	inr	l			;d951	2c 	, 
	dw	ld9c8h		;d952	20 74 	  t 
	mov	l,b			;d954	68 	h 
	mov	h,l			;d955	65 	e 
	mov	l,m			;d956	6e 	n 
	dw	$+62		;d957	20 3c 	  < 
	mov	h,e			;d959	63 	c 
	mov	m,d			;d95a	72 	r 
	mvi	a,00dh		;d95b	3e 0d 	> . 
	ldax	b			;d95d	0a 	. 
	inr	h			;d95e	24 	$ 
sd95fh:
	call	sdae6h		;d95f	cd e6 da 	. . . 
	rnz			;d962	c0 	. 
ld963h:
	push	b			;d963	c5 	. 
ld964h:
	call	sdbcdh		;d964	cd cd db 	. . . 
	pop	b			;d967	c1 	. 
	rnz			;d968	c0 	. 
	push	b			;d969	c5 	. 
	mov	a,b			;d96a	78 	x 
	call	sdad5h		;d96b	cd d5 da 	. . . 
	lxi	h,lde00h		;d96e	21 00 de 	. . . 
	call	sd9f4h		;d971	cd f4 d9 	. . . 
	lda	ldbffh		;d974	3a ff db 	: . . 
	ani	008h		;d977	e6 08 	. . 
	jnz	ld9f1h		;d979	c2 f1 d9 	. . . 
	lda	0df96h		;d97c	3a 96 df 	: . . 
	cpi	006h		;d97f	fe 06 	. . 
	jnc	ld9ach		;d981	d2 ac d9 	. . . 
	lxi	h,lde83h		;d984	21 83 de 	. . . 
	inr	m			;d987	34 	4 
	jnz	ld964h		;d988	c2 64 d9 	. d . 
	lxi	h,lde00h		;d98b	21 00 de 	. . . 
	mov	a,m			;d98e	7e 	~ 
	ani	07fh		;d98f	e6 7f 	.  
	pop	b			;d991	c1 	. 
ld992h:
	cmp	c			;d992	b9 	. 
	jnz	ld9eah		;d993	c2 ea d9 	. . . 
	push	b			;d996	c5 	. 
	lhld	0df98h		;d997	2a 98 df 	* . . 
	mov	b,h			;d99a	44 	D 
	mov	c,l			;d99b	4d 	M 
	lxi	h,lde03h		;d99c	21 03 de 	. . . 
	call	sdac6h		;d99f	cd c6 da 	. . . 
	lxi	h,lde84h		;d9a2	21 84 de 	. . . 
	cmp	m			;d9a5	be 	. 
	jnz	ld964h		;d9a6	c2 64 d9 	. d . 
	pop	b			;d9a9	c1 	. 
	xra	a			;d9aa	af 	. 
	ret			;d9ab	c9 	. 
ld9ach:
	dcx	h			;d9ac	2b 	+ 
	mov	a,m			;d9ad	7e 	~ 
	ora	a			;d9ae	b7 	. 
	jnz	ld964h		;d9af	c2 64 d9 	. d . 
	dcx	h			;d9b2	2b 	+ 
	inr	m			;d9b3	34 	4 
	jnz	ld964h		;d9b4	c2 64 d9 	. d . 
	lxi	h,lde00h		;d9b7	21 00 de 	. . . 
	mov	a,m			;d9ba	7e 	~ 
	ani	07fh		;d9bb	e6 7f 	.  
	pop	b			;d9bd	c1 	. 
	cmp	c			;d9be	b9 	. 
	jnz	ld9eah		;d9bf	c2 ea d9 	. . . 
	inx	h			;d9c2	23 	# 
	mov	a,m			;d9c3	7e 	~ 
	cmp	b			;d9c4	b8 	. 
	jnz	ld963h		;d9c5	c2 63 d9 	. c . 
ld9c8h:
	push	b			;d9c8	c5 	. 
	lhld	0df98h		;d9c9	2a 98 df 	* . . 
	mov	b,h			;d9cc	44 	D 
	mov	c,l			;d9cd	4d 	M 
	lxi	h,lde07h		;d9ce	21 07 de 	. . . 
	call	sdac6h		;d9d1	cd c6 da 	. . . 
	lxi	h,lde06h		;d9d4	21 06 de 	. . . 
	mov	b,m			;d9d7	46 	F 
	dcx	h			;d9d8	2b 	+ 
	mov	c,m			;d9d9	4e 	N 
	dcx	h			;d9da	2b 	+ 
	mov	d,m			;d9db	56 	V 
	dcx	h			;d9dc	2b 	+ 
	mov	e,m			;d9dd	5e 	^ 
	dcx	h			;d9de	2b 	+ 
	add	e			;d9df	83 	. 
	add	b			;d9e0	80 	. 
	add	c			;d9e1	81 	. 
	add	m			;d9e2	86 	. 
	cmp	d			;d9e3	ba 	. 
	jnz	ld964h		;d9e4	c2 64 d9 	. d . 
	pop	b			;d9e7	c1 	. 
	xra	a			;d9e8	af 	. 
	ret			;d9e9	c9 	. 
ld9eah:
	xra	a			;d9ea	af 	. 
	call	sdaf2h		;d9eb	cd f2 da 	. . . 
	jmp	ld963h		;d9ee	c3 63 d9 	. c . 
ld9f1h:
	pop	b			;d9f1	c1 	. 
	xra	a			;d9f2	af 	. 
	ret			;d9f3	c9 	. 
sd9f4h:
	call	sda12h		;d9f4	cd 12 da 	. . . 
	mvi	c,089h		;d9f7	0e 89 	. . 
ld9f9h:
	in	008h		;d9f9	db 08 	. . 
	ora	a			;d9fb	b7 	. 
	jm	ld9f9h		;d9fc	fa f9 d9 	. . . 
	in	00ah		;d9ff	db 0a 	. . 
	mov	m,a			;da01	77 	w 
	inx	h			;da02	23 	# 
	dcr	c			;da03	0d 	. 
	jz	lda10h		;da04	ca 10 da 	. . . 
	dcr	c			;da07	0d 	. 
	nop			;da08	00 	. 
	in	00ah		;da09	db 0a 	. . 
	mov	m,a			;da0b	77 	w 
	inx	h			;da0c	23 	# 
	jnz	ld9f9h		;da0d	c2 f9 d9 	. . . 
lda10h:
	xra	a			;da10	af 	. 
	ret			;da11	c9 	. 
sda12h:
	call	sdb7fh		;da12	cd 7f db 	.  . 
lda15h:
	in	009h		;da15	db 09 	. . 
	rar			;da17	1f 	. 
	jc	lda15h		;da18	da 15 da 	. . . 
	ani	01fh		;da1b	e6 1f 	. . 
	cmp	e			;da1d	bb 	. 
	jnz	lda15h		;da1e	c2 15 da 	. . . 
	ret			;da21	c9 	. 
sda22h:
	call	sdae6h		;da22	cd e6 da 	. . . 
	rnz			;da25	c0 	. 
	lda	ldbffh		;da26	3a ff db 	: . . 
	ani	008h		;da29	e6 08 	. . 
	jnz	lda78h		;da2b	c2 78 da 	. x . 
	lda	0df96h		;da2e	3a 96 df 	: . . 
	cpi	006h		;da31	fe 06 	. . 
	jnc	lda53h		;da33	d2 53 da 	. S . 
	push	b			;da36	c5 	. 
	mov	a,c			;da37	79 	y 
	lxi	b,lde00h		;da38	01 00 de 	. . . 
	stax	b			;da3b	02 	. 
	xra	a			;da3c	af 	. 
	inx	b			;da3d	03 	. 
	stax	b			;da3e	02 	. 
	inr	a			;da3f	3c 	< 
	inx	b			;da40	03 	. 
	stax	b			;da41	02 	. 
	inx	b			;da42	03 	. 
	lhld	0df98h		;da43	2a 98 df 	* . . 
	call	sdac6h		;da46	cd c6 da 	. . . 
	mvi	a,0ffh		;da49	3e ff 	> . 
	stax	b			;da4b	02 	. 
	inx	b			;da4c	03 	. 
	mov	a,d			;da4d	7a 	z 
	stax	b			;da4e	02 	. 
	pop	b			;da4f	c1 	. 
	jmp	lda78h		;da50	c3 78 da 	. x . 
lda53h:
	push	b			;da53	c5 	. 
	lxi	b,lde07h		;da54	01 07 de 	. . . 
	lhld	0df98h		;da57	2a 98 df 	* . . 
	call	sdac6h		;da5a	cd c6 da 	. . . 
	mvi	a,0ffh		;da5d	3e ff 	> . 
	stax	b			;da5f	02 	. 
	inx	b			;da60	03 	. 
	xra	a			;da61	af 	. 
	stax	b			;da62	02 	. 
	mov	a,d			;da63	7a 	z 
	lhld	lde02h		;da64	2a 02 de 	* . . 
	add	h			;da67	84 	. 
	add	l			;da68	85 	. 
	lhld	lde05h		;da69	2a 05 de 	* . . 
	add	h			;da6c	84 	. 
	add	l			;da6d	85 	. 
	sta	lde04h		;da6e	32 04 de 	2 . . 
	pop	b			;da71	c1 	. 
	lxi	h,lde00h		;da72	21 00 de 	. . . 
	mov	m,c			;da75	71 	q 
	inx	h			;da76	23 	# 
	mov	m,b			;da77	70 	p 
lda78h:
	mov	a,c			;da78	79 	y 
	adi	0d5h		;da79	c6 d5 	. . 
	mvi	a,000h		;da7b	3e 00 	> . 
	rar			;da7d	1f 	. 
	stc			;da7e	37 	7 
	rar			;da7f	1f 	. 
	mov	d,a			;da80	57 	W 
	mov	a,b			;da81	78 	x 
	call	sdad5h		;da82	cd d5 da 	. . . 
lda85h:
	in	009h		;da85	db 09 	. . 
	rar			;da87	1f 	. 
	jc	lda85h		;da88	da 85 da 	. . . 
	ani	01fh		;da8b	e6 1f 	. . 
	cmp	e			;da8d	bb 	. 
	jnz	lda85h		;da8e	c2 85 da 	. . . 
	mov	a,d			;da91	7a 	z 
	out	009h		;da92	d3 09 	. . 
	lxi	h,lde00h		;da94	21 00 de 	. . . 
	lxi	b,00189h		;da97	01 89 01 	. . . 
	mvi	d,001h		;da9a	16 01 	. . 
	mvi	a,080h		;da9c	3e 80 	> . 
	ora	m			;da9e	b6 	. 
	mov	e,a			;da9f	5f 	_ 
	inx	h			;daa0	23 	# 
ldaa1h:
	in	008h		;daa1	db 08 	. . 
	ana	d			;daa3	a2 	. 
	jnz	ldaa1h		;daa4	c2 a1 da 	. . . 
	add	e			;daa7	83 	. 
	out	00ah		;daa8	d3 0a 	. . 
	mov	a,m			;daaa	7e 	~ 
	inx	h			;daab	23 	# 
	mov	e,m			;daac	5e 	^ 
	inx	h			;daad	23 	# 
	dcr	c			;daae	0d 	. 
	jz	ldab8h		;daaf	ca b8 da 	. . . 
	dcr	c			;dab2	0d 	. 
	out	00ah		;dab3	d3 0a 	. . 
	jnz	ldaa1h		;dab5	c2 a1 da 	. . . 
ldab8h:
	in	008h		;dab8	db 08 	. . 
	ana	d			;daba	a2 	. 
	jnz	ldab8h		;dabb	c2 b8 da 	. . . 
	out	00ah		;dabe	d3 0a 	. . 
	dcr	b			;dac0	05 	. 
	jnz	ldab8h		;dac1	c2 b8 da 	. . . 
	xra	a			;dac4	af 	. 
	ret			;dac5	c9 	. 
sdac6h:
	mvi	d,000h		;dac6	16 00 	. . 
	mvi	e,080h		;dac8	1e 80 	. . 
ldacah:
	mov	a,m			;daca	7e 	~ 
	stax	b			;dacb	02 	. 
	add	d			;dacc	82 	. 
	mov	d,a			;dacd	57 	W 
	inx	b			;dace	03 	. 
	inx	h			;dacf	23 	# 
	dcr	e			;dad0	1d 	. 
	jnz	ldacah		;dad1	c2 ca da 	. . . 
	ret			;dad4	c9 	. 
sdad5h:
	mov	e,a			;dad5	5f 	_ 
	lda	0df96h		;dad6	3a 96 df 	: . . 
	cpi	006h		;dad9	fe 06 	. . 
	rc			;dadb	d8 	. 
	mov	a,e			;dadc	7b 	{ 
	add	a			;dadd	87 	. 
	add	a			;dade	87 	. 
	add	a			;dadf	87 	. 
	add	a			;dae0	87 	. 
	add	e			;dae1	83 	. 
	ani	01fh		;dae2	e6 1f 	. . 
	mov	e,a			;dae4	5f 	_ 
	ret			;dae5	c9 	. 
sdae6h:
	mvi	a,005h		;dae6	3e 05 	> . 
	sta	0df9ch		;dae8	32 9c df 	2 . . 
	call	sdb46h		;daeb	cd 46 db 	. F . 
	rnz			;daee	c0 	. 
	mov	a,m			;daef	7e 	~ 
	cpi	07fh		;daf0	fe 7f 	.  
sdaf2h:
	cz	sdbaeh		;daf2	cc ae db 	. . . 
	mov	a,m			;daf5	7e 	~ 
	mov	m,c			;daf6	71 	q 
	mov	e,a			;daf7	5f 	_ 
	call	sdb7fh		;daf8	cd 7f db 	.  . 
	mov	a,e			;dafb	7b 	{ 
	sub	c			;dafc	91 	. 
	rz			;dafd	c8 	. 
	mvi	d,001h		;dafe	16 01 	. . 
	jc	ldb07h		;db00	da 07 db 	. . . 
	mvi	d,002h		;db03	16 02 	. . 
	cma			;db05	2f 	/ 
	inr	a			;db06	3c 	< 
ldb07h:
	mov	e,a			;db07	5f 	_ 
ldb08h:
	in	008h		;db08	db 08 	. . 
	ani	002h		;db0a	e6 02 	. . 
	jnz	ldb08h		;db0c	c2 08 db 	. . . 
	mov	a,d			;db0f	7a 	z 
	out	009h		;db10	d3 09 	. . 
	mov	a,e			;db12	7b 	{ 
	inr	a			;db13	3c 	< 
	jnz	ldb07h		;db14	c2 07 db 	. . . 
	call	sdbcdh		;db17	cd cd db 	. . . 
	jz	ldb23h		;db1a	ca 23 db 	. # . 
	call	sdbabh		;db1d	cd ab db 	. . . 
	jmp	ldbd6h		;db20	c3 d6 db 	. . . 
ldb23h:
	lda	0df9ah		;db23	3a 9a df 	: . . 
	ora	a			;db26	b7 	. 
	jnz	ldb30h		;db27	c2 30 db 	. 0 . 
	lda	ldbffh		;db2a	3a ff db 	: . . 
	ani	080h		;db2d	e6 80 	. . 
	rz			;db2f	c8 	. 
ldb30h:
	in	009h		;db30	db 09 	. . 
	rar			;db32	1f 	. 
	jc	ldb30h		;db33	da 30 db 	. 0 . 
ldb36h:
	in	008h		;db36	db 08 	. . 
	ora	a			;db38	b7 	. 
	jm	ldb36h		;db39	fa 36 db 	. 6 . 
	in	00ah		;db3c	db 0a 	. . 
	ani	07fh		;db3e	e6 7f 	.  
	cmp	c			;db40	b9 	. 
	rz			;db41	c8 	. 
	xra	a			;db42	af 	. 
	jmp	sdaf2h		;db43	c3 f2 da 	. . . 
sdb46h:
	lda	0df95h		;db46	3a 95 df 	: . . 
	mov	e,a			;db49	5f 	_ 
	lda	0df9bh		;db4a	3a 9b df 	: . . 
	cmp	e			;db4d	bb 	. 
	mov	a,e			;db4e	7b 	{ 
	sta	0df9bh		;db4f	32 9b df 	2 . . 
	jnz	ldb5ch		;db52	c2 5c db 	. \ . 
	in	008h		;db55	db 08 	. . 
	ani	008h		;db57	e6 08 	. . 
	jz	ldb6ch		;db59	ca 6c db 	. l . 
ldb5ch:
	mvi	a,0ffh		;db5c	3e ff 	> . 
	out	008h		;db5e	d3 08 	. . 
	lda	0df9bh		;db60	3a 9b df 	: . . 
	out	008h		;db63	d3 08 	. . 
	in	008h		;db65	db 08 	. . 
	ani	008h		;db67	e6 08 	. . 
	jnz	ldb5ch		;db69	c2 5c db 	. \ . 
ldb6ch:
	lda	ldbfbh		;db6c	3a fb db 	: . . 
	cmp	e			;db6f	bb 	. 
	jc	ldbd6h		;db70	da d6 db 	. . . 
	lxi	h,0df9eh		;db73	21 9e df 	. . . 
	mvi	d,000h		;db76	16 00 	. . 
	dad	d			;db78	19 	. 
	ora	m			;db79	b6 	. 
	jm	ldbd6h		;db7a	fa d6 db 	. . . 
	xra	a			;db7d	af 	. 
	ret			;db7e	c9 	. 
sdb7fh:
	in	008h		;db7f	db 08 	. . 
	ani	004h		;db81	e6 04 	. . 
	rz			;db83	c8 	. 
	mvi	a,004h		;db84	3e 04 	> . 
	out	009h		;db86	d3 09 	. . 
ldb88h:
	in	008h		;db88	db 08 	. . 
	ani	004h		;db8a	e6 04 	. . 
	jnz	ldb88h		;db8c	c2 88 db 	. . . 
	ret			;db8f	c9 	. 
	mvi	a,008h		;db90	3e 08 	> . 
	out	009h		;db92	d3 09 	. . 
	ret			;db94	c9 	. 
sdb95h:
	lxi	h,ldbffh		;db95	21 ff db 	. . . 
	mov	a,m			;db98	7e 	~ 
	ani	0f7h		;db99	e6 f7 	. . 
	mov	m,a			;db9b	77 	w 
	mvi	a,07fh		;db9c	3e 7f 	>  
	sta	0df9bh		;db9e	32 9b df 	2 . . 
	lxi	h,07f7fh		;dba1	21 7f 7f 	.   
	shld	0df9eh		;dba4	22 9e df 	" . . 
	shld	0dfa0h		;dba7	22 a0 df 	" . . 
	ret			;dbaa	c9 	. 
sdbabh:
	call	sdb46h		;dbab	cd 46 db 	. F . 
sdbaeh:
	call	sdb7fh		;dbae	cd 7f db 	.  . 
ldbb1h:
	in	008h		;dbb1	db 08 	. . 
	ani	002h		;dbb3	e6 02 	. . 
	jnz	ldbb1h		;dbb5	c2 b1 db 	. . . 
	mvi	a,002h		;dbb8	3e 02 	> . 
	out	009h		;dbba	d3 09 	. . 
	in	008h		;dbbc	db 08 	. . 
	ani	040h		;dbbe	e6 40 	. @ 
	jnz	ldbb1h		;dbc0	c2 b1 db 	. . . 
	lda	0df9bh		;dbc3	3a 9b df 	: . . 
	mov	e,a			;dbc6	5f 	_ 
	call	ldb6ch		;dbc7	cd 6c db 	. l . 
	mvi	m,000h		;dbca	36 00 	6 . 
	ret			;dbcc	c9 	. 
sdbcdh:
	lxi	h,0df9ch		;dbcd	21 9c df 	. . . 
	dcr	m			;dbd0	35 	5 
	jz	ldbd6h		;dbd1	ca d6 db 	. . . 
	xra	a			;dbd4	af 	. 
	ret			;dbd5	c9 	. 
ldbd6h:
	mvi	a,001h		;dbd6	3e 01 	> . 
	ora	a			;dbd8	b7 	. 
	ret			;dbd9	c9 	. 
	nop			;dbda	00 	. 
	nop			;dbdb	00 	. 
	nop			;dbdc	00 	. 
	nop			;dbdd	00 	. 
	nop			;dbde	00 	. 
	nop			;dbdf	00 	. 
	nop			;dbe0	00 	. 
	nop			;dbe1	00 	. 
	nop			;dbe2	00 	. 
	nop			;dbe3	00 	. 
	nop			;dbe4	00 	. 
	nop			;dbe5	00 	. 
	nop			;dbe6	00 	. 
	nop			;dbe7	00 	. 
	nop			;dbe8	00 	. 
	nop			;dbe9	00 	. 
	nop			;dbea	00 	. 
	nop			;dbeb	00 	. 
	nop			;dbec	00 	. 
	nop			;dbed	00 	. 
	nop			;dbee	00 	. 
	nop			;dbef	00 	. 
	nop			;dbf0	00 	. 
	nop			;dbf1	00 	. 
	nop			;dbf2	00 	. 
	nop			;dbf3	00 	. 
	nop			;dbf4	00 	. 
	nop			;dbf5	00 	. 
	nop			;dbf6	00 	. 
	nop			;dbf7	00 	. 
	nop			;dbf8	00 	. 
	nop			;dbf9	00 	. 
	nop			;dbfa	00 	. 
ldbfbh:
	inr	b			;dbfb	04 	. 
	nop			;dbfc	00 	. 
	sbi	010h		;dbfd	de 10 	. . 
ldbffh:
	nop			;dbff	00 	. 
sdc00h:
	jmp	ldc1dh		;dc00	c3 1d dc 	. . . 
sdc03h:
	jmp	ldc1bh		;dc03	c3 1b dc 	. . . 
ldc06h:
	jmp	ldc1bh		;dc06	c3 1b dc 	. . . 
sdc09h:
	jmp	ldc1bh		;dc09	c3 1b dc 	. . . 
ldc0ch:
	jmp	ldc1bh		;dc0c	c3 1b dc 	. . . 
ldc0fh:
	jmp	ldc1bh		;dc0f	c3 1b dc 	. . . 
ldc12h:
	jmp	ldc1bh		;dc12	c3 1b dc 	. . . 
ldc15h:
	jmp	ldc1bh		;dc15	c3 1b dc 	. . . 
ldc18h:
	jmp	ldc1bh		;dc18	c3 1b dc 	. . . 
ldc1bh:
	xra	a			;dc1b	af 	. 
	ret			;dc1c	c9 	. 
ldc1dh:
	lxi	d,0c107h		;dc1d	11 07 c1 	. . . 
	lxi	h,ldc50h		;dc20	21 50 dc 	. P . 
	mvi	b,008h		;dc23	06 08 	. . 
	call	sdc58h		;dc25	cd 58 dc 	. X . 
	lxi	h,0c9afh		;dc28	21 af c9 	. . . 
	shld	ldc06h		;dc2b	22 06 dc 	" . . 
	shld	sdc09h		;dc2e	22 09 dc 	" . . 
	shld	ldc0ch		;dc31	22 0c dc 	" . . 
	mvi	a,0c3h		;dc34	3e c3 	> . 
	sta	00000h		;dc36	32 00 00 	2 . . 
	sta	00005h		;dc39	32 05 00 	2 . . 
	lxi	h,ld703h		;dc3c	21 03 d7 	. . . 
	shld	00001h		;dc3f	22 01 00 	" . . 
	lxi	h,0c906h		;dc42	21 06 c9 	. . . 
	shld	00006h		;dc45	22 06 00 	" . . 
	xra	a			;dc48	af 	. 
	sta	00004h		;dc49	32 04 00 	2 . . 
	mov	c,a			;dc4c	4f 	O 
	jmp	0c100h		;dc4d	c3 00 c1 	. . . 
ldc50h:
	mvi	b,043h		;dc50	06 43 	. C 
	mov	c,a			;dc52	4f 	O 
	mov	c,m			;dc53	4e 	N 
	mov	b,m			;dc54	46 	F 
	mov	c,c			;dc55	49 	I 
	mov	b,a			;dc56	47 	G 
	nop			;dc57	00 	. 
sdc58h:
	mov	a,m			;dc58	7e 	~ 
	stax	d			;dc59	12 	. 
	inx	h			;dc5a	23 	# 
	inx	d			;dc5b	13 	. 
	dcr	b			;dc5c	05 	. 
	jnz	sdc58h		;dc5d	c2 58 dc 	. X . 
	ret			;dc60	c9 	. 
	nop			;dc61	00 	. 
	nop			;dc62	00 	. 
	nop			;dc63	00 	. 
	nop			;dc64	00 	. 
	nop			;dc65	00 	. 
	nop			;dc66	00 	. 
	nop			;dc67	00 	. 
	nop			;dc68	00 	. 
	nop			;dc69	00 	. 
	nop			;dc6a	00 	. 
	nop			;dc6b	00 	. 
	nop			;dc6c	00 	. 
	nop			;dc6d	00 	. 
	nop			;dc6e	00 	. 
	nop			;dc6f	00 	. 
	nop			;dc70	00 	. 
	nop			;dc71	00 	. 
	nop			;dc72	00 	. 
	nop			;dc73	00 	. 
	nop			;dc74	00 	. 
	nop			;dc75	00 	. 
	nop			;dc76	00 	. 
	nop			;dc77	00 	. 
	nop			;dc78	00 	. 
	nop			;dc79	00 	. 
	nop			;dc7a	00 	. 
	nop			;dc7b	00 	. 
	nop			;dc7c	00 	. 
	nop			;dc7d	00 	. 
	nop			;dc7e	00 	. 
	nop			;dc7f	00 	. 
	nop			;dc80	00 	. 
	nop			;dc81	00 	. 
	nop			;dc82	00 	. 
	nop			;dc83	00 	. 
	nop			;dc84	00 	. 
	nop			;dc85	00 	. 
	nop			;dc86	00 	. 
	nop			;dc87	00 	. 
	nop			;dc88	00 	. 
	nop			;dc89	00 	. 
	nop			;dc8a	00 	. 
	nop			;dc8b	00 	. 
	nop			;dc8c	00 	. 
	nop			;dc8d	00 	. 
	nop			;dc8e	00 	. 
	nop			;dc8f	00 	. 
	nop			;dc90	00 	. 
	nop			;dc91	00 	. 
	nop			;dc92	00 	. 
	nop			;dc93	00 	. 
	nop			;dc94	00 	. 
	nop			;dc95	00 	. 
	nop			;dc96	00 	. 
	nop			;dc97	00 	. 
	nop			;dc98	00 	. 
	nop			;dc99	00 	. 
	nop			;dc9a	00 	. 
	nop			;dc9b	00 	. 
	nop			;dc9c	00 	. 
	nop			;dc9d	00 	. 
	nop			;dc9e	00 	. 
	nop			;dc9f	00 	. 
	nop			;dca0	00 	. 
	nop			;dca1	00 	. 
	nop			;dca2	00 	. 
	nop			;dca3	00 	. 
	nop			;dca4	00 	. 
	nop			;dca5	00 	. 
	nop			;dca6	00 	. 
	nop			;dca7	00 	. 
	nop			;dca8	00 	. 
	nop			;dca9	00 	. 
	nop			;dcaa	00 	. 
	nop			;dcab	00 	. 
	nop			;dcac	00 	. 
	nop			;dcad	00 	. 
	nop			;dcae	00 	. 
	nop			;dcaf	00 	. 
	nop			;dcb0	00 	. 
	nop			;dcb1	00 	. 
	nop			;dcb2	00 	. 
	nop			;dcb3	00 	. 
	nop			;dcb4	00 	. 
	nop			;dcb5	00 	. 
	nop			;dcb6	00 	. 
	nop			;dcb7	00 	. 
	nop			;dcb8	00 	. 
	nop			;dcb9	00 	. 
	nop			;dcba	00 	. 
	nop			;dcbb	00 	. 
	nop			;dcbc	00 	. 
	nop			;dcbd	00 	. 
	nop			;dcbe	00 	. 
	nop			;dcbf	00 	. 
	nop			;dcc0	00 	. 
	nop			;dcc1	00 	. 
	nop			;dcc2	00 	. 
	nop			;dcc3	00 	. 
	nop			;dcc4	00 	. 
	nop			;dcc5	00 	. 
	nop			;dcc6	00 	. 
	nop			;dcc7	00 	. 
	nop			;dcc8	00 	. 
	nop			;dcc9	00 	. 
	nop			;dcca	00 	. 
	nop			;dccb	00 	. 
	nop			;dccc	00 	. 
	nop			;dccd	00 	. 
	nop			;dcce	00 	. 
	nop			;dccf	00 	. 
	nop			;dcd0	00 	. 
	nop			;dcd1	00 	. 
	nop			;dcd2	00 	. 
	nop			;dcd3	00 	. 
	nop			;dcd4	00 	. 
	nop			;dcd5	00 	. 
	nop			;dcd6	00 	. 
	nop			;dcd7	00 	. 
	nop			;dcd8	00 	. 
	nop			;dcd9	00 	. 
	nop			;dcda	00 	. 
	nop			;dcdb	00 	. 
	nop			;dcdc	00 	. 
	nop			;dcdd	00 	. 
	nop			;dcde	00 	. 
	nop			;dcdf	00 	. 
	nop			;dce0	00 	. 
	nop			;dce1	00 	. 
	nop			;dce2	00 	. 
	nop			;dce3	00 	. 
	nop			;dce4	00 	. 
	nop			;dce5	00 	. 
	nop			;dce6	00 	. 
	nop			;dce7	00 	. 
	nop			;dce8	00 	. 
	nop			;dce9	00 	. 
	nop			;dcea	00 	. 
	nop			;dceb	00 	. 
	nop			;dcec	00 	. 
	nop			;dced	00 	. 
	nop			;dcee	00 	. 
	nop			;dcef	00 	. 
	nop			;dcf0	00 	. 
	nop			;dcf1	00 	. 
	nop			;dcf2	00 	. 
	nop			;dcf3	00 	. 
	nop			;dcf4	00 	. 
	nop			;dcf5	00 	. 
	nop			;dcf6	00 	. 
	nop			;dcf7	00 	. 
	nop			;dcf8	00 	. 
	nop			;dcf9	00 	. 
	nop			;dcfa	00 	. 
	nop			;dcfb	00 	. 
	nop			;dcfc	00 	. 
	nop			;dcfd	00 	. 
	nop			;dcfe	00 	. 
	nop			;dcff	00 	. 
	nop			;dd00	00 	. 
	nop			;dd01	00 	. 
	nop			;dd02	00 	. 
	nop			;dd03	00 	. 
	nop			;dd04	00 	. 
	nop			;dd05	00 	. 
	nop			;dd06	00 	. 
	nop			;dd07	00 	. 
	nop			;dd08	00 	. 
	nop			;dd09	00 	. 
	nop			;dd0a	00 	. 
	nop			;dd0b	00 	. 
	nop			;dd0c	00 	. 
	nop			;dd0d	00 	. 
	nop			;dd0e	00 	. 
	nop			;dd0f	00 	. 
	nop			;dd10	00 	. 
	nop			;dd11	00 	. 
	nop			;dd12	00 	. 
	nop			;dd13	00 	. 
	nop			;dd14	00 	. 
	nop			;dd15	00 	. 
	nop			;dd16	00 	. 
	nop			;dd17	00 	. 
	nop			;dd18	00 	. 
	nop			;dd19	00 	. 
	nop			;dd1a	00 	. 
	nop			;dd1b	00 	. 
	nop			;dd1c	00 	. 
	nop			;dd1d	00 	. 
	nop			;dd1e	00 	. 
	nop			;dd1f	00 	. 
	nop			;dd20	00 	. 
	nop			;dd21	00 	. 
	nop			;dd22	00 	. 
	nop			;dd23	00 	. 
	nop			;dd24	00 	. 
	nop			;dd25	00 	. 
	nop			;dd26	00 	. 
	nop			;dd27	00 	. 
	nop			;dd28	00 	. 
	nop			;dd29	00 	. 
	nop			;dd2a	00 	. 
	nop			;dd2b	00 	. 
	nop			;dd2c	00 	. 
	nop			;dd2d	00 	. 
	nop			;dd2e	00 	. 
	nop			;dd2f	00 	. 
	nop			;dd30	00 	. 
	nop			;dd31	00 	. 
	nop			;dd32	00 	. 
	nop			;dd33	00 	. 
	nop			;dd34	00 	. 
	nop			;dd35	00 	. 
	nop			;dd36	00 	. 
	nop			;dd37	00 	. 
	nop			;dd38	00 	. 
	nop			;dd39	00 	. 
	nop			;dd3a	00 	. 
	nop			;dd3b	00 	. 
	nop			;dd3c	00 	. 
	nop			;dd3d	00 	. 
	nop			;dd3e	00 	. 
	nop			;dd3f	00 	. 
	nop			;dd40	00 	. 
	nop			;dd41	00 	. 
	nop			;dd42	00 	. 
	nop			;dd43	00 	. 
	nop			;dd44	00 	. 
	nop			;dd45	00 	. 
	nop			;dd46	00 	. 
	nop			;dd47	00 	. 
	nop			;dd48	00 	. 
	nop			;dd49	00 	. 
	nop			;dd4a	00 	. 
	nop			;dd4b	00 	. 
	nop			;dd4c	00 	. 
	nop			;dd4d	00 	. 
	nop			;dd4e	00 	. 
	nop			;dd4f	00 	. 
	nop			;dd50	00 	. 
	nop			;dd51	00 	. 
	nop			;dd52	00 	. 
	nop			;dd53	00 	. 
	nop			;dd54	00 	. 
	nop			;dd55	00 	. 
	nop			;dd56	00 	. 
	nop			;dd57	00 	. 
	nop			;dd58	00 	. 
	nop			;dd59	00 	. 
	nop			;dd5a	00 	. 
	nop			;dd5b	00 	. 
	nop			;dd5c	00 	. 
	nop			;dd5d	00 	. 
	nop			;dd5e	00 	. 
	nop			;dd5f	00 	. 
	nop			;dd60	00 	. 
	nop			;dd61	00 	. 
	nop			;dd62	00 	. 
	nop			;dd63	00 	. 
	nop			;dd64	00 	. 
	nop			;dd65	00 	. 
	nop			;dd66	00 	. 
	nop			;dd67	00 	. 
	nop			;dd68	00 	. 
	nop			;dd69	00 	. 
	nop			;dd6a	00 	. 
	nop			;dd6b	00 	. 
	nop			;dd6c	00 	. 
	nop			;dd6d	00 	. 
	nop			;dd6e	00 	. 
	nop			;dd6f	00 	. 
	nop			;dd70	00 	. 
	nop			;dd71	00 	. 
	nop			;dd72	00 	. 
	nop			;dd73	00 	. 
	nop			;dd74	00 	. 
	nop			;dd75	00 	. 
	nop			;dd76	00 	. 
	nop			;dd77	00 	. 
	nop			;dd78	00 	. 
	nop			;dd79	00 	. 
	nop			;dd7a	00 	. 
	nop			;dd7b	00 	. 
	nop			;dd7c	00 	. 
	nop			;dd7d	00 	. 
	nop			;dd7e	00 	. 
	nop			;dd7f	00 	. 
	nop			;dd80	00 	. 
	nop			;dd81	00 	. 
	nop			;dd82	00 	. 
	nop			;dd83	00 	. 
	nop			;dd84	00 	. 
	nop			;dd85	00 	. 
	nop			;dd86	00 	. 
	nop			;dd87	00 	. 
	nop			;dd88	00 	. 
	nop			;dd89	00 	. 
	nop			;dd8a	00 	. 
	nop			;dd8b	00 	. 
	nop			;dd8c	00 	. 
	nop			;dd8d	00 	. 
	nop			;dd8e	00 	. 
	nop			;dd8f	00 	. 
	nop			;dd90	00 	. 
	nop			;dd91	00 	. 
	nop			;dd92	00 	. 
	nop			;dd93	00 	. 
	nop			;dd94	00 	. 
	nop			;dd95	00 	. 
	nop			;dd96	00 	. 
	nop			;dd97	00 	. 
	nop			;dd98	00 	. 
	nop			;dd99	00 	. 
	nop			;dd9a	00 	. 
	nop			;dd9b	00 	. 
	nop			;dd9c	00 	. 
	nop			;dd9d	00 	. 
	nop			;dd9e	00 	. 
	nop			;dd9f	00 	. 
	nop			;dda0	00 	. 
	nop			;dda1	00 	. 
	nop			;dda2	00 	. 
	nop			;dda3	00 	. 
	nop			;dda4	00 	. 
	nop			;dda5	00 	. 
	nop			;dda6	00 	. 
	nop			;dda7	00 	. 
	nop			;dda8	00 	. 
	nop			;dda9	00 	. 
	nop			;ddaa	00 	. 
	nop			;ddab	00 	. 
	nop			;ddac	00 	. 
	nop			;ddad	00 	. 
	nop			;ddae	00 	. 
	nop			;ddaf	00 	. 
	nop			;ddb0	00 	. 
	nop			;ddb1	00 	. 
	nop			;ddb2	00 	. 
	nop			;ddb3	00 	. 
	nop			;ddb4	00 	. 
	nop			;ddb5	00 	. 
	nop			;ddb6	00 	. 
	nop			;ddb7	00 	. 
	nop			;ddb8	00 	. 
	nop			;ddb9	00 	. 
	nop			;ddba	00 	. 
	nop			;ddbb	00 	. 
	nop			;ddbc	00 	. 
	nop			;ddbd	00 	. 
	nop			;ddbe	00 	. 
	nop			;ddbf	00 	. 
	nop			;ddc0	00 	. 
	nop			;ddc1	00 	. 
	nop			;ddc2	00 	. 
	nop			;ddc3	00 	. 
	nop			;ddc4	00 	. 
	nop			;ddc5	00 	. 
	nop			;ddc6	00 	. 
	nop			;ddc7	00 	. 
	nop			;ddc8	00 	. 
	nop			;ddc9	00 	. 
	nop			;ddca	00 	. 
	nop			;ddcb	00 	. 
	nop			;ddcc	00 	. 
	nop			;ddcd	00 	. 
	nop			;ddce	00 	. 
	nop			;ddcf	00 	. 
	nop			;ddd0	00 	. 
	nop			;ddd1	00 	. 
	nop			;ddd2	00 	. 
	nop			;ddd3	00 	. 
	nop			;ddd4	00 	. 
	nop			;ddd5	00 	. 
	nop			;ddd6	00 	. 
	nop			;ddd7	00 	. 
	nop			;ddd8	00 	. 
	nop			;ddd9	00 	. 
	nop			;ddda	00 	. 
	nop			;dddb	00 	. 
	nop			;dddc	00 	. 
	nop			;dddd	00 	. 
	nop			;ddde	00 	. 
	nop			;dddf	00 	. 
	nop			;dde0	00 	. 
	nop			;dde1	00 	. 
	nop			;dde2	00 	. 
	nop			;dde3	00 	. 
	nop			;dde4	00 	. 
	nop			;dde5	00 	. 
	nop			;dde6	00 	. 
	nop			;dde7	00 	. 
	nop			;dde8	00 	. 
	nop			;dde9	00 	. 
	nop			;ddea	00 	. 
	nop			;ddeb	00 	. 
	nop			;ddec	00 	. 
	nop			;dded	00 	. 
	nop			;ddee	00 	. 
	nop			;ddef	00 	. 
	nop			;ddf0	00 	. 
	nop			;ddf1	00 	. 
	nop			;ddf2	00 	. 
	nop			;ddf3	00 	. 
	nop			;ddf4	00 	. 
	nop			;ddf5	00 	. 
	nop			;ddf6	00 	. 
	nop			;ddf7	00 	. 
	nop			;ddf8	00 	. 
	nop			;ddf9	00 	. 
	nop			;ddfa	00 	. 
	nop			;ddfb	00 	. 
	nop			;ddfc	00 	. 
	nop			;ddfd	00 	. 
	nop			;ddfe	00 	. 
	nop			;ddff	00 	. 
lde00h:
	nop			;de00	00 	. 
	nop			;de01	00 	. 
lde02h:
	nop			;de02	00 	. 
lde03h:
	nop			;de03	00 	. 
lde04h:
	nop			;de04	00 	. 
lde05h:
	nop			;de05	00 	. 
lde06h:
	nop			;de06	00 	. 
lde07h:
	nop			;de07	00 	. 
	nop			;de08	00 	. 
	nop			;de09	00 	. 
	nop			;de0a	00 	. 
	nop			;de0b	00 	. 
	nop			;de0c	00 	. 
	nop			;de0d	00 	. 
	nop			;de0e	00 	. 
	nop			;de0f	00 	. 
	nop			;de10	00 	. 
	nop			;de11	00 	. 
	nop			;de12	00 	. 
	nop			;de13	00 	. 
	nop			;de14	00 	. 
	nop			;de15	00 	. 
	nop			;de16	00 	. 
	nop			;de17	00 	. 
	nop			;de18	00 	. 
	nop			;de19	00 	. 
	nop			;de1a	00 	. 
	nop			;de1b	00 	. 
	nop			;de1c	00 	. 
	nop			;de1d	00 	. 
	nop			;de1e	00 	. 
	nop			;de1f	00 	. 
	nop			;de20	00 	. 
	nop			;de21	00 	. 
	nop			;de22	00 	. 
	nop			;de23	00 	. 
	nop			;de24	00 	. 
	nop			;de25	00 	. 
	nop			;de26	00 	. 
	nop			;de27	00 	. 
	nop			;de28	00 	. 
	nop			;de29	00 	. 
	nop			;de2a	00 	. 
	nop			;de2b	00 	. 
	nop			;de2c	00 	. 
	nop			;de2d	00 	. 
	nop			;de2e	00 	. 
	nop			;de2f	00 	. 
	nop			;de30	00 	. 
	nop			;de31	00 	. 
	nop			;de32	00 	. 
	nop			;de33	00 	. 
	nop			;de34	00 	. 
	nop			;de35	00 	. 
	nop			;de36	00 	. 
	nop			;de37	00 	. 
	nop			;de38	00 	. 
	nop			;de39	00 	. 
	nop			;de3a	00 	. 
	nop			;de3b	00 	. 
	nop			;de3c	00 	. 
	nop			;de3d	00 	. 
	nop			;de3e	00 	. 
	nop			;de3f	00 	. 
	nop			;de40	00 	. 
	nop			;de41	00 	. 
	nop			;de42	00 	. 
	nop			;de43	00 	. 
	nop			;de44	00 	. 
	nop			;de45	00 	. 
	nop			;de46	00 	. 
	nop			;de47	00 	. 
	nop			;de48	00 	. 
	nop			;de49	00 	. 
	nop			;de4a	00 	. 
	nop			;de4b	00 	. 
	nop			;de4c	00 	. 
	nop			;de4d	00 	. 
	nop			;de4e	00 	. 
	nop			;de4f	00 	. 
	nop			;de50	00 	. 
	nop			;de51	00 	. 
	nop			;de52	00 	. 
	nop			;de53	00 	. 
	nop			;de54	00 	. 
	nop			;de55	00 	. 
	nop			;de56	00 	. 
	nop			;de57	00 	. 
	nop			;de58	00 	. 
	nop			;de59	00 	. 
	nop			;de5a	00 	. 
	nop			;de5b	00 	. 
	nop			;de5c	00 	. 
	nop			;de5d	00 	. 
	nop			;de5e	00 	. 
	nop			;de5f	00 	. 
	nop			;de60	00 	. 
	nop			;de61	00 	. 
	nop			;de62	00 	. 
	nop			;de63	00 	. 
	nop			;de64	00 	. 
	nop			;de65	00 	. 
	nop			;de66	00 	. 
	nop			;de67	00 	. 
	nop			;de68	00 	. 
	nop			;de69	00 	. 
	nop			;de6a	00 	. 
	nop			;de6b	00 	. 
	nop			;de6c	00 	. 
	nop			;de6d	00 	. 
	nop			;de6e	00 	. 
	nop			;de6f	00 	. 
	nop			;de70	00 	. 
	nop			;de71	00 	. 
	nop			;de72	00 	. 
	nop			;de73	00 	. 
	nop			;de74	00 	. 
	nop			;de75	00 	. 
	nop			;de76	00 	. 
	nop			;de77	00 	. 
	nop			;de78	00 	. 
	nop			;de79	00 	. 
	nop			;de7a	00 	. 
	nop			;de7b	00 	. 
	nop			;de7c	00 	. 
	nop			;de7d	00 	. 
	nop			;de7e	00 	. 
	nop			;de7f	00 	. 
	nop			;de80	00 	. 
	nop			;de81	00 	. 
	nop			;de82	00 	. 
lde83h:
	nop			;de83	00 	. 
lde84h:
	nop			;de84	00 	. 
	nop			;de85	00 	. 
	nop			;de86	00 	. 
	nop			;de87	00 	. 
	nop			;de88	00 	. 
	nop			;de89	00 	. 
	nop			;de8a	00 	. 
	nop			;de8b	00 	. 
	nop			;de8c	00 	. 
	nop			;de8d	00 	. 
	nop			;de8e	00 	. 
	nop			;de8f	00 	. 
	nop			;de90	00 	. 
	nop			;de91	00 	. 
	nop			;de92	00 	. 
	nop			;de93	00 	. 
	nop			;de94	00 	. 
	nop			;de95	00 	. 
	nop			;de96	00 	. 
	nop			;de97	00 	. 
	nop			;de98	00 	. 
	nop			;de99	00 	. 
	nop			;de9a	00 	. 
	nop			;de9b	00 	. 
	nop			;de9c	00 	. 
	nop			;de9d	00 	. 
	nop			;de9e	00 	. 
	nop			;de9f	00 	. 
	nop			;dea0	00 	. 
	nop			;dea1	00 	. 
	nop			;dea2	00 	. 
	nop			;dea3	00 	. 
	nop			;dea4	00 	. 
	nop			;dea5	00 	. 
	nop			;dea6	00 	. 
	nop			;dea7	00 	. 
	nop			;dea8	00 	. 
	nop			;dea9	00 	. 
	nop			;deaa	00 	. 
	nop			;deab	00 	. 
	nop			;deac	00 	. 
	nop			;dead	00 	. 
	nop			;deae	00 	. 
	nop			;deaf	00 	. 
	nop			;deb0	00 	. 
	nop			;deb1	00 	. 
	nop			;deb2	00 	. 
	nop			;deb3	00 	. 
	nop			;deb4	00 	. 
	nop			;deb5	00 	. 
	nop			;deb6	00 	. 
	nop			;deb7	00 	. 
	nop			;deb8	00 	. 
	nop			;deb9	00 	. 
	nop			;deba	00 	. 
	nop			;debb	00 	. 
	nop			;debc	00 	. 
	nop			;debd	00 	. 
	nop			;debe	00 	. 
	nop			;debf	00 	. 
	nop			;dec0	00 	. 
	nop			;dec1	00 	. 
	nop			;dec2	00 	. 
	nop			;dec3	00 	. 
	nop			;dec4	00 	. 
	nop			;dec5	00 	. 
	nop			;dec6	00 	. 
	nop			;dec7	00 	. 
	nop			;dec8	00 	. 
	nop			;dec9	00 	. 
	nop			;deca	00 	. 
	nop			;decb	00 	. 
	nop			;decc	00 	. 
	nop			;decd	00 	. 
	nop			;dece	00 	. 
	nop			;decf	00 	. 
	nop			;ded0	00 	. 
	nop			;ded1	00 	. 
	nop			;ded2	00 	. 
	nop			;ded3	00 	. 
	nop			;ded4	00 	. 
	nop			;ded5	00 	. 
	nop			;ded6	00 	. 
	nop			;ded7	00 	. 
	nop			;ded8	00 	. 
	nop			;ded9	00 	. 
	nop			;deda	00 	. 
	nop			;dedb	00 	. 
	nop			;dedc	00 	. 
	nop			;dedd	00 	. 
	nop			;dede	00 	. 
	nop			;dedf	00 	. 
	nop			;dee0	00 	. 
	nop			;dee1	00 	. 
	nop			;dee2	00 	. 
	nop			;dee3	00 	. 
	nop			;dee4	00 	. 
	nop			;dee5	00 	. 
	nop			;dee6	00 	. 
	nop			;dee7	00 	. 
	nop			;dee8	00 	. 
	nop			;dee9	00 	. 
	nop			;deea	00 	. 
	nop			;deeb	00 	. 
	nop			;deec	00 	. 
	nop			;deed	00 	. 
	nop			;deee	00 	. 
	nop			;deef	00 	. 
	nop			;def0	00 	. 
	nop			;def1	00 	. 
	nop			;def2	00 	. 
	nop			;def3	00 	. 
	nop			;def4	00 	. 
	nop			;def5	00 	. 
	nop			;def6	00 	. 
	nop			;def7	00 	. 
	nop			;def8	00 	. 
	nop			;def9	00 	. 
	nop			;defa	00 	. 
	nop			;defb	00 	. 
	nop			;defc	00 	. 
	nop			;defd	00 	. 
	nop			;defe	00 	. 
	nop			;deff	00 	. 
