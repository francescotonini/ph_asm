.section .data
st:
  .ascii "-"
nck:
  .ascii "--"
vlv:
  .ascii "--"

.section .text
	.global ph_asm

ph_asm:
	# salvo ebp corrente e aggiorno con esp attuale
	pushl %ebp
	movl %esp, %ebp

  # preparo registri
  # eax e ebx contengono l'indirizzo di bufferin/bufferout_asm
  movl 8(%ebp), %eax
  movl 12(%ebp), %ebx
  mov $0, %dx

  call start

	# ripristino ebp ed esco
	popl %ebp
	ret

start:
  # Devo capire se sono a fine array (EOF)
  # in tal caso esco, altrimenti chiamo
  # funzione per controllo init

  movb (%eax), %cl
  cmpb $0, %cl
  jne checkInit
  ret

checkInit:
  cmpb $48, (%eax)

  # Controllo reset se init != 0
  jne checkReset

  # Preparo output "vuoto"
  movb $45, st
  leal vlv, %esi
  movb $45, 1(%esi)
  movb $45, (%esi)
  leal nck, %esi
  movb $45, 1(%esi)
  movb $45, (%esi)
  jmp print
  ret

checkReset:
  cmpb $49, 2(%eax)

  # Controllo ph se reset != 1
  jne checkPH

  # Preparo output "vuoto"
  movb $45, st
  leal vlv, %esi
  movb $45, 1(%esi)
  movb $45, (%esi)
  leal nck, %esi
  movb $45, 1(%esi)
  movb $45, (%esi)
  jmp print
  ret

checkPH:
  # Recupero terza cifra phs
  cmpb $49, 4(%eax)

  # Se la terza cifra è > 1, la soluzione è basica
  jge checkBasic

  # Recupero seconda cifra ph
  cmpb $54, 5(%eax)

  # Se la seconda cifra è < 6, la soluzione è acida
  jl checkAcid

  cmpb $56, 5(%eax)

  # Se la seconda cifra è <= 8 (e >= 6), la soluzione è neutra
  jle checkNeutral

  # Altrimenti è basica
  jg checkBasic
  ret

checkBasic:
  cmpb $66, st
  movb $66, st

  # Se lo stato è variato, pulisco nck/vlv e ricomincio
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

  cmp $5, %dx
  jl print

  leal vlv, %esi
  movb $83, 1(%esi)
  movb $65, (%esi)

  jmp print
  ret

checkAcid:
  cmpb $65, st
  movb $65, st

  # Se lo stato è variato, pulisco nck/vlv e ricomincio
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

  cmp $5, %dx
  jl print

  leal vlv, %esi
  movb $83, 1(%esi)
  movb $66, (%esi)

  jmp print
  ret

checkNeutral:
  cmpb $78, st
  movb $78, st

  # Se lo stato è variato, pulisco nck/vlv e ricomincio
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

  cmp $5, %dx
  jl print

  leal vlv, %esi
  movb $83, 1(%esi)
  movb $65, (%esi)

  jmp print
  ret

clear:
  mov $0, %dx

  leal vlv, %esi
  movb $45, 1(%esi)
  movb $45, (%esi)
  leal nck, %esi
  movb $48, 1(%esi)
  movb $48, (%esi)
  jmp print
  ret

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

  jmp start
  ret
