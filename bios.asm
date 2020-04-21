;--------------------------------------------------------------------
;
;	CP/M 2.2 BIOS for Lifeboat Associates CP/M2 Vers 2.20 on
;	MITS Altair 8800x and 88-DCCD Floppy Drive
;
;	Original disassembly of the Lifeboat BIOS from LIFEBOAT.DSK
;	provided by Mike Douglas at deramp.com
;
;	Source code regeneration by Patrick Linstruth, April 2020
;
;--------------------------------------------------------------------
	

; CPM module locations

; Change MSIZE to the desired CP/M memory size in K.

MSIZE	equ	24		;Distribution size

BOOTLEN	equ	3*128		;Boot length
CCPLEN	equ	0800h		;CPM 2.2 fixed
BDOSLEN	equ	0e00h		;CPM 2.2 fixed
BIOSLEN	equ	0900h		;BIOS length
SYSGEN	equ	0900h		;SYSGEN image location
CPMOVE	equ	0900h		;CPMOVE image location

; These equates are automatically changed by MSIZE.
BIOS	equ	(MSIZE*1024)-BIOSLEN	; Memory location of BIOS
CCP	equ	BIOS-BDOSLEN-CCPLEN
BDOS	equ	BIOS-BDOSLEN
OFFSET	equ	BOOTLEN+CCPLEN+BDOSLEN			;offset in SYSGEN CPMXX.COM file
OVERLAY	equ	SYSGEN-BIOS+BOOTLEN+CCPLEN+BDOSLEN	;to overlay SYSGEN image
MOVCPM	equ	CPMOVE-BIOS+CCPLEN+BDOSLEN		;to overlay MOVCPM image
SOFFSET	equ	SYSGEN+BOOTLEN+CCPLEN+BDOSLEN		;offset in SYSGEN image

	org	bios

; CCP equates

CMDLEN	equ	CCP+7		;command length

; CPM page zero equates

WBOOTV	equ	000h		;warm boot vector location
WBOOTA	equ	001h		;warm boot vector address
BDOSV	equ	005h		;bdos entry vector location
BDOSA	equ	006h		;address field of jmp BDOS
CDISK	equ	004h		;CPM current disk
DEFDMA	equ	080h		;default dma address

; MITS Disk Drive Controller Equates

DRVSEL	equ	8		;drive select port (out)
DRVSTAT	equ	8		;drive status port (in)
DRVCTL	equ	9		;drive control port(out)
DRVSEC	equ	9		;drive sector position (in)
DRVDATA	equ	10		;drive read/write data

ENWDMSK	equ	001h		;enter new write data bit mask
HEADMSK	equ	004h		;mask to get head load bit alone
MOVEMSK	equ	002h		;mask to get head move bit alone
TRK0MSK	equ	040h		;mask to get track zero bit alone
DSELECT	equ	0ffh		;deselects drive when written to DRVSEL
SELMASK	equ	008h		;"not used" bit is zero when drive selected

DCSTEPI	equ	001h		;drive command - step in
DCSTEPO	equ	002h		;drive command - step out
DCLOAD	equ	004h		;drive command - load head
DCULOAD	equ	008h		;drive command - unload head
DCWRITE	equ	080h		;drive command - start write sequence

; disk information equates

NUMTRK	equ	77		;number of tracks
NUMSECT	equ	32		;number of sectors per track
ALTLEN	equ	137		;length of Altair sector
SECLEN	equ	128		;length of CPM sector
DSM0	equ	149		;max block number (150 blocks of 2048 bytes)
DRM0	equ	63		;max directory entry number (64 entries) 
CKS	equ	(DRM0+1)/4	;directory check space
MAXTRY	equ	5		;maximum number of disk I/O tries
UNTRACK	equ	07fh		;unknown track number

; misc equates

CR	equ	13		;ascii for carriage return
LF	equ	10		;ascii for line feed

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
	jmp	boot
wboote:	jmp	wboot
	jmp	const
	jmp	coninul			;unload head before conin
	jmp	conout
	jmp	list
	jmp	punch
	jmp	reader
	jmp	home
	jmp	seldsk
	jmp	settrk
	jmp	setsec
	jmp	setdma
	jmp	read
	jmp	write
	jmp	listst
	jmp	sectran

signon:
	db	CR,LF
	db	'CP/M2 on Altair',CR,LF
	db	'0'+(MSIZE/10),'0'+(MSIZE mod 10)
	db	'K Vers 2.20  ',CR,LF
	db	'(c) 1981 Lifeboat Associates$'

; print message at HL to '$'

prmsg:	mov	a,m
	cpi	'$'
	rz
	mov	c,m
	inx	h
	push	h
	call	conout
	pop	h
	jmp	prmsg

;----------------------------------------------------------------------------
; boot - Cold boot BIOS entry. CPM is already loaded in memory. Hand
;    control to the CCP.
;----------------------------------------------------------------------------
boot:
	xra	a
	sta	CDISK		;set initially to disk a
	call	cinit		;initialize user area
	jmp	entCpm		;go to cp/m

;----------------------------------------------------------------
; wboot - Warm boot BIOS entry. Reload CPM from disk up to, but
;    not including the BIOS. Re-enter CPM after loading.
;----------------------------------------------------------------
wboot:
	lxi	sp,0100h	;init stack pointer
	call	clrDrv		;clear selected drive and track table
	xra	a
	sta	diskNum		;disk zero is boot disk
	sta	trkNum		;set track number to zero
	lxi	h,CCP-BOOTLEN	;track 0 sector 1 is boot loader
	inr	a		;sector 1
	call	loadTrk		;load track 0
	mvi	a,1		;track 1
	sta	trkNum
	lxi	h,CCP+0e80h
	call	loadTrk
	call	winit

; entCpm: - enter CPM. Set page zero variables, enter CPM with or without
;   command line based on

entCpm:	mvi	a,0c3h		;8080 "jmp" opcode
	sta	WBOOTV		;store in 1st byte of warm boot vector
	sta	BDOSV		;and 1st byte of bdos entry vector
	lxi	h,wboote	;get the warm boot address
	shld	WBOOTV+1	;and put it after the jmp
	lxi	h,BDOS+6	;BDOS entry address
	shld	6		;
	lxi	h,cldDone	;get the "cold start done" flag
	mov	a,m
	ora	a
	mvi	m,1		;set the flag true - cold start has been done
	push	psw
	lxi	h,signon	;display sign on banner
	cz	prmsg
	pop	psw
	lxi	h,CDISK		;get current disk number
	mov	c,m		;c = current disk number
	lda	flags		;check the proper "process command line" flag
	jz	coldSt		;jump if this is cold start
	ani	FWRMCMD		;warm start - run default command line?
	jmp	cmdChk

coldSt:	ani	FCLDCMD		;cold start - run default command line?
cmdChk:	jz	CCP+3		;no, enter CCP and clear cmd line
	jmp	CCP		;yes, enter CCP with possible cmd line

; loadTrk - load one track into memory. Read odd sectors into every other 
;    128 bytes of memory until the BIOS base address is reached or all
;    32 sectors in the track have been read. Then read even sectors into
;    the opposite 128 byte sections of memory until the BIOS base address
;    is reached or all 32 sectors in the track have been read.

loadTrk	sta	secNum		;save the sector number to we're on
	shld	dmaAddr		;save the destination address
	mov	a,h
	cpi	(bios shr 8)	;current address >= bios start address?
	jnc	nxtSec		;yes, skip read (don't overwrite bios)
	cpi	(CCP shr 8)	;current address < CCP start address?
	jc	nxtSec		;yes, skip read (not to valid data yet)
	call	read		;read a sector
	jnz	wboot		;fatal read error
nxtSec	lhld	dmaAddr		;hl = destination address
	lxi	d,0100h		;increment destination address by 256 bytes
	dad	d
	lda	secNum		;a = sector number
	adi	2		;jump 2 sectors each read
	cpi	NUMSECT+1	;past the last sector in the track?
	jc	loadTrk		;not yet, keep reading
	sui	NUMSECT-1	;compute starting even sector number
	lxi	d,-0f80h	;compute load address for 1st even sector
	dad	d
	cpi	3		;done both odd and even sectors in a track?
	jnz	loadTrk		;no, go do even sectors
	ret

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
	dw	NUMSECT		;sectors per track
	db	4		;allocation block shift factor (BSH)
	db	00fh		;data location block mask (BLM)
	db	0		;extent mask (EXM), see note above
	dw	DSM0		;maximum block number (DSM)
	dw	DRM0		;maximum directory entry number (DRM)
	db	080h,0		;AL0, AL1, see note above
	dw	CKS		;CKS (DRM+1)/4
	dw	2		;reserved tracks for CPM and bootloader

;----------------------------------------------------------------------------
; seldsk - Select Disk BIOS entry. C contains the disk number to select.
;    Validate the disk number and return a pointer to the disk parameter
;    header in HL. Zero is returned in HL for invalid drive number. The
;    selected disk number is stored in diskNum. No actual drive activity 
;    takes place.
;----------------------------------------------------------------------------
seldsk	mov	a,c		;a = drive number
	ani	07fh
	lxi	h,numDisk	;verify drive number less than number of disks
	cmp	m
	jnc	selerr		;drive number error
	sta	diskNum		;save the selected disk number
	mvi	h,0		;compute disk parameter header address
	mov	l,a		;(16*drvNum) + dpHead
	dad	h
	dad	h
	dad	h
	dad	h
	lxi	d,dpHead
	dad	d		;hl points to the DPH for the passed drive
	ret
selerr	lxi	h,0		;error - hl = 0, cdisk = 0, a = 1
	xra	a
	sta	CDISK
	inr	a
	ret

;----------------------------------------------------------------------------
; home - Home BIOS entry. Move to track zero position.
;----------------------------------------------------------------------------
home:	mvi	c,0		;d88d	0e 00 	. . 

;----------------------------------------------------------------------------
; settrk - Set Track BIOS entry. C contains the desired track number.
;    The track number is saved in trkNum for later use. No actual
;    drive activity takes place.
;----------------------------------------------------------------------------
settrk:	mov	a,c
	sta	trkNum
	ret

;----------------------------------------------------------------------------
; setsec - Set Sector BIOS entry. C contains the desired sector number.
;    The sector number has already been translated through the skew table.
;    The sector number is saved in secNum for later use. No actual
;    drive activity takes place.
;----------------------------------------------------------------------------
setsec:	mov	a,c
	sta	secNum
	ret

;----------------------------------------------------------------------------
; setdma - Set DMA BIOS entry. BC contains the address for reading or
;    writing sector data for subsequent I/O operations. The address is
;    stored in dmaAddr.
;----------------------------------------------------------------------------
setdma:	mov	h,b
	mov	l,c
	shld	dmaAddr
	ret

;----------------------------------------------------------------------------
; sectran - Sector translation BIOS entry. Convert logical sector number in
;    BC to physical sector number in HL using the skew table passed in DE.
;----------------------------------------------------------------------------
sectran:
	lxi	h,xlate		;table address into HL
	mvi	b,0		;clear b
	dad	b		;offset to logical sector number
	mov	l,m		;get physical sector in L
	mvi	h,0		;set H to zero
	ret

;---------------------------------------------------------------------------
; xlate - sector translation table for skew
;---------------------------------------------------------------------------
xlate:
	db	01,09,17,25,03,11,19,27,05,13,21,29,07,15,23,31
	db	02,10,18,26,04,12,20,28,06,14,22,30,08,16,24,32

; coninul - First unloads the head then calls standard conin

coninul	call	uldHead
	jmp	conin

	push	b
	call	uldHead
	pop	b
	jmp	list

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
	ani	FWRTVFY		;are we verifying writes?
	jz	exitDio		;no, exit
	mvi	a,1		;set the "verify track number" flag to true
	call	rTrkSec		;retrieve track in c, physical sector in b
	lxi	h,altBuf	; (this isn't actually used by readSec)
	call	readSec		;read the sector just written

;  exitDio - exit disk i/o. Restore interrupts if enable interrupt flag is
;     set.

exitDio:
	push	psw
	lda	flags
	ani	FENAINT		;should we re-enable interrupts?
	jz	noInts		;no
	ei
noInts:	pop	psw
	mvi	a,0		;return error code of zero (success)
	rz
	inr	a		;increment total fail count
	ret

; rTrkSec - return track in c, physical sector in b

rTrkSec:
	sta	trkVrfy		;save the passed track verify flag
	lda	diskNum
	mov	c,a
	call	chkMnt		;manually mount another disk?
	mov	a,c
	sta	diskNum		;update disk number
	lhld	trkNum		;L = track number, H = sector number
	mov	c,l
	dcr	h		;conver 1-32 to 0-31 for altair hardware
	mov	b,h
	ret

; chkMnt - check if we need to mount another disk in this drive

chkMnt:
	lda	flags
	ani	FMNTDSK
	rz			;return if single disk mounting disabled
	lxi	h,mntdrv
	mov	a,c
	adi	'A'		;are we mounting a different drive?
	cmp	m
	jz	mounted		;no, drive is already mounted
	mov	m,a
	lxi	h,mount		;prompt to change disks
	call	prmsg
	call	conin		;wait for character input
mounted:
	mvi	c,0
	ret

mount:	db	CR,LF,'Mount disk '
mntdrv	db	'A'
	db	', then <cr>',CR,LF,'$'

;-----------------------------------------------------------------------------
; readSec - read sector. Selects the drive in diskNum, seeks to the track
;    in C and then reads the sector specified in B into the buffer
;    pointed to by dmaAddr.
;----------------------------------------------------------------------------
readSec:
	call	selTrk		;select the drive, seek to the proper track
	rnz			;exit if error
reReadP:
	push	b		;save sector number
reRead:
	call	rtryChk		;decrement and check retry counter
	pop	b
	rnz			;return if no more retries
	push	b
	mov	a,b		;a=sector number
	call	altSkew		;do 17 sector skew like Altair Basic does
	lxi	h,altBuf	;hl points to altair sector buffer
	call	rdPSec		;read physical sector
	lda	flags		;raw I/O or normal to move to (dmaAddr)?
	ani	FRAWIO
	jnz	rdExit		;raw I/O, leave data in altBuf and exit
	lda	trkNum		;process data differently depending on track#
	cpi	6		;tracks 0-5 processed directly below
	jnc	rTrk676		;jmp for tracks 6-76

; validate and move data for sectors in tracks 0 - 5

	lxi	h,altBuf+T0STOP	;should have 0ffh at byte 131 in altBuf
	inr	m
	jnz	reRead		;wasn't 255, re-try the sector read
	lxi	h,altBuf+T0TRK	;track number + 80h at byte 0 in altBuf
	mov	a,m
	ani	07fh		;get track number alone
	pop	b
	cmp	c		;track number in c match track # in data?
	jnz	rdTrkEr		;no, have track number error
	push	b
	lhld	dmaAddr		;hl = destination address for the data
	mov	b,h		;put hl into bc
	mov	c,l
	lxi	h,altBuf+T0DATA	;data starts at byte 3 of altBuf
	call	moveBuf		;move cpm sector to (dmaAddr), return checksum
	lxi	h,altBuf+T0CSUM	;sector checksum is in altBuf + 132
	cmp	m
	jnz	reRead		;checksum fail, re-try the sector read
	pop	b
	xra	a		;return success code
	ret

; rTrk676 - validate and move data for sectors in tracks 6-76

rTrk676	dcx	h		;move back to last by read (offset 136)
	mov	a,m
	ora	a		;verify it is zero
	jnz	reRead		;not zero, re-try the sector read
	dcx	h		;move back to offset 135
	inr	m		;should have 0ffh here
	jnz	reRead		;0ffh not preset, re-try the sector read
	lxi	h,altBuf+T6TRK	;verify 1st byte of altBuf matches track #
	mov	a,m
	ani	07fh		;get track number alone
	pop	b
	cmp	c		;track number in c match track # in data?
	jnz	rdTrkEr		;no, have track number error
	inx	h		;move to offset 1, should have sector num here
	mov	a,m
	cmp	b		;verify it matches requested sector number
	jnz	reReadP		;sector match fail, retry the sector read
	push	b
	lhld	dmaAddr		;hl = destination address for the data
	mov	b,h		;put hl into bc
	mov	c,l
	lxi	h,altBuf+T6DATA	;data starts at byte 7 in altBuf
	call	moveBuf		;move cpm sector to (dmaAddr), return checksum
	lxi	h,altBuf+6	;add bytes 2,3,5 and 6 to checksum
	mov	b,m		;b = byte 6
	dcx	h
	mov	c,m		;c = byte 5
	dcx	h
	mov	d,m		;d = byte 4 (checksum byte)
	dcx	h
	mov	e,m		;e = byte 3
	dcx	h		;m = byte 2
	add	e		;add bytes 3, 6, 5 and 2 (not 4) to checksum
	add	b
	add	c
	add	m
	cmp	d		;compare to checksum
	jnz	reRead		;checksum fail, re-try the sector read
	pop	b
	xra	a		;otherwise, return success code
	ret

; rdTrkEr - Track number error during the read operation

rdTrkEr	xra	a
	call	reTkSec		;retry the track and sector seek
	jmp	reReadP		;retry the sector read (push B entry)

; rdExit - exit read (raw) where data is left in altBuf

rdExit	pop	b
	xra	a
	ret

; rdPSec - read physical sector. Read the physical Altair sector (0-31)
;    specified by e into the buffer specified by HL. Physical sector
;    length is ALTLEN (137) bytes.

rdPSec	call	setSync		;sync to start of sector specified in e
	mvi	c,ALTLEN	;c = length of Altair sector (137 bytes)
rdLoop	in	DRVSTAT		;get drive status byte
	ora	a		;wait for NRDA flag true (zero)
	jm	rdLoop
	in	DRVDATA		;read the byte
	mov	m,a		;store in the read buffer
	inx	h		;increment buffer pointer
	dcr	c		;decrement characters remaining in counter
	jz	rDone		;count is zero - read is done
	dcr	c		;decrement count for 2nd byte about to be read
	nop			;timing
	in	DRVDATA		;get the 2nd byte
	mov	m,a		;store in the read buffer
	inx	h		;increment buffer pointer
	jnz	rdLoop		;loop until all bytes read
rDone	xra	a		;return success of zero = good read
	ret

; secSync - sync to start of sector specified in e. The sector number in e
;    is an Altair physical sector number (0-31).

setSync	call	ldHead		;load the drive head
wtSecTr	in	DRVSEC		;read sector position register
	rar			;wait for sector true flag (zero = true)
	jc	wtSecTr
	ani	01fh		;get sector number alone
	cmp	e		;match sector num we're looking for?
	jnz	wtSecTr
	ret
;------------------------------------------------------------------------------
; wrtSec - Write a sector. Selects the drive in diskNum, seeks to the
;    track in C and then writes the sector specified in B from the
;    buffer pointed to by dmaAddr.
;-----------------------------------------------------------------------------
wrtSec	call	selTrk		;select the drive, seek to the proper track
	rnz			;return if failed
	lda	flags		;see if raw I/O flag is set
	ani	FRAWIO
	jnz	setHCS		;raw I.O, write altBuf, go get head current
	lda	trkNum		;process data differently depending on track #
	cpi	6		;tracks 0-5 processed directly below
	jnc	wTrk676		;jump to process tracks 6-76

;  Sector write for tracks 0-5

	push	b		;save sector number
	mov	a,c		;a = track number
	lxi	b,altBuf	;bc points to altair sector buffer
	stax	b		;put track number at offset 0
	xra	a		;put 0100h (16 bit) at offset 1,2
	inx	b
	stax	b
	inr	a
	inx	b
	stax	b
	inx	b		;bc = cpm data in altBuf at offset 3
	lhld	dmaAddr		;hl = location from which to read data
	call	moveBuf		;move cpm sector from (dmaAddr) to altBuf
	mvi	a,0ffh		;offset 131 is stop byte (0ffh)
	stax	b
	inx	b		;offset 132 is checksum
	mov	a,d		;a = checksum
	stax	b		;store it at offset 132
	pop	b
	jmp	setHCS		;got set head current setting

; wTrk676 - write sector for tracks 6-76

wTrk676	push	b		;save sector number
	lxi	b,altBuf+T6DATA	;bc = cpm data in altBuf at offset 7
	lhld	dmaAddr		;hl = location from which to read data
	call	moveBuf		;move cpm sector from (dmaAddr) to altBuf
	mvi	a,0ffh		;offset 135 is stop byte (0ffh)
	stax	b
	inx	b		;offset 136 is unused (store zero)
	xra	a
	stax	b
	mov	a,d		;a = checksum
	lhld	altBuf+2	;add bytes at offset 2 and 3 to checksum
	add	h
	add	l
	lhld	altBuf+5	;add bytes at offset 5 and 6 to checksum
	add	h
	add	l
	sta	altBuf+T6CSUM	;store final checksum at offset 4
	pop	b
	lxi	h,altBuf	;hl = pointer to altair sector buffer
	mov	m,c		;store track number at offset 0
	inx	h
	mov	m,b		;store sector number at offset 1

; setHCS - set the head current reduction (bit 6) for tracks 43-76.
;   Also set the write bit (bit 7)

setHCS	mov	a,c		;a = track number
	adi	(-43 and 0ffh)	;add -43 (1st track for HCS bit = 1)
	mvi	a,0		;set a=0 without affecting carry
	rar			;080h if track >= 43
	stc
	rar			;0c0 if track >= 43, else 080h
	mov	d,a		;d is the control command for the drive
	mov	a,b		;a = sector number
	call	altSkew		;do sector skew like Altair Disk Basic

; wait for sector true and the right sector number

wtWrSec	in	DRVSEC		;read sector position register
	rar			;wait for sector true (0-true)
	jc	wtWrSec
	ani	01fh		;get sector number alone
	cmp	e		;at the right sector yet?
	jnz	wtWrSec		;no, keep looking
	mov	a,d		;control command formed in d above (setHCS)
	out	DRVCTL		;issue write command
	lxi	h,altBuf	;hl points to altair sector buffer
	lxi	b,0100h+ALTLEN	;c=137 bytes to write, b=1 byte of 0's at end
	mvi	d,ENWDMSK	;Enter New Write Data flag mask
	mvi	a,080h		;1st byte of sector is sync byte
	ora	m		;sync byte must have msb set
	mov	e,a		;e = next byte to write
	inx	h
; wrSec - write physical sector loop

wrSec	in	DRVSTAT		;read drive status register
	ana	d		;write flag (ENWD) asserted (zero)?
	jnz	wrSec		;no, keep waiting
	add	e		;put byte to write into accumulator
	out	DRVDATA		;write the byte
	mov	a,m		;a = next byte to write
	inx	h		;increment source buffer pointer
	mov	e,m		;e = byte to write next time through this loop
	inx	h		;increment source buffer pointer
	dcr	c		;decrement chars remaining (bytes just written)
	jz	wrDone		;zero - sector data written
	dcr	c		;dec chars remaining (byte about to write)
	out	DRVDATA		;write 2nd byte
	jnz	wrSec		;loop if count <> 0
; wrDone - write is done. Now write # of zeros specified in b (just 1)

wrDone	in	DRVSTAT		;wait for another write flag
	ana	d
	jnz	wrDone
	out	DRVDATA		;write zero b times
	dcr	b
	jnz	wrDone
	xra	a		;return success status
	ret

;------------------------------------------------------------------------------
; moveBuf - move sector buffer (128 bytes) from (hl) to (bc). Compute
;   checksum on all bytes and return in a.
;------------------------------------------------------------------------------
moveBuf	mvi	d,0		;d = checksum
	mvi	e,SECLEN	;e = buffer length (128 bytes)
movLoop	mov	a,m		;move from (hl) to (bc)
	stax	b
	add	d		;add byte to checksum
	mov	d,a
	inx	b		;increment both pointers
	inx	h
	dcr	e		;decrement character count
	jnz	movLoop		;loop until count = 0
	ret

;------------------------------------------------------------------------------
; altSkew - Do Altair sector skew like disk basic. For sectors greater than 6,
;    physical = (logical * 17) mod 32. Returns physical sector number in e.
;    This is done on top of the secTran skew table mechanism of CPM. The math
;    works out such that this call to altSkew does almost nothing.
;------------------------------------------------------------------------------
altSkew	mov	e,a		;e = input sector number
	lda	trkNum		;see if track number >= 6
	cpi	6
	rc			;track < 6, exit
	mov	a,e		;multiply by 17
	add	a
	add	a
	add	a
	add	a
	add	e
	ani	01fh		;keep lower 5 bits (0-31)
	mov	e,a
	ret

;------------------------------------------------------------------------------
;  selTrk - select the drive, go to the proper track (specified in diskNum
;     and C)
;------------------------------------------------------------------------------
selTrk	mvi	a,MAXTRY	;set retry count (5 tries)
	sta	rtryCnt
	call	selDrv		;returns with HL=trkTable entry for this drive
	rnz
	mov	a,m		;a = track this drive is presently on
	cpi	UNTRACK		;if unknown track number, seek to track zero
reTkSec	cz	ldSeek0		;if 7f, load head and seek to track 0
	mov	a,m		;a = track number drive is presently on
	mov	m,c		;put distination track num in the track table
	mov	e,a		;e = track number drive is presently on
	call	ldHead		;load the drive head
	mov	a,e		;a = current track, c = desired track
	sub	c		;a = current - desired
	rz			;difference is zero - on proper track alreadyj
	mvi	d,DCSTEPI	;step in to higher tracks if desired > current
	jc	mulStep
	mvi	d,DCSTEPO	;step out to lower tracks if desired < current
	cma			;make it a negative value (1's complement + 1)
	inr	a

; mulStep - issue multiple track steps in or out (controller step command
;    in d). The number of tracks to step is passed as -steps. E.g., 10
;    steps passed as -10.

mulStep	mov	e,a		;e = -tracks left to step
wMoveOk	in	DRVSTAT		;get drive status register
	ani	MOVEMSK		;wait until it's OK to move the head
	jnz	wMoveOk
	mov	a,d		;issue step in or out per command d
	out	DRVCTL
	mov	a,e		;e has -tracks to step, counting up to zero
	inr	a
	jnz	mulStep		;loop until we've stepped to the desired track
	call	rtryChk		;decrement and check retry counter
	jz	stpDone		;retry count OK
	call	selTrk0		;max tries reached - return error
	jmp	retErr

stpDone	lda	trkVrfy		;track number verification flag set?
	ora	a
	jnz	vrfyTrk		;yes, verify track on disk = computed track
	lda	flags		;see if the force track verify flag is set
	ani	FTRKVFY		;if so, verify the track data anyway
	rz

; vrfyTrk - Verify we're on the right track (passed in c) by reading
;    the track number that is stored in the sync byte at the start
;    of every sector. We don't care which sector we read.

vrfyTrk	in	DRVSEC		;wait for sector true (any sector)
	rar
	jc	vrfyTrk
wtVrfy	in	DRVSTAT		;wait for new read data available flag
	ora	a
	jm	wtVrfy		;wait for NRDA flag
	in	DRVDATA		;get sync byte (contains track number)
	ani	07fh		;get the track number alone
	cmp	c
	rz			;we're on the right track number
	xra	a
	jmp	reTkSec		;otherwise, retry track and sector seek

;-----------------------------------------------------------------------------
;  selDrv - select the drive specified in diskNum
;-----------------------------------------------------------------------------
selDrv:
	lda	diskNum		;diskNum is the disk that CPM wants to use
	mov	e,a
	lda	selNum		;disk currently selected on the controller
	cmp	e		;same drive as already selected?
	mov	a,e
	sta	selNum		;set selected drive = diskNum
	jnz	selNew		;not the same drive, select new drive
	in	DRVSTAT		;make sure the drive is still selected
	ani	SELMASK
	jz	rTrkTbl		;drive selected, retrieve the track table ptr
;
;  selNew - select a new drive, deselect the current, then select the new

selNew	mvi	a,DSELECT	;deselect the attached drive
	out	DRVSEL
	lda	selNum		;drive number to select
	out	DRVSEL
	in	DRVSTAT		;loop until drive is selected
	ani	SELMASK
	jnz	selNew

; rTrkTbl - return track table pointer. Also validates the drive number
;    passed in e. Returns with HL pointing to the trkTbl entry for drive in e.

rTrkTbl	lda	numDisk		;drive number OK? (should be 3 here?)
	cmp	e		;e has drive number
	jc	retErr		;error if drive number > 4 (should 3 be used?)
	lxi	h,trkTbl	;index by drive number (e) into track table
	mvi	d,0		;de = 16 bit drive number
	dad	d
	ora	m		;test for msb set in track number
	jm	retErr		;track number invalid is msbit is set
	xra	a		;else, return zero
	ret

;------------------------------------------------------------------------------
;  ldHead - If head already loaded, return. Otherwise, issue the head load
;       command and wait for it to load.
;------------------------------------------------------------------------------
ldHead	in	DRVSTAT		;get drive status
	ani	HEADMSK		;get head loaded bit alone
	rz			;zero = true, head is loaded
	mvi	a,DCLOAD	;issue the load head command
	out	DRVCTL
wtHead	in	DRVSTAT		;get drive status
	ani	HEADMSK		;wait for head loaded to be true
	jnz	wtHead
	ret

;------------------------------------------------------------------------------
;  uldHead - Issued the unload head command
;------------------------------------------------------------------------------
uldHead	mvi	a,DCULOAD	;issue head unload command
	out	DRVCTL
	ret

clrDrv:
	lxi	h,flags	
	mov	a,m
	ani	0f7h
	mov	m,a		;clear force track verification
	mvi	a,07fh	
	sta	selNum		;no drive selected
	lxi	h,07f7fh	;no track selected
	shld	trkTbl
	shld	trkTbl+2
	ret

;-----------------------------------------------------------------------------
; selTrk0 - Select drive in diskNum, load head and seek to track 0
;   ldSeek0 - Load head and seek to track 0
;-----------------------------------------------------------------------------
selTrk0	call	selDrv		;select drive is diskNum
ldSeek0	call	ldHead		;load the drive head
seek0	in	DRVSTAT		;get drive status register
	ani	MOVEMSK		;loop until OK to move the head
	jnz	seek0
	mvi	a,DCSTEPO	;issue step out command
	out	DRVCTL
	in	DRVSTAT	
	ani	TRK0MSK		;loop until we get to track 0
	jnz	seek0
	lda	selNum		;selNum is diskNum once drive is selected
	mov	e,a
	call	rTrkTbl		;HL = track table pointer for this drive
	mvi	m,0		;set track number for this drive to zero
	ret

;------------------------------------------------------------------------------
; rtryChk - retry counter check. Decrement retry counter. Returns zero if
;     more tries left, non-zero if retry counter reaches zero.
;------------------------------------------------------------------------------
rtryChk	lxi	h,rtryCnt
	dcr	m
	jz	retErr
	xra	a
	ret

; retErr - Return error code with 1 in accumulator and non-zero status flag

retErr	mvi	a,1
	ora	a
	ret

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

FCLDCMD equ	001h		;true = CCP process cmd on cold start
FWRMCMD equ	002h		;true = CCP process cmd on warm start
FMNTDSK	equ	004h		;true = single disk mounting
FRAWIO	equ	008h		;r/w directly from altBuf
FENAINT equ	010h		;enable interrupts after disk I/O
FWRTVFY equ	040h		;write verify flag (true = verify)
FTRKVFY equ	080h		;force track number verification


;------------------------------------------------------------------------------
; USER AREA for CP/M2 on Altair.
;
; Copyright (C) 1981 Lifeboat Associates
;
; Default user area
;------------------------------------------------------------------------------

; JUMP TABLE - Jumps MUST remain here in same order.

cinit:	jmp	cinitr		;Cold boot init
winit:	jmp	nulUser		;Warm boot init
const:	jmp	nulUser		;Console status
conin:	jmp	nulUser		;Console input
conout:	jmp	nulUser		;Console output
list:	jmp	nulUser		;Printer output
punch:	jmp	nulUser		;Punch output
reader:	jmp	nulUser		;Reader input
listst:	jmp	nulUser		;Printer status

;
; NULL User Function
nulUser:
	xra	a			;dc1b	af 	. 
	ret			;dc1c	c9 	. 

cinitr:
	lxi	d,CMDLEN		;dc1d	11 07 c1 	. . . 
	lxi	h,config		;dc20	21 50 dc 	. P . 
	mvi	b,CFGLEN		;dc23	06 08 	. . 
	call	autoRun		;dc25	cd 58 dc 	. X . 
	lxi	h,BDOS+0afh	;bdos wait$err
	shld	const		;dc2b	22 06 dc 	" . . 
	shld	conin		;dc2e	22 09 dc 	" . . 
	shld	conout		;dc31	22 0c dc 	" . . 
	mvi	a,jmp		;dc34	3e c3 	> . 
	sta	WBOOTV		;dc36	32 00 00 	2 . . 
	sta	BDOSV		;dc39	32 05 00 	2 . . 
	lxi	h,wboote		;dc3c	21 03 d7 	. . . 
	shld	WBOOTA		;dc3f	22 01 00 	" . . 
	lxi	h,BDOS+BDOSA		;dc42	21 06 c9 	. . . 
	shld	BDOSA		;dc45	22 06 00 	" . . 
	xra	a			;dc48	af 	. 
	sta	CDISK		;dc49	32 04 00 	2 . . 
	mov	c,a			;dc4c	4f 	O 
	jmp	CCP		;dc4d	c3 00 c1 	. . . 

config: db	6, 'CONFIG', 0
CFGLEN	equ	$-config

autoRun:
	mov	a,m			;dc58	7e 	~ 
	stax	d			;dc59	12 	. 
	inx	h			;dc5a	23 	# 
	inx	d			;dc5b	13 	. 
	dcr	b			;dc5c	05 	. 
	jnz	autoRun		;dc5d	c2 58 dc 	. X . 
	ret			;dc60	c9 	. 

;
; User Patch Area
userPatch:
	ds	415		;dc61-ddff

;------------------------------------------------------------------------------
; altBuf - Altair buffer contains the 137 bytes read straight from
;   the Altair drive. This BIOS assumes the disk is laid out in a
;   manner similar to the Altair Disk Basic format. Sectors in tracks 0-5
;   have a different layout than sectors in tracks 6-76.
;------------------------------------------------------------------------------

altBuf:	ds	131		;altair disk buffer

; Tracks 0-5

T0TRK	equ	0		;offset of track number
T0DATA	equ	3		;offset of 128 byte data payload
T0STOP	equ	131		;offset of stop byte (0ffh)
T0CSUM	equ	132		;offset of checksum

; Tracks 6-76

T6TRK	equ	0		;offset of track number
T6SEC	equ	1		;offset of sector number
T6CSUM	equ	4		;offset of checksum
T6DATA	equ	7		;offset of 128 byte data payload
T6STOP	equ	135		;offset of stop byte (0ffh)
T6ZERO	equ	136		;offset of unused, but checked for zero.

lde83h	ds	1
lde84h	ds	2
lde86h	ds	1
	ds	2

;-----------------------------------------------------------------------------
;  Disk scratchpad areas defined in the DPH table
;-----------------------------------------------------------------------------
dirBuf	ds	128		;bdos directory scratchpad
alv0	ds	19		;
csv0	ds	CKS		;change disk scratchpad
alv1	ds	19		;bdos storage allocation scratchpad
csv1	ds	CKS
alv2	ds	19
csv2	ds	CKS
alv3	ds	19
csv3	ds	CKS
;-----------------------------------------------------------------------------
; disk control data
;-----------------------------------------------------------------------------
diskNum ds	1		;current disk number	DF95
trkNum	ds	1		;track num (sector num MUST follow in memory)
secNum	ds	1		;sector number for disk operations
dmaAddr ds	2		;dma address for disk operations
trkVrfy	ds	1		;verify track number if <> 0
selNum	ds	1		;disk number currently selected on controller
rtryCnt	ds	1		;retry counter
cldDone	db	0		;true after cold start has completed
trkTbl	db	UNTRACK, UNTRACK, UNTRACK, UNTRACK

BIOSEND	equ	($ AND 0fc00h)+0400h	;round msb up to next 1K boundary

	end

