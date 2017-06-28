.section .data
# Rappresenta la posizione dell'array a cui mi sono fermato
index:
  .long 0

# Rappresenta il carattere di termine del file, usato per fermare l'esecuzione
eof:
  .ascii "\0"

# TODO: cambia valore, 5 ha senso per debug
# Rappresenta init nel file di input allo stato corrente
init:
  .ascii "5"

# Rappresenta reset nel file di input allo stato corrente
reset:
  .ascii "5"

# Rappresenta ph nel file di input allo stato corrente
ph_value:
  .byte 000

.section .text
	.global ph_asm

ph_asm:
	# salvo ebp corrente e aggiorno con esp attuale
	pushl %ebp
	movl %esp, %ebp

  # eax e ebx contengono l'indirizzo di bufferin/bufferout_asm
  movl 8(%ebp), %eax
  movl 12(%ebp), %ebx

  call getInput
  call setOutput

	# ripristino ebp ed esco
	popl %ebp
	ret

getInput:
  # Sposto l'indice in un registro
  movl index, %ecx

  # Recupero primi 4 byte della linea corrente
  movl (%eax, %ecx, 1), %edx

  # Muovo il primo byte (che corrisponde a init) nella variabile init
  movb %dl, init

  # Effettuo shift di 8 bit per raggiungere il terzo byte,
  # che corrisponde a reset e lo copio nella variabile reset
  sarl $8, %edx
  movb %dh, reset

  ret

setOutput:
  movl index, %ecx
  movl (%ebx, %ecx, 1), %edx

  movb init, %dl
  movb reset, %dh

  # Ricopia in memoria
  movl %edx, (%ebx, %ecx, 1)

  ret

# copy:
#  movl index, %ecx
#
#  movl (%eax, ecx, 1), %edx
#  movb %dl, (%ebx, %ecx, 1)
#
#  # Va avanti
#  addl $1, index
#  cmpb %dl, eof
#  jnz copy
#
#  ret
