;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2024                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_OFF & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA
#DEFINE START_COUNT .3  ; Define uma constante START_COUNT com valor 3


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		DC_R
		DC_G
		DC_B
		TIMER_COUNT

		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP
	
SELECT_PIN
	BTFSS	GPIO, GP3	; Verifica se o pino GP3 est� em n�vel alto
	GOTO	NEXT		; Se n�o estiver, pula para NEXT
	BTFSS	GPIO, GP5	; Verifica se o pino GP5 est� em n�vel alto
	GOTO	NEXT		; Se n�o estiver, pula para NEXT
	GOTO	SET_BLUE	; Se ambos GP3 e GP5 estiverem altos, vai para SET_BLUE
	
NEXT
	BTFSC	GPIO, GP5	; Verifica se o pino GP5 est� em n�vel baixo
	GOTO	SET_GREEN	; Se estiver alto, vai para SET_GREEN
	BTFSC	GPIO, GP3	; Verifica se o pino GP3 est� em n�vel baixo
	GOTO	SET_RED		; Se estiver alto, vai para SET_RED
	GOTO	CLEAR_ALL	; Se ambos estiverem baixos, vai para CLEAR_ALL

SET_RED
	MOVFW	ADRESH	        ; Move o valor do registrador ADRESH (resultado do ADC) para W
	MOVWF	DC_R	        ; Move o valor de W para o registrador DC_R (controle do LED vermelho)
	GOTO	CLEAR_TIMER_INT	; Vai para CLEAR_TIMER_INT

SET_GREEN
	MOVFW	ADRESH	        ; Move o valor do registrador ADRESH para W
	MOVWF	DC_G	        ; Move o valor de W para o registrador DC_G (controle do LED verde)
	GOTO	CLEAR_TIMER_INT	; Vai para CLEAR_TIMER_INT

SET_BLUE
	MOVFW	ADRESH	        ; Move o valor do registrador ADRESH para W
	MOVWF	DC_B	        ; Move o valor de W para o registrador DC_B (controle do LED azul)
	GOTO	CLEAR_TIMER_INT	; Vai para CLEAR_TIMER_INT

CLEAR_ALL
	CLRF	DC_R	        ; Limpa o registrador DC_R (desliga o LED vermelho)
	CLRF	DC_G	        ; Limpa o registrador DC_G (desliga o LED verde)
	CLRF	DC_B	        ; Limpa o registrador DC_B (desliga o LED azul)
	
CLEAR_TIMER_INT
	BCF	INTCON, T0IF	; Limpa a flag de interrup��o do timer TMR0
	MOVLW	START_COUNT	; Move a constante START_COUNT para W
	MOVWF	TMR0	        ; Move o valor de W para o registrador TMR0 (inicializa o timer)
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00111000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00011000'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000010'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'11100000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'00000000'
	MOVWF	PIE1
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00001111'
	MOVWF	ADCON0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	;CORPO DA ROTINA PRINCIPAL

	BCF	GPIO, GP0	; Desliga o pino GP0 (LED vermelho)
	BCF	GPIO, GP1	; Desliga o pino GP1 (LED verde)
	BCF	GPIO, GP2	; Desliga o pino GP2 (LED azul)
	
LOOP
	BSF	ADCON0, GO	; Inicia a convers�o do ADC

	MOVFW	TMR0	        ; Move o valor do registrador TMR0 para W
	MOVWF	TIMER_COUNT	; Move o valor de W para o registrador TIMER_COUNT
	MOVLW	START_COUNT	; Move a constante START_COUNT para W
	SUBWF	TIMER_COUNT, 1	; Subtrai START_COUNT de TIMER_COUNT e armazena o resultado em TIMER_COUNT

RED
	MOVFW	DC_R	        ; Move o valor do registrador DC_R para W
	SUBWF	TIMER_COUNT, 0	; Subtrai DC_R de TIMER_COUNT e armazena o resultado em W
	BTFSC	STATUS, C	; Verifica se o resultado da subtra��o foi positivo (DC_R <= TIMER_COUNT)
	GOTO	TURN_RED_OFF	; Se foi positivo, vai para TURN_RED_OFF 
	
TURN_RED_ON
	BSF	GPIO, GP0	; Liga o pino GP0 (LED vermelho)
	GOTO	GREEN	        ; Vai para GREEN
	
TURN_RED_OFF
	MOVFW	DC_R	        ; Move o valor do registrador DC_R para W
	SUBLW	.249	        ; Subtrai DC_R de 249 e armazena o resultado em W
	BTFSC	STATUS, C	; Verifica se o resultado da subtra��o foi positivo (DC_R >= 250)
	BCF	GPIO, GP0	; Se foi positivo, desliga o pino GP0 (LED vermelho)


GREEN
	MOVFW	DC_G	        ; Move o valor do registrador DC_G para W
	SUBWF	TIMER_COUNT, 0	; Subtrai DC_G de TIMER_COUNT e armazena o resultado em W
	BTFSC	STATUS, C	; Verifica se o resultado da subtra��o foi positivo (DC_G <= TIMER_COUNT)
	GOTO	TURN_GREEN_OFF	; Se foi positivo, vai para TURN_GREEN_OFF

TURN_GREEN_ON
	BSF	GPIO, GP1	; Liga o pino GP1 (LED verde)
	GOTO	BLUE	        ; Vai para BLUE
	
TURN_GREEN_OFF
	MOVFW	DC_G	        ; Move o valor do registrador DC_G para W
	SUBLW	.249	        ; Subtrai DC_G de 249 e armazena o resultado em W
	BTFSC	STATUS, C	; Verifica se o resultado da subtra��o foi positivo (DC_G >= 250)
	BCF	GPIO, GP1	; Se foi positivo, desliga o pino GP1 (LED verde)
	

BLUE
    	MOVFW	DC_B	        ; Move o valor do registrador DC_B para W
	SUBWF	TIMER_COUNT, 0	; Subtrai DC_B de TIMER_COUNT e armazena o resultado em W
	BTFSC	STATUS, C	; Verifica se o resultado da subtra��o foi positivo (DC_B <= TIMER_COUNT)
	GOTO	TURN_BLUE_OFF	; Se foi positivo, vai para TURN_BLUE_OFF

TURN_BLUE_ON
	BSF	GPIO, GP2	; Liga o pino GP2 (LED azul)
    	GOTO	LOOP	        ; Volta para LOOP
	
TURN_BLUE_OFF
	MOVFW	DC_B	        ; Move o valor do registrador DC_B para W
	SUBLW	.249	        ; Subtrai DC_B de 249 e armazena o resultado em W
	BTFSC	STATUS, C	; Verifica se o resultado da subtra��o foi positivo (DC_B >= 250)
	BCF	GPIO, GP2	; Se foi positivo, desliga o pino GP2 (LED azul)
	GOTO	LOOP	        ; Volta para LOOP


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
