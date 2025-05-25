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

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		COUNTER
		COMPLEMENT

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
	BANK0
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP
	
	BCF     T1CON, TMR1ON	;Para TIMER1
	
	MOVLW   0xFF
	MOVWF   TMR1H		;Seta os 8 bits mais significativos do TIMER1
	
	MOVLW   0xF4
	MOVWF   TMR1L		;Seta os 8 bits menos significativos do TIMER1
	
	MOVLW	B'00111101'	;Configura o TIMER1
	MOVWF	T1CON
	
	BCF	PIR1,	TMR1IF	;Clear interrup��o

	BSF     T1CON, TMR1ON	;Come�a TIMER1

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
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000010'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00000010'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'11000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'00000001'
	MOVWF	PIE1		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'10000000'
	MOVWF	VRCON
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000100'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00111101'
	MOVWF	T1CON
	


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
; =================================================================
; C�digo para o PIC12F675 que ajusta o brilho de um LED (GP4) com base
; na tens�o de entrada aplicada � porta GP1.
; O duty cycle varia de 0% a 100% conforme a tens�o de GP1 varia de 0V a 3,5V.
; =================================================================

MAIN
    BCF		GPIO, GP4        ; Garante que o LED (GP4) inicie desligado.

; =================================================================
; CONFIGURA��O DO COMPARADOR E INICIALIZA��O DE VARI�VEIS
; =================================================================
LOOP1_SETUP    
    MOVLW	B'10100000'	    ; Carrega a configura��o inicial para VRCON (low range)
				    ; Define a tens�o de refer�ncia do comparador.

    BANK1			    ; Muda para o banco 1 (onde est� o VRCON).
    MOVWF	VRCON		    ; Armazena o valor carregado no registrador VRCON.
    BANK0			    ; Retorna ao banco 0.

    CLRF	COUNTER		    ; Zera a vari�vel COUNTER que controla o duty cycle.

    MOVLW	B'00000001'	    ; Carrega o valor 1 no acumulador W.
				    ; Ser� usado para incrementar COUNTER.

; =================================================================
; PRIMEIRO LOOP DE AJUSTE DO DUTY CYCLE - (Ajuste progressivo do Duty Cycle)
; =================================================================
LOOP1
    BTFSC	CMCON, COUT	    ; Verifica se a sa�da do comparador (COUT) est� em 1.
    GOTO	BLINK_LED	    ; Se sim, pula para a rotina de controle do LED. (VIN- > CVRef)

    ADDWF	COUNTER, 1	    ; Incrementa COUNTER.
    BTFSC	STATUS, DC	    ; Se o bit de "carry" do STATUS for 1 (overflow),
    GOTO	LOOP2_SETUP	    ; muda para o segundo est�gio de ajuste.

    BANK1			    ; Muda para o banco 1.
    ADDWF	VRCON		    ; Atualiza VRCON para ajustar a refer�ncia de tens�o.
    BANK0			    ; Retorna para o banco 0.

    GOTO	LOOP1		    ; Volta para continuar ajustando o duty cycle.

; =================================================================
; CONFIGURA��O DO COMPARADOR
; =================================================================
LOOP2_SETUP
    MOVLW	B'10001101'	    ; Define uma nova configura��o para VRCON (high range)

    BANK1
    MOVWF	VRCON		    ; Atualiza VRCON com o novo valor.
    BANK0

    MOVLW	B'00000001'	    ; Prepara o incremento para COUNTER.

; =================================================================
; SEGUNDO LOOP DE AJUSTE DO DUTY CYCLE - (Ajuste progressivo do Duty Cycle)
; =================================================================
LOOP2
    BTFSC	CMCON, COUT      ; Verifica se a sa�da do comparador (COUT) est� em 1. (VIN- > CVRef)
    GOTO	BLINK_LED        ; Se sim, pula para a rotina do LED.

    ADDWF	COUNTER, 1       ; Incrementa COUNTER.
    BTFSC	STATUS, DC       ; Se ocorrer overflow, pula para acionar o LED.
    GOTO	BLINK_LED

    BANK1
    ADDWF	VRCON		 ; Atualiza VRCON para novo ajuste da refer�ncia de tens�o.
    BANK0

    GOTO	LOOP2		 ; Continua ajustando at� atingir a condi��o.

; =================================================================
; CONTROLE DO LED - ACENDER
; =================================================================
BLINK_LED
    MOVLW	B'00010010'	    ; Carrega um valor fixo para o registrador COMPLEMENT.
    MOVWF	COMPLEMENT	    ; COMPLEMENT ser� usado para controle de tempo.

    MOVLW	B'00000000'	    ; Carrega 0 no acumulador W.
    XORWF	COUNTER		    ; Verifica se COUNTER � 0.
    BTFSC	STATUS, Z	    ; Se COUNTER == 0, volta ao in�cio.
    GOTO	MAIN

    BSF		GPIO, GP4	    ; Acende o LED (GP4).

; =================================================================
; ATRASO PARA O TEMPO LIGADO DO LED (DUTY CYCLE)
; =================================================================
SLEEP_LOOP_LED_ON
    DECF	COMPLEMENT	    ; Decrementa o registrador COMPLEMENT.
    MOVLW	B'00000000'	    ; Carrega 0 em W.
    XORWF	COMPLEMENT	    ; Verifica se COMPLEMENT chegou a 0.

    SLEEP			    ; Entra no modo de baixo consumo para controle do tempo.

    BTFSC	STATUS, Z	    ; Se COMPLEMENT zerou, volta ao in�cio do loop.
    GOTO	LOOP1_SETUP

    DECFSZ	COUNTER		    ; Decrementa COUNTER, se n�o for zero, repete o loop.
    GOTO	SLEEP_LOOP_LED_ON

    BCF		GPIO, GP4	    ; Desliga o LED (GP4).

; =================================================================
; ATRASO PARA O TEMPO DESLIGADO DO LED
; =================================================================
SLEEP_LOOP_LED_OFF
    SLEEP			; Entra em modo de economia de energia.
    DECFSZ	COMPLEMENT      ; Decrementa COMPLEMENT at� zerar.
    GOTO	SLEEP_LOOP_LED_OFF

    GOTO	LOOP1_SETUP      ; Reinicia o processo de ajuste do duty cycle.


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    END