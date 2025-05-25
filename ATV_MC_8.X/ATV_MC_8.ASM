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

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_ON & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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
	MOVLW	B'00000001' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00010001'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00001111'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	CALL	0x3FF
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00000001'
	MOVWF	ADCON0
	CLRF	T1CON

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;===============================================================================
; CARACTER�STICAS DE CONSUMO:
;   - Corrente no modo WDT:		17 �A  (~2 segundos em atividade)
;   - Corrente durante convers�o A\D:	1  �A  (~41 �s por convers�o)
;   - Corrente com LED ativo:		18 mA  (~2 segundos por ativa��o)
;   - Consumo total estimado:		90.850 �Wh
;===============================================================================
	
MAIN
    BSF ADCON0, ADON	    ; Liga o m�dulo ADC (Conversor Anal�gico-Digital)
    CLRWDT		    ; Limpa o Watchdog Timer (evita reset acidental)

    BANK1		    
    MOVLW B'00001111'	    ; Carrega W com o valor para configurar OPTION_REG:
			    ; - Bits 0-2: Prescaler do WDT (1:128)
			    ; - Bit 3: Prescaler designado ao WDT
    MOVWF OPTION_REG	    ; Configura o OPTION_REG com os valores acima
    BANK0		    

    BSF ADCON0, GO	    ; Inicia a convers�o ADC (seta o bit GO)

CONV_LOOP
    BTFSS PIR1, ADIF	    ; Verifica se a convers�o ADC terminou (flag ADIF setada)
    GOTO CONV_LOOP	    ; Se n�o terminou, continua no loop
    BCF PIR1, ADIF	    ; Limpa a flag de interrup��o do ADC

MENOR_QUE_DOIS		    ; Verifica se a tens�o � menor que ~2V (102 em ADRESH)
    MOVLW .102		    ; Carrega W com o valor de refer�ncia (102 ? 2V)
    SUBWF ADRESH, W	    ; Subtrai W do resultado do ADC (byte alto)
    BTFSC STATUS, C	    ; Verifica a flag de carry (se ADRESH >= W)
    GOTO MENOR_QUE_TRES	    ; Se >= 102, pula para o pr�ximo limite

    ; Se a tens�o est� abaixo de ~2V
    BCF GPIO, GP2	    ; Desliga GP2
    BCF GPIO, GP4	    ; Desliga GP4
    BCF GPIO, GP5	    ; Desliga GP5
    BSF GPIO, GP1	    ; Liga GP1 (indica faixa de tens�o mais baixa)
    GOTO DORMIR		    ; Vai para o modo de dormir

MENOR_QUE_TRES		    ; Verifica se a tens�o � menor que ~3V (153 em ADRESH)
    MOVLW .153		    ; Carrega W com o valor de refer�ncia (153 ? 3V)
    SUBWF ADRESH, W	    ; Subtrai do resultado do ADC
    BTFSC STATUS, C	    ; Verifica a flag de carry
    GOTO MENOR_QUE_QUATRO   ; Se >= 153, pula para o pr�ximo limite

    ; Se a tens�o est� entre ~2V e ~3V
    BCF GPIO, GP1	    ; Desliga GP1
    BCF GPIO, GP4	    ; Desliga GP4
    BCF GPIO, GP5	    ; Desliga GP5
    BSF GPIO, GP2	    ; Liga GP2 (indica faixa de tens�o m�dia-baixa)
    GOTO DORMIR		    ; Vai para o modo de dormir

MENOR_QUE_QUATRO	    ; Verifica se a tens�o � menor que ~4V (204 em ADRESH)
    MOVLW .204		    ; Carrega W com o valor de refer�ncia (204 ? 4V)
    SUBWF ADRESH, W	    ; Subtrai do resultado do ADC
    BTFSC STATUS, C	    ; Verifica a flag de carry
    GOTO MAIOR_QUE_QUATRO   ; Se >= 204, pula para a faixa mais alta

    ; Se a tens�o est� entre ~3V e ~4V
    BCF GPIO, GP1	    ; Desliga GP1
    BCF GPIO, GP2	    ; Desliga GP2
    BCF GPIO, GP5	    ; Desliga GP5
    BSF GPIO, GP4	    ; Liga GP4 (indica faixa de tens�o m�dia-alta)
    GOTO DORMIR		    ; Vai para o modo de dormir

MAIOR_QUE_QUATRO	    ; Tens�o maior que ~4V (faixa mais alta)
    BCF GPIO, GP1	    ; Desliga GP1
    BCF GPIO, GP2	    ; Desliga GP2
    BCF GPIO, GP4	    ; Desliga GP4
    BSF GPIO, GP5	    ; Liga GP5 (indica faixa de tens�o mais alta)

DORMIR			    ; Rotina de "dormir" (baixo consumo)
    BCF ADCON0, ADON	    ; Desliga o ADC para economizar energia
    SLEEP		    ; Entra em modo de baixo consumo (SLEEP)
    GOTO MAIN		    ; Ao acordar, reinicia o programa

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
