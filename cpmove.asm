	TITLE	'CP/M VERSION 2.2 SYSTEM RELOCATOR - 2/80'
;	CPM RELOCATOR PROGRAM, INCLUDED WITH THE MODULE TO PERFORM
;	THE MOVE FROM 900H TO THE DESTINATION ADDRESS
;
;	VERSION 4.2
;	COPYRIGHT (C) 1979 1980
;	LIFEBOAT ASSOCIATES
;
;	COPYRIGHT (C) 1979
;	DIGITAL RESEARCH
;	BOX 579, PACIFIC GROVE CALIFORNIA
;	93950
;
	ORG	100H
	JMP	PASTCOPY
COPY:	DB	'CPMOVE Vers 4.2 (C) Lifeboat Associates, 1979 1980  '
	DB	'(C) Digital Research, 1978'
PASTCOPY:
BIOSWK	EQU	00H	;THREE PAGES FOR BIOS WORKSPACE
STACK	EQU	800H
MODSIZ	EQU	801H	;MODULE SIZE IS STORED HERE
VERSION	EQU	22	;CPM VERSION NUMBER
BOOTSIZ	EQU	2*128	;SIZE OF THE COLD START LOADER
;	(MAY HAVE FIRST 80H BYTES = 00H)
BDOSL	EQU	0800H	;RELATIVE LOCATION OF BDOS
BIOS	EQU	1600H	;RELATIVE LOCATION OF BIOS
;
BOOT	EQU	0000H	;REBOOT LOCATION
BDOS	EQU	0005H
PRNT	EQU	9	;PRINT BUFFER FUNCTION
FCB	EQU	5CH	;DEFAULT FCB
MODULE	EQU	900H	;MODULE ADDRESS
;
CR	EQU	0DH
LF	EQU	0AH
	LXI	SP,STACK
;
;	MAY BE MEMORY SIZE SPECIFIED IN COMMAND
	LXI	D,FCB+1
	LDAX	D
	CPI	'R'
	LHLD	MODSIZ
	JZ	SETASC
	CPI	' '
	JZ	FINDTOP
	CPI	'?'	;WAS * SPECIFIED?
	JZ	FINDTOP
;
;	MUST BE MEMORY SIZE SPECIFICATION
	LXI	H,0
CLOOP:	;CONVERT TO DECIMAL
	LDAX	D
	INX	D
	CPI	' '
	JZ	ECON
	ORA	A
	JZ	ECON
;	MUST BE DECIMAL DIGIT
	SUI	'0'
	CPI	10
	JNC	CERROR
;	DECIMAL DIGIT IS IN A
	DAD	H	;*2
	PUSH	H
	DAD	H	;*4
	DAD	H	;*8
	POP	B	;*2 IN B,C
	DAD	B	;*10 IN H,L
	MOV	C,A
	MVI	B,0
	DAD	B	;*10+X
	JMP	CLOOP
ECON:	;END OF CONVERSION, CHECK FOR PROPER RANGE
	MOV	A,H
	ORA	A
	JNZ	CERROR
	MOV	A,L
	CPI	20
	JC	CERROR
	MVI	L,0
	MOV	H,A
	DAD	H	;SHL 1
	DAD	H	;SHL 2 FOR KILOBYTES
;	H,L HAVE TOP OF MEMORY+1
	JMP	SETASC
;
CERROR:
	LXI	D,CONMSG
	CALL	PRINT
	JMP	BOOT
CONMSG:	DB	CR,LF,'Invalid memory size.$'
;
;
;	FIND END OF MEMORY
FINDTOP:
	LXI	H,0
FINDM:	INR	H	;TO NEXT PAGE
	JZ	MSIZED	;CAN OVERFLOW ON 64K SYSTEMS
	MOV	A,M
	CMA
	MOV	M,A
	CMP	M
	CMA
	MOV	M,A	;BITS INVERTED FOR RAM OPERATIONAL TEST
	JZ	FINDM
;	BITS DIDN'T CHANGE, MUST BE END OF MEMORY
;	ALIGN ON EVEN BOUNDARY
MSIZED:	MOV	A,H
;	ANI	1111$1100B	;EVEN 1K BOUNDARY
	ANI	0FCH		;ZASM
	MOV	H,A
SETASC:	;SET ASCII VALUE OF MEMORY SIZE
	PUSH	H	;SAVE FOR LATER
	MOV	A,H
	RRC
	RRC
;	ANI	11$1111B	;FOR 1K COUNTS
	ANI	03FH		;ZASM
	JNZ	NOT64		;MAY BE 64 K MEM SIZE
	MVI	A,64		;SET TO LITERAL IF SO
NOT64:	MOV	B,A		;READY FOR COUNT DOWN
	LXI	H,03030H	;"00"
	SHLD	AMEM		;BOTH ARE SET TO ASCII 0
ASC0:	LXI	H,AMEM+1	;ADDRESS OF ASCII EQUIVALENT
	INR	M
	MOV	A,M
	CPI	'9'+1
	JC	ASC1
	MVI	M,'0'
	DCX	H
	INR	M
ASC1:	DCR	B		;COUNT DOWN BY KILOBYTES
	JNZ	ASC0
	LXI	D,MEMSG
	CALL	PRINT		;MEMORY SIZE MESSAGE
;
;	TRY TO FIND THE ASCII STRING '' TO SET SIZE
	LXI	H,MODSIZ
	MOV	C,M
	INX	H
	MOV	B,M		;B,C CONTAINS MODULE LENGTH
	PUSH	B		;SAVE LENGTH FOR LATER
	LXI	D,MODULE	;D,E CONTAINS MODULE
	LXI	H,AMSG		;H,E CONTAINS "K VER"
	CALL	SLOOP
	JNC	ESEAR		;NOT FOUND, END OF SEARCH
	;FOUND STRING, SET MEMORY SIZE
	DCX	D		;D,E CONTAINS START ADDRESS OF STRING BEING MATCHED
	LXI	H,AMEM+1	;H,L CONTAINS 'NN' K VALUE
	MOV	A,M		;A IS ONES DIGIT
	STAX	D
	DCX	D		;MOVE TO TENS DIGIT
	DCX	H
	MOV	A,M
	STAX	D
	DCR	D
	LXI	H,CPM		;SEARCH FOR CP/M BANNER
	LXI	B,0200h
	CALL	SLOOP		;D,E=MODULE H,L='CP/M$'  B,C=02,00
	JNC	ESEAR		;NOT FOUND
	CALL	PRINT		;PRINT BANNER
;
;
ESEAR:	;END OF SEARCH
	POP	B		;RECOVER MODULE LENGTH
	POP	H		;H,L CONTAINS END OF MEMORY
	PUSH	B		;SAVE LENGTH FOR RELOCATION BELOW
	MOV	A,B
	ADI	BIOSWK		;ADD BIOS WORK SPACE TO MODULE LENGTH
	MOV	B,A
	MOV	A,L
	SUB	C		;COMPUTE MEMTOP-MODULE SIZE
	MOV	L,A
	MOV	A,H
	SBB	B
	MOV	H,A
;	H,L CONTAINS THE BASE OF THE RELOCATION AREA
	SHLD	RELBAS		;SAVE THE RELOCATION BASE
	LXI	H,MODULE
	POP	B
	DAD	B
;
;	HL ADDRESS BEGINNING OF THE BIT MAP FOR RELOCATION
	PUSH	B		;???
	POP	B		;???
	PUSH	H		;SAVE BIT MAP BASE IN STACK
	LHLD	RELBAS
	XCHG
	LXI	H,BOOTSIZ
	DAD	D		;TO FIND BIAS VALUE
;	REGISTER H CONTAINS BIAS VALUE
;
	LXI	D,MODULE
REL0:	MOV	A,B	;BC=0?
	ORA	C
	JZ	ENDREL
;
;	NOT END OF RELOCATION, MAY BE INTO NEXT BYTE OF BIT MAP
	DCX	B	;COUNT LENGTH DOWN
	MOV	A,E
	ANI	111B	;0 CAUSES FETCH OF NEXT BYTE
	JNZ	REL1
;	FETCH BIT MAP FROM STACKED ADDRESS
	XTHL
	MOV	A,M	;NEXT 8 BITS OF MAP
	INX	H
	XTHL		;BASE ADDRESS GOES BACK TO STACK
	MOV	L,A	;L HOLDS THE MAP AS WE PROCESS 8 LOCATIONS
REL1:	MOV	A,L
	RAL		;CY SET TO 1 IF RELOCATION IS NECESSARY
	MOV	L,A	;BACK TO L FOR NEXT TIME AROUND
	JNC	REL2	;SKIP RELOCATION IF CY=0
;
;	CURRENT ADDRESS REQUIRES RELOCATION
	LDAX	D
	ADD	H	;APPLY BIAS IN H
	STAX	D
;
REL2:	INX	D
	JMP	REL0
;
ENDREL:	;END OF RELOCATION
	POP	D		;GET STACKED ADDRESS
	LHLD	MODSIZ
	MOV	B,H
	MOV	C,L		;B,C CONTAINS MODULE SIZE
	LXI	H,MODULE+80H	;H,L CONTAINS MODULE+80H
	DAD	B		;H,L CONTAINS MODULE+80H+LENGTH
	XCHG			;H,L TO D,E
	LXI	H,MODULE	;H,L CONTAINS MODLUE
	DAD	B		;H,L CONTAINS MODULE+LENGTH
	CALL	MOVEDN		;MOVE H,L TO D,E
	MVI	B,080H
	LXI	H,MODULE+80H
MEMCLR:
	MVI	M,0
	INX	H
	DCR	B
	JNZ	MEMCLR
	JMP	TREND
	MVI	B,128		;CHECK FOR 128 ZEROES
	LXI	H,MODULE
TR0:
	MOV	A,M
	ORA	A
	JNZ	TREND
	INX	H
	DCR	B
	JNZ	TR0
;
	LHLD	MODSIZ
	LXI	B,0FF80H
	DAD	B
	MOV	B,H
	MOV	C,L
	LXI	H,MODULE+80H
	LXI	D,MODULE
	CALL	MOVEUP
;
TREND:	;SET ASCII MEMORY IMAGE SIZE
	LHLD	MODSIZ
	MOV	B,H
	MOV	C,L
	LXI	H,MODULE	;B,C MODULE SIZE, H,L BASE
	DAD	B
	MOV	B,H
	LXI	H,03030H	;'00'
	SHLD	SAVMEM
;	'00' STORED INTO MESSAGE
TRCOMP:
	DCR	B
	JZ	TRC1
	LXI	H,SAVMEM+1	;ADDRESSING LEAST DIGIT
	INR	M
	MOV	A,M
	CPI	'9'+1
	JC	TRCOMP
	MVI	M,'0'
	DCX	H
	INR	M
	JMP	TRCOMP
;	FILL CPMXX.COM FROM SAVMEM
TRC1:	LHLD	AMEM
	SHLD	SAVM0
;	MESSAGE SET, PRINT IT AND REBOOT
	LXI	D,RELOK
	CALL	PRINT
	CALL	PCRLF
	JMP	BOOT
;
	CALL	PCRLF
	LHLD	MODSIZ
	MOV	B,H
	MOV	C,L
	LHLD	RELBAS
	XCHG
;
TRANSFER:
;	GO TO THE RELOCATED MEMORY IMAGE
	LXI	H,MODULE
	CALL	MOVEUP
	LXI	D,BOOTSIZ+BIOS	;MODULE
	LHLD	RELBAS		;RECALL BASE OF RELO AREA
	DAD	D		;INDEX TO BOOT ENTRY POINT
	PCHL			;GO TO RELOCATED PROGRAM
;
;B,C=LENGTH
;D,E=MATCH
;H,L=SEARCH
;CARRY=FOUND
SLOOP:	;SEARCH LOOP
	MOV	A,B
	ORA	C
	STC		; RESET CARRY
	CMC
	RZ
	DCX	B	; COUNT SEARCH LENGTH DOWN
	PUSH	H
	PUSH	B
	PUSH	D
CHLOOP:	;CHARACTER LOOP, MATCH ON CONTENTS OF D,E AND H,L
	LDAX	D
	CPI	'a'
	JC	CHLOOP1
	ANI	05FH		;UPPER CASE
CHLOOP1:
	CMP	M
	JZ	MATCH
	;NOT FOUND AT THIS ADDRESS, LOOK AT NEXT ADDRESS
	POP	D
	INX	D
	POP	B
	POP	H
	JMP	SLOOP
MATCH:
	INX	H		;NEXT MATCH CHARACTER
	INX	D		;NEXT SEARCH CHARACTER
	MOV	A,M
	CPI	'$'		;TERMINATION CHARACTER
	JNZ	CHLOOP
	POP	D
	POP	B
	POP	H
	STC			;SET CARRY = FOUND
	RET
;
; BC=LENGTH
; HL=SOURCE
; DE=DEST
MOVEUP:
	MOV	A,C
	ORA	B
	RZ
	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCX	B
	JMP	MOVEUP
;
; BC=LENGTH
; HL=SOURCE
; DE=DEST
MOVEDN:
	MOV	A,C		;BC=0?
	ORA	B
	RZ
	MOV	A,M		;GET ABSOLUTE LOCATION
	STAX	D		;PLACE IT INTO THE RELOC AREA
	DCX	H
	DCX	D
	DCX	B		;COUNT DOWN TO ZERO
	JMP	MOVEDN

;========================
; START USELESS BLOCK???
;========================
	XRA	A
	LXI	D,0368H
	STAX	D
	DCX	D
	MVI	C,LF
	CALL	BDOS
	LXI	H,0368H
	MOV	C,M
	INX	H
	MVI	B,0
	DAD	B
	MVI	M,CR
	INR	C
l0353h:
	MOV	A,M
	CALL	TOUPR
	MOV	M,A
	DCX	H
	DCR	C
	JNZ	l0353h
	RET
TOUPR:
	CPI	'a'-1
	RC
	CPI	'z'+1
	RNC
	ANI	05FH
	RET

	DW	0010h
l0369h:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	DCR	c

;======================
; END USELESS BLOCK???
;======================

PCRLF:	LXI	D,CRLF
	JMP	PRINT

CRLF:	DB	CR,LF,'$'

PRINT:
	MVI	C,PRNT
	JMP	BDOS
;
;	DATA	AREAS
MEMSG:	DB	CR,LF,'Constructing '
AMEM:	DB	'00'
	DB	'K CP/M',CR,LF,CR,LF,'$'
RELOK:	DB	CR,LF,CR,LF,'New CP/M in memory at 900H (sysgen image)'
	DB	CR,LF,'is ready for "SYSGEN" or "SAVE '
SAVMEM:	DB	'00 CPM'
SAVM0:	DB	'00.COM"$'
CPM:	DB	'CP/M$'
AMSG:	DB	'K VER$'
RELBAS:	DS	2		;RELOCATION BASE
