;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA√á√ïES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2024                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos√© de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI√á√ïES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR√ÉO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA√á√ÉO DE MEM√ìRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI√á√ÉO DE COMANDOS DE USU√ÅRIO PARA ALTERA√á√ÉO DA P√ÅGINA DE MEM√ìRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM√ìRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM√ìRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI√ÅVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI√á√ÉO DOS NOMES E ENDERE√áOS DE TODAS AS VARI√ÅVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE√áO INICIAL DA MEM√ìRIA DE
					;USU√ÅRIO
		W_TEMP		;REGISTRADORES TEMPOR√ÅRIOS PARA USO
		STATUS_TEMP	;JUNTO √ÄS INTERRUP√á√ïES
		COUNTER
		VALUE

		;COLOQUE AQUI SUAS NOVAS VARI√ÅVEIS
		;N√ÉO ESQUE√áA COMENT√ÅRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINI√á√ÉO DE VARI√ÅVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI√á√ÉO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI√á√ÉO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI√á√ÉO DE TODOS OS PINOS QUE SER√ÉO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB√âM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA√çDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI√á√ÉO DE TODOS OS PINOS QUE SER√ÉO UTILIZADOS COMO SA√çDA
; RECOMENDAMOS TAMB√âM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE√áO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN√çCIO DA INTERRUP√á√ÉO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE√áO DE DESVIO DAS INTERRUP√á√ïES. A PRIMEIRA TAREFA √â SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA√á√ÉO FUTURA

	ORG	0x04			;ENDERE√áO INICIAL DA INTERRUP√á√ÉO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP√á√ÉO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER√ÉO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP√á√ïES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA√çDA DA INTERRUP√á√ÉO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP√á√ÉO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI√á√ÉO DE FUNCIONAMENTO
; E UM NOME COERENTE √ÄS SUAS FUN√á√ïES.

WAIT_50MS
	MOVLW	.60		; Carrega o valor 60 no W (para temporizaÁ„o de ~50ms)
	MOVWF	TMR0		; Armazena no Timer0
	BCF	INTCON, T0IF	; Limpa flag de overflow do Timer0
LOOP_50MS
	BTFSS	INTCON, T0IF	; Testa se o Timer0 estourou
	GOTO	LOOP_50MS	; Se n„o, continua esperando
	RETURN
    
WAIT_99US
	MOVLW	.31		; Carrega o valor 31 no W (para temporizaÁ„o de ~99us)
	MOVWF	COUNTER		; Armazena no contador
LOOP_99US
	DECFSZ	COUNTER		; Decrementa o contador, pula se zero
	GOTO	LOOP_99US	; Continua loop se n„o zerou
	RETURN
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000101' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA√çDAS
	MOVLW	B'00010100'
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;DEFINE OP√á√ïES DE OPERA√á√ÉO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP√á√ïES DE INTERRUP√á√ïES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA√á√ÉO DO COMPARADOR ANAL√ìGICO
	MOVLW	B'00001001'
	MOVWF	ADCON0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA√á√ÉO DAS VARI√ÅVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
; __________________________________________________________________
; GP0: Receber os bits da comunicaÁ„o serial (UART)
; GP1: Transmitir os bits da comunicaÁ„o serial (UART)
; GP5: Acionar o LED conforme especificado
; GP2: Entrada para convers„o A/D
; __________________________________________________________________
	
MAIN
	BSF	GPIO, GP1   ; Inicia estado inicial
	GOTO	START
STOP
	CALL	WAIT_99US
	NOP
	NOP
	NOP
	NOP
	NOP
	BSF	GPIO, GP1   ; Retorna ao estado inicial
START	
	BTFSC	GPIO, GP0   ; Testa se GP0 (entrada serial) est· baixo
	GOTO	START	    ; Se n„o, continua esperando
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	BCF	STATUS, C
	BTFSC	GPIO, GP0   ; Recebe 1 bit da comunicaÁ„o serial
	BSF	STATUS, C
	BTFSS	GPIO, GP0
	BCF	STATUS, C
	RRF	VALUE	; Rotaciona bit recebido para VALUE
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	BCF	STATUS, C
	BTFSC	GPIO, GP0
	BSF	STATUS, C
	BTFSS	GPIO, GP0
	BCF	STATUS, C
	RRF	VALUE	; Rotaciona bit recebido para VALUE
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	BCF	STATUS, C
	BTFSC	GPIO, GP0   ; Recebe 1 bit da comunicaÁ„o serial
	BSF	STATUS, C
	BTFSS	GPIO, GP0
	BCF	STATUS, C
	RRF	VALUE	; Rotaciona bit recebido para VALUE
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	BCF	STATUS, C
	BTFSC	GPIO, GP0   ; Recebe 1 bit da comunicaÁ„o serial
	BSF	STATUS, C
	BTFSS	GPIO, GP0
	BCF	STATUS, C
	RRF	VALUE	; Rotaciona bit recebido para VALUE
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	BCF	STATUS, C
	BTFSC	GPIO, GP0   ; Recebe 1 bit da comunicaÁ„o serial
	BSF	STATUS, C
	BTFSS	GPIO, GP0
	BCF	STATUS, C
	RRF	VALUE	; Rotaciona bit recebido para VALUE
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	BCF	STATUS, C
	BTFSC	GPIO, GP0   ; Recebe 1 bit da comunicaÁ„o serial
	BSF	STATUS, C
	BTFSS	GPIO, GP0
	BCF	STATUS, C
	RRF	VALUE	; Rotaciona bit recebido para VALUE
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	BCF	STATUS, C
	BTFSC	GPIO, GP0   ; Recebe 1 bit da comunicaÁ„o serial
	BSF	STATUS, C
	BTFSS	GPIO, GP0
	BCF	STATUS, C
	RRF	VALUE	; Rotaciona bit recebido para VALUE
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	BCF	STATUS, C
	BTFSC	GPIO, GP0   ; Recebe 1 bit da comunicaÁ„o serial
	BSF	STATUS, C
	BTFSS	GPIO, GP0
	BCF	STATUS, C
	RRF	VALUE	; Rotaciona bit recebido para VALUE
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	NOP	; Parity bit
	NOP
	MOVLW	.39
	XORWF	VALUE, 0
	BTFSS	STATUS, Z
	GOTO	STOP	; Se VALUE != 39, reinicia
	
	BSF	GPIO, GP5   ; Liga LED em GP5 (conforme especificaÁ„o)
	CALL	WAIT_50MS   ; MantÈm LED aceso por 50ms
	BCF	GPIO, GP5   ; Desliga LED
	
	BCF	PIR1, ADIF
	BSF	ADCON0, GO  ; Inicia convers„o A/D
	
CONV_LOOP
	BTFSS	PIR1, ADIF  ; Espera convers„o A/D terminar
	GOTO	CONV_LOOP
	
	MOVFW	ADRESH
	MOVWF	VALUE	    ; Move ADRESH para VALUE
	
	BCF	GPIO, GP1
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	RLF	VALUE	; Transmite 1 bit da comunicaÁ„o serial
	BTFSC	STATUS, C
	BSF	GPIO, GP1
	BTFSS	STATUS, C
	BCF	GPIO, GP1
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	RLF	VALUE	; Transmite 1 bit da comunicaÁ„o serial
	BTFSC	STATUS, C
	BSF	GPIO, GP1
	BTFSS	STATUS, C
	BCF	GPIO, GP1
	NOP
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	RLF	VALUE	; Transmite 1 bit da comunicaÁ„o serial
	BTFSC	STATUS, C
	BSF	GPIO, GP1
	BTFSS	STATUS, C
	BCF	GPIO, GP1
	NOP
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	RLF	VALUE	; Transmite 1 bit da comunicaÁ„o serial
	BTFSC	STATUS, C
	BSF	GPIO, GP1
	BTFSS	STATUS, C
	BCF	GPIO, GP1
	NOP
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	RLF	VALUE	; Transmite 1 bit da comunicaÁ„o serial
	BTFSC	STATUS, C
	BSF	GPIO, GP1
	BTFSS	STATUS, C
	BCF	GPIO, GP1
	NOP
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	RLF	VALUE	; Transmite 1 bit da comunicaÁ„o serial
	BTFSC	STATUS, C   
	BSF	GPIO, GP1
	BTFSS	STATUS, C
	BCF	GPIO, GP1
	NOP
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	RLF	VALUE	; Transmite 1 bit da comunicaÁ„o serial
	BTFSC	STATUS, C
	BSF	GPIO, GP1
	BTFSS	STATUS, C
	BCF	GPIO, GP1
	NOP
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	RLF	VALUE	; Transmite 1 bit da comunicaÁ„o serial
	BTFSC	STATUS, C
	BSF	GPIO, GP1
	BTFSS	STATUS, C
	BCF	GPIO, GP1
	NOP
	
	; Espera 104us (tempo entre bits)
	CALL	WAIT_99US
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF	GPIO, GP1   ; Transmite Parity bit da comunicaÁ„o serial
	
	GOTO	STOP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
