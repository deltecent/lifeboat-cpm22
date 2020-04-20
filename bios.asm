;
; Original disassembly of the Lifeboat BIOS from LIFEBOAT.DSK
; provided by Mike Douglas at deramp.com
;

	org	0d700h

; CPM module locations


ccpLen	equ	0800h		;CPM 2.2 fixed
bdosLen	equ	0e00h		;CPM 2.2 fixed
ccp	equ	$-bdosLen-ccpLen
bdos	equ	$-bdosLen

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
	jmp	sectran		;d730	c3 9f d8 	. . . 

signon:
	db	cr,lf
	db	'CP/M2 on Altair',cr,lf
	db	'56K Vers 2.20  ',cr,lf
	db	'(c) 1981 Lifeboat Associates$'
;
prmsg:	;print message at h,l to '$'
	mov	a,m			;d774	7e 	~ 
	cpi	'$'		;d775	fe 24 	. $ 
	rz			;d777	c8 	. 
	mov	c,m			;d778	4e 	N 
	inx	h			;d779	23 	# 
	push	h			;d77a	e5 	. 
	call	conout		;d77b	cd 0c dc 	. . . 
	pop	h			;d77e	e1 	. 
	jmp	prmsg		;d77f	c3 74 d7 	. t . 
;
boot:
	xra	a			;d782	af 	. 
	sta	cdisk		;set initially to disk a
	call	sdc00h		;initialize user area
	jmp	gocpm		;go to cp/m
;
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
;
gocpm:
;
;	reset monitor entry points
	mvi	a,jmp		;d7ae	3e c3 	> . 
	sta	wbootv		;d7b0	32 00 00 	2 . . 
	sta	bdosv		;d7b3	32 05 00 	2 . . 
	lxi	h,wboote		;d7b6	21 03 d7 	. . . 
	shld	1		;d7b9	22 01 00 	" . . 
ld7bch:
	lxi	h,bdos+6		;d7bc	21 06 c9 	. . . 
	shld	6		;d7bf	22 06 00 	" . . 
	lxi	h,0df9dh		;d7c2	21 9d df 	. . . 
	mov	a,m			;d7c5	7e 	~ 
	ora	a			;d7c6	b7 	. 
	mvi	m,001h		;d7c7	36 01 	6 . 
	push	psw			;d7c9	f5 	. 
	lxi	h,signon		;d7ca	21 33 d7 	. 3 . 
	cz	prmsg		;d7cd	cc 74 d7 	. t . 
	pop	psw			;d7d0	f1 	. 
	lxi	h,cdisk		;d7d1	21 04 00 	. . . 
	mov	c,m			;d7d4	4e 	N 
	lda	flags		;d7d5	3a ff db 	: . . 
	jz	ld7e0h		;d7d8	ca e0 d7 	. . . 
	ani	fWrmCmd		;d7db	e6 02 	. . 
	jmp	ld7e2h		;d7dd	c3 e2 d7 	. . . 
;
ld7e0h:
	ani	001h		;d7e0	e6 01 	. . 
;
ld7e2h:
	jz	ccp+3		;d7e2	ca 03 c1 	. . . 
	jmp	ccp		;d7e5	c3 00 c1 	. . . 
;
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
;
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

;-----------------------------------------------------------------------------
; mitsdrv - disk parameter block. This table gives a block size of 2048 bytes.
;   Per CPM docs, EXM should be 1 and AL0,AL1 should be 080h, 000h.
;   This would give two logical extents per physical extent. (32K per
;   physical extent). The settings here give one logical extent per
;   physical extent (16K per physical extent). This was probably done
;   to maintain compatibility with CPM 1.4 disks.
;-----------------------------------------------------------------------------
mitsDrv:
	dw      numSect         ;sectors per track
	db      4               ;allocation block shift factor (BSH)
	db      00fh            ;data location block mask (BLM)
	db      0               ;extent mask (EXM), see note above
	dw      dsm0            ;maximum block number (DSM)
	dw      drm0            ;maximum directory entry number (DRM)
	db      080h, 0         ;AL0, AL1, see note above
	dw      cks             ;CKS (DRM+1)/4
	dw      2               ;reserved tracks for CPM and bootloader

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
	lxi	h,numDisk		;d86e	21 fb db 	. . . 
	cmp	m			;d871	be 	. 
	jnc	selerr		;d872	d2 84 d8 	. . . 
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
selerr:
	lxi	h,0		;d884	21 00 00 	. . . 
	xra	a			;d887	af 	. 
	sta	cdisk		;d888	32 04 00 	2 . . 
	inr	a			;d88b	3c 	< 
	ret			;d88c	c9 	. 

;----------------------------------------------------------------------------
; home - Home BIOS entry. Move to track zero position.
;----------------------------------------------------------------------------
home:	mvi	c,0		;d88d	0e 00 	. . 

;----------------------------------------------------------------------------
; settrk - Set Track BIOS entry. C contains the desired track number.
;    The track number is saved in trkNum for later use. No actual
;    drive activity takes place.
;----------------------------------------------------------------------------
settrk:	mov	a,c			;d88f	79 	y 
	sta	trkNum		;d890	32 96 df 	2 . . 
	ret			;d893	c9 	. 

;----------------------------------------------------------------------------
; setsec - Set Sector BIOS entry. C contains the desired sector number.
;    The sector number has already been translated through the skew table.
;    The sector number is saved in secNum for later use. No actual
;    drive activity takes place.
;----------------------------------------------------------------------------
setsec:	mov	a,c			;d894	79 	y 
	sta	secNum		;d895	32 97 df 	2 . . 
	ret			;d898	c9 	. 

;----------------------------------------------------------------------------
; setdma - Set DMA BIOS entry. BC contains the address for reading or
;    writing sector data for subsequent I/O operations. The address is
;    stored in dmaAddr.
;----------------------------------------------------------------------------
setdma:	mov	h,b			;d899	60 	` 
	mov	l,c			;d89a	69 	i 
	shld	dmaAddr		;d89b	22 98 df 	" . . 
	ret			;d89e	c9 	. 
;----------------------------------------------------------------------------
; sectran - Sector translation BIOS entry. Convert logical sector number in
;    BC to physical sector number in HL using the skew table passed in DE.
;----------------------------------------------------------------------------
sectran:
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
	call	uldHead		;d8c9	cd 90 db
	jmp	0dc09h		;d8cc
	push	b		;d8cf
	call	uldHead		;d8d0	cd 90 db
	pop	b		;d8d3	c1	.
	jmp	list		;d8d4	c3 0f dc 	. . . 

;----------------------------------------------------------------------------
; read - Read sector BIOS entry. Read one sector using the trkNum, secNum
;    and dmaAddr specified for diskNum. Returns 0 in A if successful, 1 in A
;    if a non-recoverable error has occured.
;----------------------------------------------------------------------------
read:
	mvi	a,1		;set the "verify track number" flag to true
	call	rTrkSec		;retrieve track in c, physical sector in b
	di
	call	readSec		;read the sector
	jmp	exitDio		;disk i/o exit routine

;----------------------------------------------------------------------------
; write - Write sector BIOS entry. Write one sector using the trkNum, secNum
;    and dmaAddr specified for diskNum. Returns 0 in A if successful, 1 in A
;    if a non-recoverable error has occured.
;----------------------------------------------------------------------------
write:
	xra	a		;set the "verify track number" flag to false
	call	rTrkSec		;retrieve track in c, physical sector in b
	di
	call	wrtSec		;write sector
	jnz	exitDio		;write failed, exit
	lda	flags
	ani	fWrtVfy		;are we verifying writes?
	jz	exitDio		;no, exit
	mvi	a,1		;set the "verify track number" flag to true
	call	rTrkSec		;d8f8	cd 11 d9 	. . . 
	lxi	h,altBuf		;d8fb	21 00 de 	. . . 
	call	readSec		;d8fe	cd 5f d9 	. _ . 
exitDio:
	push	psw			;d901	f5 	. 
	lda	flags		;d902	3a ff db 	: . . 
	ani	fEnaInt		;d905	e6 10 	. . 
	jz	noInts		;d907	ca 0b d9 	. . . 
	ei			;d90a	fb 	. 
noInts:
	pop	psw			;d90b	f1 	. 
	mvi	a,0		;d90c	3e 00 	> . 
	rz			;d90e	c8 	. 
	inr	a			;d90f	3c 	< 
	ret			;d910	c9 	. 
;
; rTrkSec - return track in c, physical sector in b
rTrkSec:
	sta	trkVrfy		;d911	32 9a df 	2 . . 
	lda	diskNum		;d914	3a 95 df 	: . . 
	mov	c,a			;d917	4f 	O 
	call	chkmnt		;d918	cd 26 d9 	. & . 
	mov	a,c			;d91b	79 	y 
	sta	diskNum		;d91c	32 95 df 	2 . . 
	lhld	trkNum		;d91f	2a 96 df 	* . . 
	mov	c,l			;d922	4d 	M 
	dcr	h			;d923	25 	% 
	mov	b,h			;d924	44 	D 
	ret			;d925	c9 	. 
;
chkmnt:
	lda	flags		;d926	3a ff db 	: . . 
	ani	004h		;d929	e6 04 	. . 
	rz			;d92b	c8 	. 
	lxi	h,mntdrv		;d92c	21 50 d9 	. P . 
	mov	a,c			;d92f	79 	y 
	adi	'A'		;d930	c6 41 	. A 
	cmp	m			;d932	be 	. 
	jz	mounted		;d933	ca 40 d9 	. @ . 
	mov	m,a			;d936	77 	w 
	lxi	h,mount		;d937	21 43 d9 	. C . 
	call	prmsg		;d93a	cd 74 d7 	. t . 
	call	conin		;d93d	cd 09 dc 	. . . 
mounted:
	mvi	c,0		;d940	0e 00 	. . 
	ret			;d942	c9 	. 

mount:	db	cr,lf,'mount disk '
mntdrv	db	'A'
	db	', then <cr>',cr,lf,'$'

readSec:
	call	selTrk		;d95f	cd e6 da 	. . . 
	rnz			;d962	c0 	. 
reReadP:
	push	b			;d963	c5 	. 
reRead:
	call	rtryChk		;d964	cd cd db 	. . . 
	pop	b			;d967	c1 	. 
	rnz			;d968	c0 	. 
	push	b			;d969	c5 	. 
	mov	a,b			;d96a	78 	x 
	call	altSkew		;d96b	cd d5 da 	. . . 
	lxi	h,altBuf		;d96e	21 00 de 	. . . 
	call	rdPSec		;d971	cd f4 d9 	. . . 
	lda	flags		;d974	3a ff db 	: . . 
	ani	fRawIO		;d977	e6 08 	. . 
	jnz	rdExit		;d979	c2 f1 d9 	. . . 
	lda	trkNum		;d97c	3a 96 df 	: . . 
	cpi	6		;d97f	fe 06 	. . 
	jnc	rTrk676		;d981	d2 ac d9 	. . . 
	lxi	h,altBuf+t0Stop		;d984	21 83 de 	. . . 
	inr	m			;d987	34 	4 
	jnz	reRead		;d988	c2 64 d9 	. d . 
	lxi	h,altBuf		;d98b	21 00 de 	. . . 
	mov	a,m			;d98e	7e 	~ 
	ani	07fh		;d98f	e6 7f 	.  
	pop	b			;d991	c1 	. 
	cmp	c			;d992	b9 	. 
	jnz	rdTrkEr		;d993	c2 ea d9 	. . . 
	push	b			;d996	c5 	. 
	lhld	dmaAddr		;d997	2a 98 df 	* . . 
	mov	b,h			;d99a	44 	D 
	mov	c,l			;d99b	4d 	M 
	lxi	h,altBuf+t0Data		;d99c	21 03 de 	. . . 
	call	moveBuf		;d99f	cd c6 da 	. . . 
	lxi	h,altBuf+t0CSum		;d9a2	21 84 de 	. . . 
	cmp	m			;d9a5	be 	. 
	jnz	reRead		;d9a6	c2 64 d9 	. d . 
	pop	b			;d9a9	c1 	. 
	xra	a			;d9aa	af 	. 
	ret			;d9ab	c9 	. 

rTrk676:
	dcx	h			;d9ac	2b 	+ 
	mov	a,m			;d9ad	7e 	~ 
	ora	a			;d9ae	b7 	. 
	jnz	reRead		;d9af	c2 64 d9 	. d . 
	dcx	h			;d9b2	2b 	+ 
	inr	m			;d9b3	34 	4 
	jnz	reRead		;d9b4	c2 64 d9 	. d . 
	lxi	h,altBuf		;d9b7	21 00 de 	. . . 
	mov	a,m			;d9ba	7e 	~ 
	ani	07fh		;d9bb	e6 7f 	.  
	pop	b			;d9bd	c1 	. 
	cmp	c			;d9be	b9 	. 
	jnz	rdTrkEr		;d9bf	c2 ea d9 	. . . 
	inx	h			;d9c2	23 	# 
	mov	a,m			;d9c3	7e 	~ 
	cmp	b			;d9c4	b8 	. 
	jnz	reReadP		;d9c5	c2 63 d9 	. c . 
	push	b			;d9c8	c5 	. 
	lhld	dmaAddr		;d9c9	2a 98 df 	* . . 
	mov	b,h			;d9cc	44 	D 
	mov	c,l			;d9cd	4d 	M 
	lxi	h,altBuf+t6Data		;d9ce	21 07 de 	. . . 
	call	moveBuf		;d9d1	cd c6 da 	. . . 
	lxi	h,altBuf+6		;d9d4	21 06 de 	. . . 
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
	jnz	reRead		;d9e4	c2 64 d9 	. d . 
	pop	b			;d9e7	c1 	. 
	xra	a			;d9e8	af 	. 
	ret			;d9e9	c9 	. 

rdTrkEr:
	xra	a			;d9ea	af 	. 
	call	reTkSec		;d9eb	cd f2 da 	. . . 
	jmp	reReadP		;d9ee	c3 63 d9 	. c . 

rdExit:
	pop	b			;d9f1	c1 	. 
	xra	a			;d9f2	af 	. 
	ret			;d9f3	c9 	. 

rdPSec:
	call	setSync		;d9f4	cd 12 da 	. . . 
	mvi	c,altLen		;d9f7	0e 89 	. . 
rdLoop:
	in	drvStat		;d9f9	db 08 	. . 
	ora	a			;d9fb	b7 	. 
	jm	rdLoop		;d9fc	fa f9 d9 	. . . 
	in	drvData		;d9ff	db 0a 	. . 
	mov	m,a			;da01	77 	w 
	inx	h			;da02	23 	# 
	dcr	c			;da03	0d 	. 
	jz	rDone		;da04	ca 10 da 	. . . 
	dcr	c			;da07	0d 	. 
	nop			;da08	00 	. 
	in	drvData		;da09	db 0a 	. . 
	mov	m,a			;da0b	77 	w 
	inx	h			;da0c	23 	# 
	jnz	rdLoop		;da0d	c2 f9 d9 	. . . 
rDone:
	xra	a			;da10	af 	. 
	ret			;da11	c9 	. 
setSync:
	call	ldHead		;da12	cd 7f db 	.  . 
wtSecTr:
	in	drvSec		;da15	db 09 	. . 
	rar			;da17	1f 	. 
	jc	wtSecTr		;da18	da 15 da 	. . . 
	ani	01fh		;da1b	e6 1f 	. . 
	cmp	e			;da1d	bb 	. 
	jnz	wtSecTr		;da1e	c2 15 da 	. . . 
	ret			;da21	c9 	. 

wrtSec:
	call	selTrk		;da22	cd e6 da 	. . . 
	rnz			;da25	c0 	. 
	lda	flags		;da26	3a ff db 	: . . 
	ani	fRawIO		;da29	e6 08 	. . 
	jnz	setHCS		;da2b	c2 78 da 	. x . 
	lda	trkNum		;da2e	3a 96 df 	: . . 
	cpi	6		;da31	fe 06 	. . 
	jnc	wTrk676		;da33	d2 53 da 	. S . 
	push	b			;da36	c5 	. 
	mov	a,c			;da37	79 	y 
	lxi	b,altBuf		;da38	01 00 de 	. . . 
	stax	b			;da3b	02 	. 
	xra	a			;da3c	af 	. 
	inx	b			;da3d	03 	. 
	stax	b			;da3e	02 	. 
	inr	a			;da3f	3c 	< 
	inx	b			;da40	03 	. 
	stax	b			;da41	02 	. 
	inx	b			;da42	03 	. 
	lhld	dmaAddr		;da43	2a 98 df 	* . . 
	call	moveBuf		;da46	cd c6 da 	. . . 
	mvi	a,0ffh		;da49	3e ff 	> . 
	stax	b			;da4b	02 	. 
	inx	b			;da4c	03 	. 
	mov	a,d			;da4d	7a 	z 
	stax	b			;da4e	02 	. 
	pop	b			;da4f	c1 	. 
	jmp	setHCS		;da50	c3 78 da 	. x . 

wTrk676:
	push	b			;da53	c5 	. 
	lxi	b,altBuf+t6Data		;da54	01 07 de 	. . . 
	lhld	dmaAddr		;da57	2a 98 df 	* . . 
	call	moveBuf		;da5a	cd c6 da 	. . . 
	mvi	a,0ffh		;da5d	3e ff 	> . 
	stax	b			;da5f	02 	. 
	inx	b			;da60	03 	. 
	xra	a			;da61	af 	. 
	stax	b			;da62	02 	. 
	mov	a,d			;da63	7a 	z 
	lhld	altBuf+2		;da64	2a 02 de 	* . . 
	add	h			;da67	84 	. 
	add	l			;da68	85 	. 
	lhld	altBuf+5		;da69	2a 05 de 	* . . 
	add	h			;da6c	84 	. 
	add	l			;da6d	85 	. 
	sta	altBuf+t6CSum		;da6e	32 04 de 	2 . . 
	pop	b			;da71	c1 	. 
	lxi	h,altBuf		;da72	21 00 de 	. . . 
	mov	m,c			;da75	71 	q 
	inx	h			;da76	23 	# 
	mov	m,b			;da77	70 	p 
setHCS:
	mov	a,c			;da78	79 	y 
	adi	(-43 and 0ffh)		;da79	c6 d5 	. . 
	mvi	a,0		;da7b	3e 00 	> . 
	rar			;da7d	1f 	. 
	stc			;da7e	37 	7 
	rar			;da7f	1f 	. 
	mov	d,a			;da80	57 	W 
	mov	a,b			;da81	78 	x 
	call	altSkew		;da82	cd d5 da 	. . . 
wtWrSec:
	in	drvSec		;da85	db 09 	. . 
	rar			;da87	1f 	. 
	jc	wtWrSec		;da88	da 85 da 	. . . 
	ani	01fh		;da8b	e6 1f 	. . 
	cmp	e			;da8d	bb 	. 
	jnz	wtWrSec		;da8e	c2 85 da 	. . . 
	mov	a,d			;da91	7a 	z 
	out	drvCtl		;da92	d3 09 	. . 
	lxi	h,altBuf		;da94	21 00 de 	. . . 
	lxi	b,0100h+altLen		;da97	01 89 01 	. . . 
	mvi	d,enwdMsk		;da9a	16 01 	. . 
	mvi	a,080h		;da9c	3e 80 	> . 
	ora	m			;da9e	b6 	. 
	mov	e,a			;da9f	5f 	_ 
	inx	h			;daa0	23 	# 
wrSec:
	in	drvStat		;daa1	db 08 	. . 
	ana	d			;daa3	a2 	. 
	jnz	wrSec		;daa4	c2 a1 da 	. . . 
	add	e			;daa7	83 	. 
	out	drvData		;daa8	d3 0a 	. . 
	mov	a,m			;daaa	7e 	~ 
	inx	h			;daab	23 	# 
	mov	e,m			;daac	5e 	^ 
	inx	h			;daad	23 	# 
	dcr	c			;daae	0d 	. 
	jz	wrDone		;daaf	ca b8 da 	. . . 
	dcr	c			;dab2	0d 	. 
	out	drvData		;dab3	d3 0a 	. . 
	jnz	wrSec		;dab5	c2 a1 da 	. . . 
wrDone:
	in	drvStat		;dab8	db 08 	. . 
	ana	d			;daba	a2 	. 
	jnz	wrDone		;dabb	c2 b8 da 	. . . 
	out	drvData		;dabe	d3 0a 	. . 
	dcr	b			;dac0	05 	. 
	jnz	wrDone		;dac1	c2 b8 da 	. . . 
	xra	a			;dac4	af 	. 
	ret			;dac5	c9 	. 

;------------------------------------------------------------------------------
; moveBuf - move sector buffer (128 bytes) from (hl) to (bc). Compute
;   checksum on all bytes and return in a.
;------------------------------------------------------------------------------
moveBuf:
	mvi	d,0		;dac6	16 00 	. . 
	mvi	e,secLen		;dac8	1e 80 	. . 
movLoop:
	mov	a,m			;daca	7e 	~ 
	stax	b			;dacb	02 	. 
	add	d			;dacc	82 	. 
	mov	d,a			;dacd	57 	W 
	inx	b			;dace	03 	. 
	inx	h			;dacf	23 	# 
	dcr	e			;dad0	1d 	. 
	jnz	movLoop		;dad1	c2 ca da 	. . . 
	ret			;dad4	c9 	. 
;------------------------------------------------------------------------------
; altSkew - Do Altair sector skew like disk basic. For sectors greater than 6,
;    physical = (logical * 17) mod 32. Returns physical sector number in e.
;    This is done on top of the secTran skew table mechanism of CPM. The math
;    works out such that this call to altSkew does almost nothing.
;------------------------------------------------------------------------------
altSkew:
	mov	e,a			;dad5	5f 	_ 
	lda	trkNum		;dad6	3a 96 df 	: . . 
	cpi	6		;dad9	fe 06 	. . 
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
;------------------------------------------------------------------------------
;  selTrk - select the drive, go to the proper track (specified in diskNum
;     and C)
;------------------------------------------------------------------------------
selTrk:	mvi     a,maxTry        ;set retry count (5 tries)
	sta	rtryCnt		;dae8	32 9c df 	2 . . 
	call	selDrv		;daeb	cd 46 db 	. F . 
	rnz			;daee	c0 	. 
	mov	a,m			;daef	7e 	~ 
	cpi	unTrack		;daf0	fe 7f 	.  
reTkSec:
	cz	ldSeek0		;daf2	cc ae db 	. . . 
	mov	a,m			;daf5	7e 	~ 
	mov	m,c			;daf6	71 	q 
	mov	e,a			;daf7	5f 	_ 
	call	ldHead		;daf8	cd 7f db 	.  . 
	mov	a,e			;dafb	7b 	{ 
	sub	c			;dafc	91 	. 
	rz			;dafd	c8 	. 
	mvi	d,dcStepI		;dafe	16 01 	. . 
	jc	mulStep		;db00	da 07 db 	. . . 
	mvi	d,dcStepO		;db03	16 02 	. . 
	cma			;db05	2f 	/ 
	inr	a			;db06	3c 	< 

; mulStep - issue multiple track steps in or out (controller step command
;    in d). The number of tracks to step is passed as -steps. E.g., 10
;    steps passed as -10.
mulStep:
	mov	e,a			;db07	5f 	_ 
wMoveOk:
	in	drvStat		;db08	db 08 	. . 
	ani	moveMsk		;db0a	e6 02 	. . 
	jnz	wMoveOk		;db0c	c2 08 db 	. . . 
	mov	a,d			;db0f	7a 	z 
	out	drvCtl		;db10	d3 09 	. . 
	mov	a,e			;db12	7b 	{ 
	inr	a			;db13	3c 	< 
	jnz	mulStep		;db14	c2 07 db 	. . . 
	call	rtryChk		;db17	cd cd db 	. . . 
	jz	stpDone		;db1a	ca 23 db 	. # . 
	call	selTrk0		;db1d	cd ab db 	. . . 
	jmp	retErr		;db20	c3 d6 db 	. . . 
stpDone:
	lda	trkVrfy		;db23	3a 9a df 	: . . 
	ora	a			;db26	b7 	. 
	jnz	vrfyTrk		;db27	c2 30 db 	. 0 . 
	lda	flags		;db2a	3a ff db 	: . . 
	ani	fRawIO		;db2d	e6 80 	. . 
	rz			;db2f	c8 	. 

;  vrfyTrk - Verify we're on the right track (passed in c) by reading
;     the track number that is stored in the sync byte at the start
;     of every sector. We don't care which sector we read.
vrfyTrk:
	in	drvSec		;db30	db 09 	. . 
	rar			;db32	1f 	. 
	jc	vrfyTrk		;db33	da 30 db 	. 0 . 
wtVrfy:
	in	drvStat		;db36	db 08 	. . 
	ora	a			;db38	b7 	. 
	jm	wtVrfy		;db39	fa 36 db 	. 6 . 
	in	drvData		;db3c	db 0a 	. . 
	ani	07fh		;db3e	e6 7f 	. 
	cmp	c			;db40	b9 	. 
	rz			;db41	c8 	. 
	xra	a			;db42	af 	. 
	jmp	reTkSec		;db43	c3 f2 da 	. . . 
;-----------------------------------------------------------------------------
;  selDrv - select the drive specified in diskNum
;-----------------------------------------------------------------------------
selDrv:
	lda	diskNum		;db46	3a 95 df 	: . . 
	mov	e,a			;db49	5f 	_ 
	lda	selNum		;db4a	3a 9b df 	: . . 
	cmp	e			;db4d	bb 	. 
	mov	a,e			;db4e	7b 	{ 
	sta	selNum		;db4f	32 9b df 	2 . . 
	jnz	selNew		;db52	c2 5c db 	. \ . 
	in	drvStat		;db55	db 08 	. . 
	ani	selMask		;db57	e6 08 	. . 
	jz	rTrkTbl		;db59	ca 6c db 	. l . 
;
;  selNew - select a new drive, deselect the current, then select the new
selNew:
	mvi	a,dSelect		;db5c	3e ff 	> . 
	out	drvSel		;db5e	d3 08 	. . 
	lda	selNum		;db60	3a 9b df 	: . . 
	out	drvSel		;db63	d3 08 	. . 
	in	drvStat		;db65	db 08 	. . 
	ani	selMask		;db67	e6 08 	. . 
	jnz	selNew		;db69	c2 5c db 	. \ . 
rTrkTbl:
	lda	numDisk		;db6c	3a fb db 	: . . 
	cmp	e			;db6f	bb 	. 
	jc	retErr		;db70	da d6 db 	. . . 
	lxi	h,trkTbl		;db73	21 9e df 	. . . 
	mvi	d,0		;db76	16 00 	. . 
	dad	d			;db78	19 	. 
	ora	m			;db79	b6 	. 
	jm	retErr		;db7a	fa d6 db 	. . . 
	xra	a			;db7d	af 	. 
	ret			;db7e	c9 	. 
ldHead:
	in	drvStat		;db7f	db 08 	. . 
	ani	headMsk		;db81	e6 04 	. . 
	rz			;db83	c8 	. 
	mvi	a,dcLoad		;db84	3e 04 	> . 
	out	drvCtl		;db86	d3 09 	. . 
wtHead:
	in	drvStat		;db88	db 08 	. . 
	ani	headMsk		;db8a	e6 04 	. . 
	jnz	wtHead		;db8c	c2 88 db 	. . . 
	ret			;db8f	c9 	. 

uldHead:
	mvi	a,dcUload		;db90	3e 08 	> . 
	out	drvCtl		;db92	d3 09 	. . 
	ret			;db94	c9 	. 

sdb95h:
	lxi	h,flags		;db95	21 ff db 	. . . 
	mov	a,m			;db98	7e 	~ 
	ani	0f7h		;db99	e6 f7 	. . 
	mov	m,a			;db9b	77 	w 
	mvi	a,07fh		;db9c	3e 7f 	>  
	sta	selNum		;db9e	32 9b df 	2 . . 
	lxi	h,07f7fh		;dba1	21 7f 7f 	.   
	shld	trkTbl		;dba4	22 9e df 	" . . 
	shld	0dfa0h		;dba7	22 a0 df 	" . . 
	ret			;dbaa	c9 	. 

selTrk0:
	call	selDrv		;dbab	cd 46 db 	. F . 
ldSeek0:
	call	ldHead		;dbae	cd 7f db 	.  . 
seek0:
	in	drvStat		;dbb1	db 08 	. . 
	ani	moveMsk		;dbb3	e6 02 	. . 
	jnz	seek0		;dbb5	c2 b1 db 	. . . 
	mvi	a,dcStepO		;dbb8	3e 02 	> . 
	out	drvCtl		;dbba	d3 09 	. . 
	in	drvStat		;dbbc	db 08 	. . 
	ani	trk0Msk		;dbbe	e6 40 	. @ 
	jnz	seek0		;dbc0	c2 b1 db 	. . . 
	lda	selNum		;dbc3	3a 9b df 	: . . 
	mov	e,a			;dbc6	5f 	_ 
	call	rTrkTbl		;dbc7	cd 6c db 	. l . 
	mvi	m,0		;dbca	36 00 	6 . 
	ret			;dbcc	c9 	. 

;------------------------------------------------------------------------------
; rtryChk - retry counter check. Decrement retry counter. Returns zero if
;     more tries left, non-zero if retry counter reaches zero.
;------------------------------------------------------------------------------
rtryChk:
	lxi	h,rtryCnt		;dbcd	21 9c df 	. . . 
	dcr	m			;dbd0	35 	5 
	jz	retErr		;dbd1	ca d6 db 	. . . 
	xra	a			;dbd4	af 	. 
	ret			;dbd5	c9 	. 
;
; retErr - Return error code with 1 in accumulator and non-zero status flag
retErr:
	mvi	a,1		;dbd6	3e 01 	> . 
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
numDisk:
	db	4
	dw	altBuf		;dbfc	00 	. 
	db	16		;dbfd	de 10 	. . 
flags:	db	0		;dbff	00 	. 

fCldCmd equ	001h		;true = CCP process cmd on cold start
fWrmCmd equ	002h		;true = CCP process cmd on warm start
fRawIO  equ	008h		;r/w directly from altBuf
fEnaInt equ	010h		;enable interrupts after disk I/O
fWrtVfy equ	040h		;write verify flag (true = verify)
fTrkVfy equ	080h		;force track number verification

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

;------------------------------------------------------------------------------
; altBuf - Altair buffer contains the 137 bytes read straight from
;   the Altair drive. This BIOS assumes the disk is laid out in a
;   manner similar to the Altair Disk Basic format. Sectors in tracks 0-5
;   have a different layout than sectors in tracks 6-76.
;------------------------------------------------------------------------------

altBuf:	ds	131		;altair disk buffer

; Tracks 0-5

t0Trk   equ     0               ;offset of track number
t0Data  equ     3               ;offset of 128 byte data payload
t0Stop  equ     131             ;offset of stop byte (0ffh)
t0CSum  equ     132             ;offset of checksum

; Tracks 6-76

t6Trk   equ     0               ;offset of track number
t6Sec   equ     1               ;offset of sector number
t6CSum  equ     4               ;offset of checksum
t6Data  equ     7               ;offset of 128 byte data payload
t6Stop  equ     135             ;offset of stop byte (0ffh)
t6Zero  equ     136             ;offset of unused, but checked for zero.

lde83h	ds	1
lde84h	ds	2
lde86h	ds	1
	ds	2

;-----------------------------------------------------------------------------
;  Disk scratchpad areas defined in the DPH table
;-----------------------------------------------------------------------------
dirBuf	ds	128		;bdos directory scratchpad
alv0	ds	19		;
csv0	ds	cks		;change disk scratchpad
alv1	ds	19		;bdos storage allocation scratchpad
csv1	ds	cks
alv2	ds	19
csv2	ds	cks
alv3	ds	19
csv3	ds	cks
;-----------------------------------------------------------------------------
; disk control data
;-----------------------------------------------------------------------------
diskNum ds	1		;current disk number	DF95
trkNum  ds	1		;track num (sector num MUST follow in memory)
secNum  ds	1		;sector number for disk operations
dmaAddr ds	2		;dma address for disk operations
trkVrfy	ds	1		;verify track number if <> 0
selNum  ds      1               ;disk number currently selected on controller
rtryCnt	ds	1		;retry counter
	ds	1
trkTbl	db	unTrack, unTrack, unTrack, unTrack

biosEnd	equ	($ AND 0fc00h)+0400h	;round msb up to next 1K boundary

	end

