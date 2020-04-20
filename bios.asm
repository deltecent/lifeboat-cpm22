;
; Original disassembly of the Lifeboat BIOS from LIFEBOAT.DSK
; provided by Mike Douglas at deramp.com
;

	org	0d700h

; CPM page zero equates

wbootv	equ	000h		;warm boot vector location
bdosv	equ	005h		;bdos entry vector location
cdisk	equ	004h		;CPM current disk
defDma	equ	080h		;default dma address

; MITS Disk Drive Controller Equates

drvSel	equ	8		;drive select port (out)
drvStat	equ	8		;drive status port (in)
drvCtl	equ	9		;drive control port(out)
drvSec	equ	9		;drive sector position (in)
drvData	equ	10		;drive read/write data

enwdMsk	equ	001h		;enter new write data bit mask
headMsk	equ	004h		;mask to get head load bit alone
moveMsk	equ	002h		;mask to get head move bit alone
trk0Msk	equ	040h		;mask to get track zero bit alone
dSelect	equ	0ffh		;deselects drive when written to drvSel
selMask	equ	008h		;"not used" bit is zero when drive selected

dcStepI	equ	001h		;drive command - step in
dcStepO	equ	002h		;drive command - step out
dcLoad	equ	004h		;drive command - load head
dcUload	equ	008h		;drive command - unload head
dcWrite	equ	080h		;drive command - start write sequence

; disk information equates

numDisk	equ	4		;up to four drives in use
numTrk	equ	77		;number of tracks
numSect	equ	32		;number of sectors per track
altLen	equ	137		;length of Altair sector
secLen	equ	128		;length of CPM sector
dsm0	equ	149		;max block number (150 blocks of 2048 bytes)
drm0	equ	63		;max directory entry number (64 entries) 
cks	equ	(drm0+1)/4	;directory check space
maxTry	equ	5		;maximum number of disk I/O tries
unTrack	equ	07fh		;unknown track number

; misc equates

cr	equ	13		;ascii for carriage return
lf	equ	10		;ascii for line feed

;
;	perform following functions
;	boot	cold start
;	wboot	warm start (save i/o byte)
;	(boot and wboot are the same for mds)
;	const	console status
;		reg-a = 00 if no character ready
;		reg-a = ff if character ready
;	conin	console character in (result in reg-a)
;	conout	console character out (char in reg-c)
;	list	list out (char in reg-c)
;	punch	punch out (char in reg-c)
;	reader	paper tape reader in (result to reg-a)
;	home	move to track 00
;
;	(the following calls set-up the io parameter block for the
;	mds, which is used to perform subsequent reads and writes)
;	seldsk	select disk given by reg-c (0,1,2...)
;	settrk	set track address (0,...76) for subsequent read/write
;	setsec	set sector address (1,...,26) for subsequent read/write
;	setdma	set subsequent dma address (initially 80h)
;
;	(read and write assume previous calls to set up the io parameters)
;	read	read track/sector to preset dma address
;	write	write track/sector from preset dma address
;
;-----------------------------------------------------------------------------
;
;  BIOS Entry Jump Table
;
;-----------------------------------------------------------------------------
;
	jmp	boot		;d700	c3 82 d7 	. . . 
wboote:	jmp	wboot		;d703	c3 8c d7 	. . . 
	jmp	const		;d706	c3 06 dc 	. . . 
	jmp	conin		;d709	c3 c9 d8 	. . . DC09?
	jmp	conout		;d70c	c3 0c dc 	. . . 
	jmp	list		;d70f	c3 0f dc 	. . . 
	jmp	punch		;d712	c3 12 dc 	. . . 
	jmp	reader		;d715	c3 15 dc 	. . . 
	jmp	home		;d718	c3 8d d8 	. . . 
	jmp	seldsk		;d71b	c3 6b d8 	. k . 
	jmp	settrk		;d71e	c3 8f d8 	. . . 
	jmp	setsec		;d721	c3 94 d8 	. . . 
	jmp	setdma		;d724	c3 99 d8 	. . . 
	jmp	read		;d727	c3 d7 d8 	. . . 
	jmp	write		;d72a	c3 e3 d8 	. . . 
	jmp	listst		;d72d	c3 18 dc 	. . . 
	jmp	setran		;d730	c3 9f d8 	. . . 
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
	dw	boot		;d74e	20 32 	  2 
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
	call	conout		;d77b	cd 0c dc 	. . . 
	pop	h			;d77e	e1 	. 
	jmp	ld774h		;d77f	c3 74 d7 	. t . 
boot:
	xra	a			;d782	af 	. 
	sta	00004h		;d783	32 04 00 	2 . . 
	call	sdc00h		;d786	cd 00 dc 	. . . 
	jmp	ld7aeh		;d789	c3 ae d7 	. . . 
wboot:
	lxi	sp,00100h		;d78c	31 00 01 	1 . . 
	call	sdb95h		;d78f	cd 95 db 	. . . 
	xra	a			;d792	af 	. 
	sta	diskNum		;d793	32 95 df 	2 . . 
	sta	trkNum		;d796	32 96 df 	2 . . 
	lxi	h,0bf80h		;d799	21 80 bf 	. . . 
	inr	a			;d79c	3c 	< 
	call	sd7e8h		;d79d	cd e8 d7 	. . . 
	mvi	a,001h		;d7a0	3e 01 	> . 
	sta	trkNum		;d7a2	32 96 df 	2 . . 
	lxi	h,0cf80h		;d7a5	21 80 cf 	. . . 
	call	sd7e8h		;d7a8	cd e8 d7 	. . . 
ld7abh:
	call	sdc03h		;d7ab	cd 03 dc 	. . . 
ld7aeh:
	mvi	a,0c3h		;d7ae	3e c3 	> . 
	sta	wbootv		;d7b0	32 00 00 	2 . . 
	sta	bdosv		;d7b3	32 05 00 	2 . . 
	lxi	h,wboote		;d7b6	21 03 d7 	. . . 
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
	sta	secNum		;d7e8	32 97 df 	2 . . 
	shld	dmaAddr		;d7eb	22 98 df 	" . . 
	mov	a,h			;d7ee	7c 	| 
	cpi	0d7h		;d7ef	fe d7 	. . 
	jnc	ld7ffh		;d7f1	d2 ff d7 	. . . 
	cpi	0c1h		;d7f4	fe c1 	. . 
	jc	ld7ffh		;d7f6	da ff d7 	. . . 
	call	read		;d7f9	cd d7 d8 	. . . 
	jnz	wboot		;d7fc	c2 8c d7 	. . . 
ld7ffh:
	lhld	dmaAddr		;d7ff	2a 98 df 	* . . 
	lxi	d,00100h		;d802	11 00 01 	. . . 
	dad	d			;d805	19 	. 
	lda	secNum		;d806	3a 97 df 	: . . 
	adi	002h		;d809	c6 02 	. . 
	cpi	021h		;d80b	fe 21 	. . 
	jc	sd7e8h		;d80d	da e8 d7 	. . . 
	sui	01fh		;d810	d6 1f 	. . 
	lxi	d,0f080h		;d812	11 80 f0 	. . . 
	dad	d			;d815	19 	. 
	cpi	003h		;d816	fe 03 	. . 
	jnz	sd7e8h		;d818	c2 e8 d7 	. . . 
	ret			;d81b	c9 	. 
;-----------------------------------------------------------------------------
; dpHead - disk parameter header for each drive
;-----------------------------------------------------------------------------
dpHead:
	dw	xlate,0,0,0,dirBuf,mitsDrv,csv0,alv0
	dw	xlate,0,0,0,dirBuf,mitsDrv,csv1,alv1
	dw	xlate,0,0,0,dirBuf,mitsDrv,csv2,alv2
	dw	xlate,0,0,0,dirBuf,mitsDrv,csv3,alv3

mitsDrv:dw	ld85eh		;d85c	20 00 	  . 

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

;----------------------------------------------------------------------------
; seldsk - Select Disk BIOS entry. C contains the disk number to select.
;    Validate the disk number and return a pointer to the disk parameter
;    header in HL. Zero is returned in HL for invalid drive number. The
;    selected disk number is stored in diskNum. No actual drive activity 
;    takes place.
;----------------------------------------------------------------------------
seldsk:
	mov	a,c			;d86b	79 	y 
	ani	07fh		;d86c	e6 7f 	.  
	lxi	h,ldbfbh		;d86e	21 fb db 	. . . 
	cmp	m			;d871	be 	. 
	jnc	ld884h		;d872	d2 84 d8 	. . . 
	sta	diskNum		;d875	32 95 df 	2 . . 
	mvi	h,0		;d878	26 00 	& . 
	mov	l,a			;d87a	6f 	o 
	dad	h			;d87b	29 	) 
	dad	h			;d87c	29 	) 
	dad	h			;d87d	29 	) 
	dad	h			;d87e	29 	) 
	lxi	d,dpHead		;d87f	11 1c d8 	. . . 
	dad	d			;d882	19 	. 
	ret			;d883	c9 	. 
ld884h:
	lxi	h,wbootv		;d884	21 00 00 	. . . 
	xra	a			;d887	af 	. 
	sta	00004h		;d888	32 04 00 	2 . . 
	inr	a			;d88b	3c 	< 
	ret			;d88c	c9 	. 
home:
	mvi	c,0		;d88d	0e 00 	. . 
settrk:
	mov	a,c			;d88f	79 	y 
	sta	trkNum		;d890	32 96 df 	2 . . 
	ret			;d893	c9 	. 
setsec:
	mov	a,c			;d894	79 	y 
	sta	secNum		;d895	32 97 df 	2 . . 
	ret			;d898	c9 	. 
setdma:
	mov	h,b			;d899	60 	` 
	mov	l,c			;d89a	69 	i 
	shld	dmaAddr		;d89b	22 98 df 	" . . 
	ret			;d89e	c9 	. 
setran:
	lxi	h,xlate		;d89f	21 a9 d8 	. . . 
	mvi	b,0		;d8a2	06 00 	. . 
	dad	b			;d8a4	09 	. 
	mov	l,m			;d8a5	6e 	n 
	mvi	h,0		;d8a6	26 00 	& . 
	ret			;d8a8	c9 	. 

;---------------------------------------------------------------------------
; xlate - sector translation table for skew
;---------------------------------------------------------------------------
xlate:
	db	1,9,17,25,3,11,19,27
	db	5,13,21,29,7,15,23,31
	db	2,10,18,26,4,12,20,28
	db	6,14,22,30,8,16,24,32
;
	call	0db90h		;d8c9	cd 90 db
	jmp	0dc09h		;d8cc
	push	b		;d8cf
	call	0db90h		;d8d0	cd 90 db
	pop	b		;d8d3	c1	.
	jmp	list		;d8d4	c3 0f dc 	. . . 
read:
	mvi	a,001h		;d8d7	3e 01 	> . 
	call	sd911h		;d8d9	cd 11 d9 	. . . 
	di			;d8dc	f3 	. 
	call	sd95fh		;d8dd	cd 5f d9 	. _ . 
ld8e0h:
	jmp	ld901h		;d8e0	c3 01 d9 	. . . 
write:
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
	mvi	a,0		;d90c	3e 00 	> . 
	rz			;d90e	c8 	. 
	inr	a			;d90f	3c 	< 
	ret			;d910	c9 	. 
sd911h:
	sta	0df9ah		;d911	32 9a df 	2 . . 
	lda	diskNum		;d914	3a 95 df 	: . . 
	mov	c,a			;d917	4f 	O 
	call	sd926h		;d918	cd 26 d9 	. & . 
	mov	a,c			;d91b	79 	y 
	sta	diskNum		;d91c	32 95 df 	2 . . 
	lhld	trkNum		;d91f	2a 96 df 	* . . 
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
	call	conin		;d93d	cd 09 dc 	. . . 
ld940h:
	mvi	c,0		;d940	0e 00 	. . 
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
	lda	trkNum		;d97c	3a 96 df 	: . . 
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
	lhld	dmaAddr		;d997	2a 98 df 	* . . 
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
	lhld	dmaAddr		;d9c9	2a 98 df 	* . . 
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
	in	drvStat		;d9f9	db 08 	. . 
	ora	a			;d9fb	b7 	. 
	jm	ld9f9h		;d9fc	fa f9 d9 	. . . 
	in	drvData		;d9ff	db 0a 	. . 
	mov	m,a			;da01	77 	w 
	inx	h			;da02	23 	# 
	dcr	c			;da03	0d 	. 
	jz	lda10h		;da04	ca 10 da 	. . . 
	dcr	c			;da07	0d 	. 
	nop			;da08	00 	. 
	in	drvData		;da09	db 0a 	. . 
	mov	m,a			;da0b	77 	w 
	inx	h			;da0c	23 	# 
	jnz	ld9f9h		;da0d	c2 f9 d9 	. . . 
lda10h:
	xra	a			;da10	af 	. 
	ret			;da11	c9 	. 
sda12h:
	call	sdb7fh		;da12	cd 7f db 	.  . 
lda15h:
	in	drvSec		;da15	db 09 	. . 
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
	lda	trkNum		;da2e	3a 96 df 	: . . 
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
	lhld	dmaAddr		;da43	2a 98 df 	* . . 
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
	lhld	dmaAddr		;da57	2a 98 df 	* . . 
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
	mvi	a,0		;da7b	3e 00 	> . 
	rar			;da7d	1f 	. 
	stc			;da7e	37 	7 
	rar			;da7f	1f 	. 
	mov	d,a			;da80	57 	W 
	mov	a,b			;da81	78 	x 
	call	sdad5h		;da82	cd d5 da 	. . . 
lda85h:
	in	drvSec		;da85	db 09 	. . 
	rar			;da87	1f 	. 
	jc	lda85h		;da88	da 85 da 	. . . 
	ani	01fh		;da8b	e6 1f 	. . 
	cmp	e			;da8d	bb 	. 
	jnz	lda85h		;da8e	c2 85 da 	. . . 
	mov	a,d			;da91	7a 	z 
	out	drvCtl		;da92	d3 09 	. . 
	lxi	h,lde00h		;da94	21 00 de 	. . . 
	lxi	b,00189h		;da97	01 89 01 	. . . 
	mvi	d,001h		;da9a	16 01 	. . 
	mvi	a,080h		;da9c	3e 80 	> . 
	ora	m			;da9e	b6 	. 
	mov	e,a			;da9f	5f 	_ 
	inx	h			;daa0	23 	# 
ldaa1h:
	in	drvStat		;daa1	db 08 	. . 
	ana	d			;daa3	a2 	. 
	jnz	ldaa1h		;daa4	c2 a1 da 	. . . 
	add	e			;daa7	83 	. 
	out	drvData		;daa8	d3 0a 	. . 
	mov	a,m			;daaa	7e 	~ 
	inx	h			;daab	23 	# 
	mov	e,m			;daac	5e 	^ 
	inx	h			;daad	23 	# 
	dcr	c			;daae	0d 	. 
	jz	ldab8h		;daaf	ca b8 da 	. . . 
	dcr	c			;dab2	0d 	. 
	out	drvData		;dab3	d3 0a 	. . 
	jnz	ldaa1h		;dab5	c2 a1 da 	. . . 
ldab8h:
	in	drvStat		;dab8	db 08 	. . 
	ana	d			;daba	a2 	. 
	jnz	ldab8h		;dabb	c2 b8 da 	. . . 
	out	drvData		;dabe	d3 0a 	. . 
	dcr	b			;dac0	05 	. 
	jnz	ldab8h		;dac1	c2 b8 da 	. . . 
	xra	a			;dac4	af 	. 
	ret			;dac5	c9 	. 
sdac6h:
	mvi	d,0		;dac6	16 00 	. . 
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
	lda	trkNum		;dad6	3a 96 df 	: . . 
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
	in	drvStat		;db08	db 08 	. . 
	ani	002h		;db0a	e6 02 	. . 
	jnz	ldb08h		;db0c	c2 08 db 	. . . 
	mov	a,d			;db0f	7a 	z 
	out	drvCtl		;db10	d3 09 	. . 
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
	in	drvSec		;db30	db 09 	. . 
	rar			;db32	1f 	. 
	jc	ldb30h		;db33	da 30 db 	. 0 . 
ldb36h:
	in	drvStat		;db36	db 08 	. . 
	ora	a			;db38	b7 	. 
	jm	ldb36h		;db39	fa 36 db 	. 6 . 
	in	drvData		;db3c	db 0a 	. . 
	ani	07fh		;db3e	e6 7f 	.  
	cmp	c			;db40	b9 	. 
	rz			;db41	c8 	. 
	xra	a			;db42	af 	. 
	jmp	sdaf2h		;db43	c3 f2 da 	. . . 
sdb46h:
	lda	diskNum		;db46	3a 95 df 	: . . 
	mov	e,a			;db49	5f 	_ 
	lda	0df9bh		;db4a	3a 9b df 	: . . 
	cmp	e			;db4d	bb 	. 
	mov	a,e			;db4e	7b 	{ 
	sta	0df9bh		;db4f	32 9b df 	2 . . 
	jnz	ldb5ch		;db52	c2 5c db 	. \ . 
	in	drvStat		;db55	db 08 	. . 
	ani	008h		;db57	e6 08 	. . 
	jz	ldb6ch		;db59	ca 6c db 	. l . 
ldb5ch:
	mvi	a,0ffh		;db5c	3e ff 	> . 
	out	drvSel		;db5e	d3 08 	. . 
	lda	0df9bh		;db60	3a 9b df 	: . . 
	out	drvSel		;db63	d3 08 	. . 
	in	drvStat		;db65	db 08 	. . 
	ani	008h		;db67	e6 08 	. . 
	jnz	ldb5ch		;db69	c2 5c db 	. \ . 
ldb6ch:
	lda	ldbfbh		;db6c	3a fb db 	: . . 
	cmp	e			;db6f	bb 	. 
	jc	ldbd6h		;db70	da d6 db 	. . . 
	lxi	h,0df9eh		;db73	21 9e df 	. . . 
	mvi	d,0		;db76	16 00 	. . 
	dad	d			;db78	19 	. 
	ora	m			;db79	b6 	. 
	jm	ldbd6h		;db7a	fa d6 db 	. . . 
	xra	a			;db7d	af 	. 
	ret			;db7e	c9 	. 
sdb7fh:
	in	drvStat		;db7f	db 08 	. . 
	ani	004h		;db81	e6 04 	. . 
	rz			;db83	c8 	. 
	mvi	a,004h		;db84	3e 04 	> . 
	out	drvCtl		;db86	d3 09 	. . 
ldb88h:
	in	drvStat		;db88	db 08 	. . 
	ani	004h		;db8a	e6 04 	. . 
	jnz	ldb88h		;db8c	c2 88 db 	. . . 
	ret			;db8f	c9 	. 
	mvi	a,008h		;db90	3e 08 	> . 
	out	drvCtl		;db92	d3 09 	. . 
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
	in	drvStat		;dbb1	db 08 	. . 
	ani	002h		;dbb3	e6 02 	. . 
	jnz	ldbb1h		;dbb5	c2 b1 db 	. . . 
	mvi	a,002h		;dbb8	3e 02 	> . 
	out	drvCtl		;dbba	d3 09 	. . 
	in	drvStat		;dbbc	db 08 	. . 
	ani	040h		;dbbe	e6 40 	. @ 
	jnz	ldbb1h		;dbc0	c2 b1 db 	. . . 
	lda	0df9bh		;dbc3	3a 9b df 	: . . 
	mov	e,a			;dbc6	5f 	_ 
	call	ldb6ch		;dbc7	cd 6c db 	. l . 
	mvi	m,0		;dbca	36 00 	6 . 
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
const:
	jmp	ldc1bh		;dc06	c3 1b dc 	. . . 
conin:
	jmp	ldc1bh		;dc09	c3 1b dc 	. . . 
conout:
	jmp	ldc1bh		;dc0c	c3 1b dc 	. . . 
list:
	jmp	ldc1bh		;dc0f	c3 1b dc 	. . . 
punch:
	jmp	ldc1bh		;dc12	c3 1b dc 	. . . 
reader:
	jmp	ldc1bh		;dc15	c3 1b dc 	. . . 
listst:
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
	shld	const		;dc2b	22 06 dc 	" . . 
	shld	conin		;dc2e	22 09 dc 	" . . 
	shld	conout		;dc31	22 0c dc 	" . . 
	mvi	a,0c3h		;dc34	3e c3 	> . 
	sta	wbootv		;dc36	32 00 00 	2 . . 
	sta	bdosv		;dc39	32 05 00 	2 . . 
	lxi	h,wboote		;dc3c	21 03 d7 	. . . 
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
;
	ds	415		;dc61-ddff

;-----------------------------------------------------------------------------
;  Disk scratchpad areas defined in the DPH table
;-----------------------------------------------------------------------------
lde00h:	ds	2
lde02h:	ds	1
lde03h:	ds	1
lde04h:	ds	1
lde05h:	ds	1
lde06h:	ds	1
lde07h:	ds	2
	ds	124
lde83h	ds	1
lde84h	ds	2
lde86h	ds	1
dirBuf	ds	128		;bdos directory scratchpad
alv0	ds	19		;
csv0	ds	cks		;change disk scratchpad
alv1	ds	19		;bdos storage allocation scratchpad
csv1	ds	cks
alv2	ds	19
csv2	ds	cks
alv3	ds	19
csv3	ds	cks
	ds	1
;-----------------------------------------------------------------------------
; disk control data
;-----------------------------------------------------------------------------
diskNum ds	1		;current disk number
trkNum  ds	1		;track num (sector num MUST follow in memory)
secNum  ds	1		;sector number for disk operations
dmaAddr ds	2		;dma address for disk operations

biosEnd	equ	($ AND 0fc00h)+0400h	;round msb up to next 1K boundary

	end

