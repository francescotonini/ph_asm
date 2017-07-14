.section .text
	.global controllore

# "main"
controllore:
	# salvo ebp corrente
	pushl %ebp

  # ebp prende il valore di esp
	movl %esp, %ebp

  # salvo stato dei registri, saranno ripristinati a fine esecuzione
  pushl %eax
  pushl %ebx
  pushl %ecx
  pushl %edi
  pushl %esi

  # preparo registri
  # esi e edi contengono l'indirizzo di bufferin/bufferout_asm
  # cl sarà usato come contatore
  # bl conterrà st
  # bh conterrà la seconda cifra di vlv
  # eax sarà usato in diversi contesti
  movl 8(%ebp), %esi
  movl 12(%ebp), %edi
  xorl %ecx, %ecx
  xorl %eax, %eax
  xorl %ebx, %ebx

  # verifico se il file è vuoto
  cmpb $0, (%esi)

  # se il file è vuoto termino
  # altrimenti salto a funzione di "elaborazione"
  je end

# funzione di controllo init, reset e ph
start:
  # riga esempio
  # 1,0,120
  # init,reset,ph

  # verifico se i primi 4 byte della riga sono "1,0,", ovvero
  # macchina accesa e operativa. In tal caso procedo, altrimenti
  # stampo output "reset"
  cmpl $741354545, (%esi)
  jne printReset

  # recupero terza cifra ph
  # 49 è 1 in ascii
  # Se la terza cifra è = 1, la soluzione è basica
  cmpb $49, 4(%esi)
  je checkBasic

  # recupero seconda cifra ph
  # 54 è 6 in ascii
  # Se la seconda cifra è < 6, la soluzione è acida
  cmpb $54, 5(%esi)
  jl checkAcid

  # recuoero seconda cifra ph
  # 56 è 8 in ascii
  # Se la seconda cifra è < 8 (e > 6), la soluzione è neutra
  cmpb $56, 5(%esi)
  jl checkNeutral

  # sommo seconda e prima cifra del ph, per stabilire se è uguale o maggiore ad 80
  # Se la somma tra la seconda cifra e la terza è <= 80, la soluzione è neutra
  # 104 è la somma di 8 + 0 (codificato in ascii)
  # Se non ho ancora effettuato salti, allora la soluzione
  # è basica
  movb 5(%esi), %al
  addb 6(%esi), %al
  cmpb $104, %al
  jle checkNeutral

# elabora ph basico
checkBasic:
  # Comparo lo stato precedente con il presente
  cmpb $66, %bl

  # Aggiorno stato
  movb $66, %bl

  # Se lo stato è variato, pulisco nck/vlv e ricomincio
  # Altrimenti procedo col calcolo di nck e delle valvole
  jne printClear

  # Incremento nck
  incb %cl

	# stampa st
	movb %bl, (%edi)

	# stampa divisore
	movb $44, 1(%edi)

	# Stampo nck in ascii
	movzb %cl, %ax
	movb $10, %dl
	divb %dl
	addb $48, %ah
	movb %ah, 3(%edi)
	movzb %al, %ax
	divb %dl
	addb $48, %ah
	movb %ah, 2(%edi)

	# Stampa divisore
	movb $44, 4(%edi)

	# Verifico se ho superato i 5 cicli di clock
	# (vedi specifiche)
	# se non li ho superati stampo valvole chiuse
  cmpb $5, %cl
	jl printValves

	# stampa valvole "AS"
	movb $65, 5(%edi)
	movb $83, 6(%edi)

	# fine riga
	movb $10, 7(%edi)

	# salto alla funzione di termine,
	# che controllerà se ci sono altre righe
	# da analizzare
	jmp end

# elabora ph acido
checkAcid:
  # Comparo lo stato precedente con il presente
  cmpb $65, %bl

  # Aggiorno stato
  movb $65, %bl

  # Se lo stato è variato, pulisco nck/vlv e ricomincio
  # Altrimenti procedo col calcolo di nck e delle valvole
  jne printClear

	# Incremento nck
  incb %cl

	# stampa st
	movb %bl, (%edi)

	# stampa divisore
	movb $44, 1(%edi)

	# Stampo nck in ascii
	movzb %cl, %ax
	movb $10, %dl
	divb %dl
	addb $48, %ah
	movb %ah, 3(%edi)
	movzb %al, %ax
	divb %dl
	addb $48, %ah
	movb %ah, 2(%edi)

	# Stampa divisore
	movb $44, 4(%edi)

	# Verifico se ho superato i 5 cicli di clock
	# (vedi specifiche)
	# se non li ho superati stampo valvole chiuse
  cmpb $5, %cl
	jl printValves

	# stampa valvole "BS"
	movb $66, 5(%edi)
	movb $83, 6(%edi)

	# fine riga
	movb $10, 7(%edi)

	# salto alla funzione di termine,
	# che controllerà se ci sono altre righe
	# da analizzare
	jmp end

# elabora ph neutro
checkNeutral:
  # Comparo lo stato precedente con il presente
  cmpb $78, %bl

  # Aggiorno stato
  movb $78, %bl

  # Se lo stato è variato, pulisco nck/vlv e ricomincio
  # Altrimenti procedo col calcolo di nck
  jne printClear

  # Incremento nck
  inc %cl

	# stampa st
	movb %bl, (%edi)

	# stampa divisore
	movb $44, 1(%edi)

	# Stampo nck in ascii
	movzb %cl, %ax
	movb $10, %dl
	divb %dl
	addb $48, %ah
	movb %ah, 3(%edi)
	movzb %al, %ax
	divb %dl
	addb $48, %ah
	movb %ah, 2(%edi)

	# Stampa divisore
	movb $44, 4(%edi)

	# stampa valvole "azzerate"
	movb $45, 5(%edi)
	movb $45, 6(%edi)

	# fine riga
	movb $10, 7(%edi)

	# salto alla funzione di termine,
	# che controllerà se ci sono altre righe
	# da analizzare
	jmp end

# stamp output "vuoto"
printReset:
  # azzero nck, vlv e st
  xorb %cl, %cl
  xor %bx, %bx

  # stampa -,--
  movl $757935149, (%edi)

  # stampa ,--\n
  movl $170732844, 4(%edi)

  # salto alla funzione di termine,
  # che controllerà se ci sono altre righe
  # da analizzare
  jmp end

# pulisco nck e vlv a seguito di una
# variazione di ph
printClear:
  # azzero nck e vlv
  xorb %cl, %cl
  xorb %bh, %bh

  # stampa st
  movb %bl, (%edi)

  # stampa ,--,
  movl $741355564, 1(%edi)

  # stampa --
  movw $11565, 5(%edi)

  # fine riga
  movb $10, 7(%edi)

  # salto alla funzione di termine,
  # che controllerà se ci sono altre righe
  # da analizzare
  jmp end

printValves:
	movb $45, 5(%edi)
	movb $45, 6(%edi)

	# fine riga
	movb $10, 7(%edi)

	jmp end

end:
  addl $8, %esi
  addl $8, %edi

  # verifico se sono a fine file
  cmpb $0, (%esi)

  # se non sono a fine file ricomincio
  jne start

  # altrimenti ripristino registri
  popl %esi
  popl %edi
  popl %ecx
  popl %ebx
  popl %eax
  popl %ebp
  ret
