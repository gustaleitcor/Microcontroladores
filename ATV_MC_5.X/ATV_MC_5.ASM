;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÃ‡Ã•ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2024                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David JosÃ© de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÃ‡Ã•ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃƒO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÃ‡ÃƒO DE MEMÃ“RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÃ‡ÃƒO DE COMANDOS DE USUÃRIO PARA ALTERAÃ‡ÃƒO DA PÃGINA DE MEMÃ“RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÃ“RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÃ“RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÃVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÃ‡ÃƒO DOS NOMES E ENDEREÃ‡OS DE TODAS AS VARIÃVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÃ‡O INICIAL DA MEMÃ“RIA DE
					;USUÃRIO
		W_TEMP		;REGISTRADORES TEMPORÃRIOS PARA USO
		STATUS_TEMP	;JUNTO Ã€S INTERRUPÃ‡Ã•ES
		COUNTER

		;COLOQUE AQUI SUAS NOVAS VARIÃVEIS
		;NÃƒO ESQUEÃ‡A COMENTÃRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÃ‡ÃƒO DE VARIÃVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÃ‡ÃƒO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÃ‡ÃƒO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÃ‡ÃƒO DE TODOS OS PINOS QUE SERÃƒO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÃ‰M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÃDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÃ‡ÃƒO DE TODOS OS PINOS QUE SERÃƒO UTILIZADOS COMO SAÃDA
; RECOMENDAMOS TAMBÃ‰M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÃ‡O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÃCIO DA INTERRUPÃ‡ÃƒO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÃ‡O DE DESVIO DAS INTERRUPÃ‡Ã•ES. A PRIMEIRA TAREFA Ã‰ SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÃ‡ÃƒO FUTURA

	ORG	0x04		; 0x04 é o endereço padrão para o vetor de interrupção em microcontroladores PIC.
	BCF	PIR1, ADIF	; Limpa o flag de interrupção do conversor A/D (ADIF no registrador PIR1). Isso informa ao hardware que a interrupção foi tratada.
	BSF	ADCON0, 1	; Reinicia o conversor A/D, setando o bit 1 do registrador ADCON0 (inicia uma nova conversão).
	NOP			; No Operation (não faz nada, mas consome um ciclo de clock). Usado para garantir um pequeno atraso estratégico.
	RETFIE			; Retorna da interrupção e reabilita as interrupções globais (GIE é automaticamente setado).
	


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÃ‡ÃƒO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃƒO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÃ‡Ã•ES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÃDA DA INTERRUPÃ‡ÃƒO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÃ‡ÃƒO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	

	
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÃ‡ÃƒO DE FUNCIONAMENTO
; E UM NOME COERENTE Ã€S SUAS FUNÃ‡Ã•ES.

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00010000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00011000'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'11000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'01000000'
	MOVWF	PIE1		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00001111'
	MOVWF	ADCON0		;DEFINE O MODO DE OPERAÇÃO DO CONVERSOR A/D
	MOVLW	B'01000000'
	MOVWF	PIR1		;DEFINE OPÇÕES DE INTERRUPÇÕES
	


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÃ‡ÃƒO DAS VARIÃVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
MAIN	
	MOVFW	ADRESH		; Move o valor do registrador ADRESH (parte alta do resultado da conversão A/D) para o registrador W (working register).
	
	SUBLW	.250		; Subtrai o valor 250 do valor em W (W = 250 - W). O resultado é armazenado em W.
	BTFSC	STATUS, Z	; Verifica o bit de zero (Z) no registrador STATUS. Se Z = 1 (ou seja, se W = 250), pula a próxima instrução.
	GOTO	JUMP_LOOP_1	; Se Z = 1, vai para o rótulo JUMP_LOOP_1 (tratamento especial para o valor 250).
	BTFSC	STATUS, C	; Verifica o bit de carry (C) no registrador STATUS. Se C = 1 (ou seja, se W >= 250), pula a próxima instrução.
	BCF GPIO, GP0		; Se C = 1, limpa o bit GP0 do registrador GPIO (define o pino GP0 como 0).
	MOVWF	COUNTER		; Move o valor de W para o registrador COUNTER.
LOOP_1
	NOP			; No Operation (não faz nada, apenas espera um ciclo de clock).
	NOP			; Outro NOP.
	NOP			; Mais um NOP.
	DECFSZ	COUNTER		; Decrementa o valor de COUNTER. Se COUNTER = 0, pula a próxima instrução.
	GOTO	LOOP_1		; Se COUNTER não for zero, volta para LOOP_1.

JUMP_LOOP_1
	MOVFW	ADRESH		; Move o valor de ADRESH para W novamente.
	MOVWF	COUNTER		; Move o valor de W para COUNTER.
	
	SUBLW	.0		; Subtrai 0 de W (W = 0 - W)
	BTFSS	STATUS, Z	; Verifica o bit de zero (Z) no registrador STATUS. Se Z = 0 (ou seja, se W != 0), pula a próxima instrução.
	BSF	GPIO, GP0	; Se Z = 0, define o bit GP0 do registrador GPIO como 1 (liga o pino GP0).
LOOP_2
	NOP			; No Operation.
	NOP			; Outro NOP.
	NOP			; Mais um NOP.
	DECFSZ	COUNTER		; Decrementa o valor de COUNTER. Se COUNTER = 0, pula a próxima instrução.
	GOTO	LOOP_2		; Se COUNTER não for zero, volta para LOOP_2.
	GOTO	MAIN		; Volta para o início do programa (MAIN).
	
	


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    END