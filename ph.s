.section .data
# Rappresenta il ph nello stato precedente
# all'esecuzione attuale
st:
  .ascii "-"
# Rappresenta il contatore espresso
# in ascii (il contatore reale è in %dx)
nck:
  .ascii "--"
# Rappresenta le valvole nello stato precedente
# all'esecuzione attuale
vlv:
  .ascii "--"

.section .text
	.global controllore

# funzione "main"
controllore:

	# salvo ebp corrente
  # ebp prende il valore di esp
	pushl %ebp
	movl %esp, %ebp

  # salvo stato dei registri che utilizzerò
  pushl %eax
  pushl %ebx
  pushl %ecx
  pushl %edx

  # preparo registri
  # eax e ebx contengono l'indirizzo di bufferin/bufferout_asm
  movl 8(%ebp), %eax
  movl 12(%ebp), %ebx

  # richiamo funzione che eseguirà i primi controlli
  # su bufferin
  call start

	# ripristino registri ed esco
  popl %edx
  popl %ecx
  popl %ebx
  popl %eax
	popl %ebp
	ret

# verifica se abbiamo raggiunto la fine
# dell'array. In caso negativo richiama
# una funzione per il controllo del campo init
start:
  movb (%eax), %cl
  cmpb $0, %cl
  jne checkInit
  ret

# verifica il valore di init (primo elemento riga)
# se è diverso da 0 (quindi la macchina è accesa)
# richiamo funzione per il controllo di reset.
# se init è uguale a 0, reimposto gli output e richiamo
# la funzione di stampa
checkInit:
  # comparo $48 (ovvero 0 in ascii) con il primo byte
  # di eax
  cmpb $48, (%eax)

  # passo al controllo di reset se init è diverso da 0
  jne checkReset

  # Reimposto l'output
  # 45 corrisponde a - in ascii
  movb $45, st
  leal vlv, %esi
  movb $45, 1(%esi)
  movb $45, (%esi)
  leal nck, %esi
  movb $45, 1(%esi)
  movb $45, (%esi)
  jmp print
  ret

# verifica il valore di reset (terzo elemento riga)
# se è diverso da 1 (quindi la macchina è in esecuzione)
# richiamo funzione per il controllo del ph.
# se reset è uguale a 1, reimposto gli output
# e richiamo la funzione di stampa
checkReset:
  # 49 corrisponde a 1 in ascii
  cmpb $49, 2(%eax)

  # passo al controllo del ph se reset è diverso da 1
  jne checkPH

  # Reimposto l'output
  # 45 corrisponde a - in ascii
  movb $45, st
  leal vlv, %esi
  movb $45, 1(%esi)
  movb $45, (%esi)
  leal nck, %esi
  movb $45, 1(%esi)
  movb $45, (%esi)
  jmp print
  ret

# verifico il valore di ph.
checkPH:
  # Recupero terza cifra ph
  # 49 è 1 in ascii
  cmpb $49, 4(%eax)

  # Se la terza cifra è >= 1, la soluzione è basica
  jge checkBasic

  # Recupero seconda cifra ph
  # 54 è 6 in ascii
  cmpb $54, 5(%eax)

  # Se la seconda cifra è < 6, la soluzione è acida
  jl checkAcid

  # 56 è 8 in ascii
  cmpb $56, 5(%eax)

  # Se la seconda cifra è <= 8 (e >= 6), la soluzione è neutra
  jle checkNeutral

  # Se non ho ancora effettuato salti, allora la soluzione
  # è basica
  jg checkBasic
  ret

# elabora ph basico
checkBasic:
  # Comparo lo stato precedente con il presente
  cmpb $66, st

  # Aggiorno stato
  movb $66, st

  # Se lo stato è variato, pulisco nck/vlv e ricomincio
  # Altrimenti procedo col calcolo di nck e delle valvole
  jne clear

  # Incremento nck
  inc %dx
  cmp $5, %dx

  # Converto nck in ascii
  pushl %eax
  pushl %edx
  leal nck, %esi
  mov %dx, %ax
  movb $10, %dl
  divb %dl
  addb $48, %ah
  movb %ah, 1(%esi)
  movzb %al, %ax
  divb %dl
  addb $48, %ah
  movb %ah, (%esi)
  popl %edx
  popl %eax

  # Verifico se ho superato i 5 cicli di clock
  # (vedi specifiche)
  cmp $5, %dx

  # Se non li ho superati,
  # stampo e non tocco le valvole
  jl print

  # Se li ho superati modifico le valvole
  # e stamp
  leal vlv, %esi
  movb $83, 1(%esi)
  movb $65, (%esi)

  jmp print
  ret

# elabora ph acido
checkAcid:
  # Comparo lo stato precedente con il presente
  cmpb $65, st

  # Aggiorno stato
  movb $65, st

  # Se lo stato è variato, pulisco nck/vlv e ricomincio
  # Altrimenti procedo col calcolo di nck e delle valvole
  jne clear

  # Incremento nck
  inc %dx

  # Converto nck in ascii
  pushl %eax
  pushl %edx
  leal nck, %esi
  mov %dx, %ax
  movb $10, %dl
  divb %dl
  addb $48, %ah
  movb %ah, 1(%esi)
  movzb %al, %ax
  divb %dl
  addb $48, %ah
  movb %ah, (%esi)
  popl %edx
  popl %eax

  # Verifico se ho superato i 5 cicli di clock
  # (vedi specifiche)
  cmp $5, %dx

  # Se non li ho superati,
  # stampo e non tocco le valvole
  jl print

  # Se li ho superati modifico le valvole
  # e stampo
  leal vlv, %esi
  movb $83, 1(%esi)
  movb $66, (%esi)

  jmp print
  ret

# elabora ph neutro
checkNeutral:
  # Comparo lo stato precedente con il presente
  cmpb $78, st

  # Aggiorno stato
  movb $78, st

  # Se lo stato è variato, pulisco nck/vlv e ricomincio
  # Altrimenti procedo col calcolo di nck
  jne clear

  # Incremento nck
  inc %dx

  # Converto nck in ascii
  pushl %eax
  pushl %edx
  leal nck, %esi
  mov %dx, %ax
  movb $10, %dl
  divb %dl
  addb $48, %ah
  movb %ah, 1(%esi)
  movzb %al, %ax
  divb %dl
  addb $48, %ah
  movb %ah, (%esi)
  popl %edx
  popl %eax

  # Reimposto le valvole
  leal vlv, %esi
  movb $45, 1(%esi)
  movb $45, (%esi)

  # Stampo
  jmp print
  ret

# pulisco nck e vlv a seguito di una
# variazione di ph
clear:
  # azzero nck
  mov $0, %dx

  # reimposto vlv e nck
  leal vlv, %esi
  movb $45, 1(%esi)
  movb $45, (%esi)
  leal nck, %esi
  movb $48, 1(%esi)
  movb $48, (%esi)

  # stampo
  jmp print
  ret

# stampo su bufferout e incremento gli indirizzi
# (ovvero passo alla riga successiva)
print:
  # Salvo eax, sarà ripristinato in seguito
  pushl %eax

  # Stampa st
  movb st, %al
  movb %al, (%ebx)

  # Stampa divisore
  movb $44, 1(%ebx)

  # Stampa nck
  mov nck, %ax
  mov %ax, 2(%ebx)

  # Stampa divisore
  movb $44, 4(%ebx)

  # Stampa vlv
  mov vlv, %ax
  mov %ax, 5(%ebx)
  movb $10, 7(%ebx)

  # Ripritino eax
  popl %eax

  # Incremento indirizzi
  addl $8, %eax
  addl $8, %ebx

  # Salto alla funzione di avvio,
  # che controllerà se ci sono altre righe
  # da analizzare
  jmp start
  ret
