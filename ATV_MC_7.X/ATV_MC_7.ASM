;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     Março DE 2025                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERSÃO: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
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
		DADO		;ARMAZENA O DADO PARA A EEPROM
		CONV_COUNTER
		LAST_ALT_AVG
		ALT_AVG_H
		ALT_AVG_L
		TIMER_COUNTER

		;NOVAS VARIÁVEIS

	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
; INICIALIZAÇÃO DA EEPROM, DE ACORDO COM A DESCRIÇÃO NO ARQUIVO "Def_Rega_Formigas.inc"

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
	
	BTFSS   PIR1, ADIF	; Verifica se a interrupção foi do ADC (ADIF=1?)
	GOTO    TIMER1_INT	; Se não foi, vai para tratamento do Timer1
    
AC_CONV_INT			; Rotina de tratamento da interrupção do ADC
	INCF    CONV_COUNTER	; Incrementa o contador de conversões
	MOVFW   ADRESH		; Move o resultado alto do ADC para W
	ADDWF   ALT_AVG_L	; Soma ao acumulador baixo de altitude
    
	BTFSC   STATUS, C	; Verifica se houve carry na soma
	INCF    ALT_AVG_H	; Se houve, incrementa o acumulador alto
    
	BCF     PIR1, ADIF	; Limpa o flag de interrupção do ADC
	BSF     ADCON0, GO	; Inicia nova conversão A/D
    
	GOTO    SAI_INT		; Sai da interrupção
    
TIMER1_INT			; Rotina de tratamento da interrupção do Timer1
	BCF     T1CON, TMR1ON	; Desliga o Timer1

	MOVLW   B'00001011'	; Valor para recarregar TMR1H (high byte)
	MOVWF   TMR1H		; Configura os 8 bits mais significativos

	MOVLW   B'11011100'	; Valor para recarregar TMR1L (low byte)
	MOVWF   TMR1L		; Configura os 8 bits menos significativos

	MOVLW   B'00111101'	; Configuração do Timer1:
				; - Clock interno
				; - Prescaler 1:8
				; - Timer ligado
	MOVWF   T1CON		; Aplica a configuração

	BCF     PIR1, TMR1IF	; Limpa o flag de interrupção do Timer1
    
	INCF    TIMER_COUNTER	; Incrementa o contador de tempo
    
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
LE_EEPROM
;LER DADO DA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;O DADO LIDO RETORNA EM W
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR		;INDICA O END. DE LEITURA
	BSF		EECON1,RD	;INICIA O PROCESSO DE LEITURA
	MOVF	EEDATA,W	;COLOCA DADO LIDO EM W
	BANK0				;POSICIONA PARA BANK 0
	RETURN

GRAVA_EEPROM
;ESCREVE UM DADO NA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;O DADO A SER ESCRITO DEVE ESTAR ARMAZENADO NA VARIÁVEL DADO
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF		EECON1,WREN ;HABILITA ESCRITA
	BCF		INTCON,GIE	;DESLIGA INTERRUPÇÕES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF		EECON1,WR ;INICIA A ESCRITA
AGUARDA
	BTFSC	EECON1,WR ;TERMINOU?
	GOTO	AGUARDA
	BSF		INTCON,GIE ;HABILITA INTERRUPÇÕES
	BANK0				;POSICIONA PARA BANK 0
	RETURN

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000101' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00010100'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'11000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'01000001'
	MOVWF	PIE1
	MOVLW	B'00000001'
	MOVWF	WPU
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00001001'
	MOVWF	ADCON0
	MOVLW	B'00111100'	;Configura o TIMER1
	MOVWF	T1CON

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
    CLRF    CONV_COUNTER	; Limpa o contador de conversões
    CLRF    LAST_ALT_AVG	; Limpa o último valor médio de altitude
    CLRF    TIMER_COUNTER	; Limpa o contador do timer
    CLRF    ADRESH		; Limpa o registro alto do resultado ADC
    
INIT_LOOP
    BTFSC   GPIO, GP0		; Verifica se o pino GP0 está em nível baixo
    GOTO    INIT_LOOP		; Se não estiver, continua no loop
    
    BSF     ADCON0, GO		; C.C Inicia a conversão A/D
    
LOW_LOOP
    MOVLW   .5			; Carrega 5 em W (referente aos 10 metros)
    SUBWF   ADRESH, W		; Subtrai W de ADRESH
    BTFSS   STATUS, C		; Verifica se o resultado é negativo (C=0)
    GOTO    LOW_LOOP		; Se for, continua no loop
		              
    CLRF    ALT_AVG_H		; Limpa a parte alta da média de altitude
    CLRF    ALT_AVG_L		; Limpa a parte baixa da média de altitude
    
RESET_AVG
    MOVFW   ALT_AVG_L		; Move ALT_AVG_L para W
    MOVWF   LAST_ALT_AVG	; Armazena em LAST_ALT_AVG (última média)
    CLRF    ALT_AVG_H		; Limpa a parte alta da média
    CLRF    ALT_AVG_L		; Limpa a parte baixa da média
    CLRF    CONV_COUNTER	; Zera o contador de conversões
    BSF     ADCON0, GO		; Inicia nova conversão A/D
    
AVG_LOOP
    MOVLW   .32			; Carrega 32 em W (número de amostras)
    SUBWF   CONV_COUNTER, W	; Subtrai do contador de conversões
    BTFSS   STATUS, Z		; Verifica se já atingiu 32 amostras
    GOTO    AVG_LOOP		; Se não, continua no loop
    
    BCF     ADCON0, GO		; Para a conversão A/D
    
AVG_CALC
    BCF     STATUS, C		; Limpa o bit de carry
    
    ; Realiza 5 rotações à direita (divide por 32) no valor acumulado
    RRF     ALT_AVG_H		; Rotaciona a parte alta
    RRF     ALT_AVG_L		; Rotaciona a parte baixa
    RRF     ALT_AVG_H
    RRF     ALT_AVG_L
    RRF     ALT_AVG_H
    RRF     ALT_AVG_L
    RRF     ALT_AVG_H
    RRF     ALT_AVG_L
    RRF     ALT_AVG_H
    RRF     ALT_AVG_L
    
    MOVFW   LAST_ALT_AVG	; Carrega última média em W
    SUBWF   ALT_AVG_L, W	; Subtrai da média atual
    BTFSC   STATUS, C		; Verifica se a média atual é menor
    GOTO    RESET_AVG		; Se não for, reinicia o cálculo
    
CONFIG_TIMER1
    MOVLW   B'00001011'		; Valor para TMR1H (timer 1 high byte)
    MOVWF   TMR1H		; Configura os 8 bits mais significativos
    
    MOVLW   B'11011100'		; Valor para TMR1L (timer 1 low byte)
    MOVWF   TMR1L		; Configura os 8 bits menos significativos
    
    MOVLW   B'00111100'		; Configuração do Timer1
    MOVWF   T1CON		; Habilita com prescaler 1:8
    
    BSF     T1CON, TMR1ON	; Liga o Timer1
    
    
GRAVA_APOGEU
    MOVFW   LAST_ALT_AVG	; Carrega o último valor médio válido
    MOVWF   DADO		; Armazena em DADO
    MOVLW   0x13		; Endereço 0x13 da EEPROM
    CALL    GRAVA_EEPROM	; Chama rotina para gravar na EEPROM
    
WAIT_5S
    MOVLW   .10			; Contador para esperar ~5 segundos
    SUBWF   TIMER_COUNTER, W	; Verifica se já atingiu
    BTFSS   STATUS, Z		; Se zero, tempo atingido
    GOTO    WAIT_5S		; Se não, continua esperando
    
    BSF     GPIO, GP1		; Ativa saída GP1 (aciona paraquedas)
    CLRF    TIMER_COUNTER	; Zera o contador novamente
    
OPEN_CHUTE
    MOVLW   .4			; Tempo para manter paraquedas aberto
    SUBWF   TIMER_COUNTER, W	; Verifica se já atingiu
    BTFSS   STATUS, Z		; Se zero, tempo atingido
    GOTO    OPEN_CHUTE		; Se não, continua esperando
    
    BCF     GPIO, GP1		; Desativa saída GP1 (fecha paraquedas)
    BCF     T1CON, TMR1ON	; Desliga o Timer1
    BCF     ADCON0, GO		; Desliga o conversor A/D
	
FIM
	GOTO FIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
