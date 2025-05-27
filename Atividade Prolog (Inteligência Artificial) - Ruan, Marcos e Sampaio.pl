/*********************************************
 * 1. DECLARA��O DE PREDICADOS DIN�MICOS
 *********************************************/
:- dynamic(bateria/1).
:- dynamic(temperatura_motor/1).
:- dynamic(nivel_oleo/1).
:- dynamic(sensor_oxigenio/1).
:- dynamic(luz_check_engine/0).
:- dynamic(luz_bateria/0).
:- dynamic(falha_ignicao/0).
:- dynamic(barulho_incomum/0).
:- dynamic(rotacao_alta/0).


/*********************************************
 * 2. FATOS B�SICOS (SINTOMAS E CAUSAS)
 *    - Aqui definimos sintomas e as poss�veis
 *      causas associadas a cada um deles. (n�o mexer)
 *********************************************/

/* Exemplos de causas representadas por termos que
   indicam poss�veis problemas */
causa(bateria_fraca).
causa(alternador_defeituoso).
causa(sistema_arrefecimento).
causa(baixo_nivel_oleo).
causa(vela_ignicao_defeituosa).
causa(sensor_oxigenio_defeituoso).
causa(problema_injecao).
causa(problema_transmissao).
causa(problema_interno_motor).  % Ex.: biela, pist�o, etc.

/*********************************************
 * 3. REGRAS DE DIAGN�STICO PRINCIPAIS
 *    - Se determinados sintomas e leituras
 *      de sensores estiverem presentes,
 *      inferimos a causa prov�vel.
 *********************************************/

% 3.1 Diagn�stico de bateria fraca
%    - Se h� falha de igni��o, luz de bateria acesa
%      e tens�o da bateria < 12, conclui-se bateria_fraca.
diagnostico(bateria_fraca) :-
    falha_ignicao,
    luz_bateria,
    bateria(Voltage),
    Voltage < 12.

% 3.2 Diagn�stico de alternador defeituoso
%    - Se a bateria est� fraca mesmo ap�s recarga,
%      ou se a luz de bateria acende durante o uso,
%      suspeita do alternador.
diagnostico(alternador_defeituoso) :-
    luz_bateria,
    \+ diagnostico(bateria_fraca).
    /* Se n�o foi diagnosticada bateria_fraca,
       mas a luz continua acesa, pode ser alternador. */

% 3.3 Diagn�stico de superaquecimento / sistema de arrefecimento
%    - Se temperatura do motor > 100�C e/ou check engine aceso,
%      indicamos problema de arrefecimento.
diagnostico(sistema_arrefecimento) :-
    temperatura_motor(T),
    T > 100.

diagnostico(sistema_arrefecimento) :-
    luz_check_engine,
    temperatura_motor(T),
    T > 90.

% 3.4 Diagn�stico de baixo n�vel de �leo
%    - Se n�vel do �leo est� abaixo do m�nimo,
%      sugerimos problema relacionado ao �leo.
diagnostico(baixo_nivel_oleo) :-
    nivel_oleo(Nivel),
    Nivel < 1.0.

% 3.5 Diagn�stico de vela de igni��o defeituosa
%    - Se h� falha de igni��o frequente, mas a bateria est� boa,
%      suspeitamos da vela de igni��o.
diagnostico(vela_ignicao_defeituosa) :-
    falha_ignicao,
    \+ diagnostico(bateria_fraca),
    bateria(Voltage),
    Voltage >= 12.

% 3.6 Diagn�stico de sensor de oxig�nio defeituoso
%    - Se o sensor de oxig�nio marca valor fora da faixa normal
%      e a luz de check engine pisca somente em alta rota��o,
%      pode ser o sensor de oxig�nio.
diagnostico(sensor_oxigenio_defeituoso) :-
    sensor_oxigenio(Valor),
    (Valor < 0.1; Valor > 0.9),
    rotacao_alta,
    luz_check_engine.

% 3.7 Diagn�stico de problema na inje��o
%    - Se h� falha em alta rota��o e a leitura do sensor de
%      oxig�nio est� na faixa normal, pode ser a inje��o.
diagnostico(problema_injecao) :-
    rotacao_alta,
    luz_check_engine,
    sensor_oxigenio(Valor),
    Valor >= 0.1,
    Valor =< 0.9.

% 3.8 Diagn�stico de ru�dos no motor (problema interno ou transmiss�o)
%    - Se h� barulho incomum e perda de pot�ncia, mas a check engine
%      n�o acende, pode ser mec�nico (bielas, transmiss�o etc.).
diagnostico(problema_interno_motor) :-
    barulho_incomum,
    \+ luz_check_engine,
    temperatura_motor(T),
    T < 100,  % Temperatura normal
    !.

diagnostico(problema_transmissao) :-
    barulho_incomum,
    rotacao_alta,
    \+ luz_check_engine.

/*********************************************
 * 4. RECOMENDA��ES DE A��O
 *    - Associa cada causa a uma recomenda��o
 *      de manuten��o / corre��o.
 *********************************************/
recomendacao(bateria_fraca, 'Recarregar ou substituir a bateria').
recomendacao(alternador_defeituoso, 'Verificar correia do alternador ou trocar alternador').
recomendacao(sistema_arrefecimento, 'Checar radiador, bomba d\'�gua, ventoinha e fluido de arrefecimento').
recomendacao(baixo_nivel_oleo, 'Completar o n�vel de �leo do motor ou trocar o �leo').
recomendacao(vela_ignicao_defeituosa, 'Verificar e substituir velas de igni��o defeituosas').
recomendacao(sensor_oxigenio_defeituoso, 'Substituir sensor de oxig�nio (sonda lambda)').
recomendacao(problema_injecao, 'Verificar sistema de inje��o e limpeza dos bicos injetores').
recomendacao(problema_transmissao, 'Verificar transmiss�o e trocar �leo da caixa se necess�rio').
recomendacao(problema_interno_motor, 'Inspe��o detalhada do motor - poss�vel problema em bielas, pist�es ou v�lvulas').

/*********************************************
 * 5. PREDICADO PRINCIPAL DE DIAGN�STICO
 *    - Identifica todas as causas poss�veis,
 *      exibe as recomenda��es. (n�o mexer)
 *********************************************/
diagnosticar :-
    % Encontra todas as causas que satisfazem as regras
    findall(Causa, diagnostico(Causa), ListaCausas),
    (   ListaCausas \= []
    ->  format('Possiveis problemas diagnosticados: ~w~n',[ListaCausas]),
        listar_recomendacoes(ListaCausas)
    ;   write('Nenhum problema foi diagnosticado com as informacoes atuais.'), nl
    ).

listar_recomendacoes([]).
listar_recomendacoes([Causa|Resto]) :-
    recomendacao(Causa, Rec),
    format(' -> Para ~w, recomenda-se: ~w~n', [Causa, Rec]),
    listar_recomendacoes(Resto).


/*********************************************
 * 6. EXEMPLOS DE CASOS DE TESTE
 *    - Cada cen�rio insere (assert) valores
 *      de sintomas e sensores, chama
 *      diagnosticar/0 e depois limpa o estado.
 * * (n�o mexer)
 *********************************************/
% Observa��o: Estes predicados s�o apenas exemplos
% de como testar. Ajuste conforme desejar.

caso_teste_1_partida_inconsistente :-
    write('=== Caso de Teste 1: Partida Inconsistente ==='), nl,
    limpar_estado,
    assertz(falha_ignicao),
    assertz(luz_bateria),
    assertz(bateria(11.8)),
    diagnosticar,
    limpar_estado.

caso_teste_2_superaquecimento :-
    write('=== Caso de Teste 2: Superaquecimento no Motor ==='), nl,
    limpar_estado,
    assertz(temperatura_motor(105)),
    assertz(nivel_oleo(1.5)),
    assertz(luz_check_engine),
    diagnosticar,
    limpar_estado.

caso_teste_3_motor_engasgado_altas_rotacoes :-
    write('=== Caso de Teste 3: Motor Engasgado em Altas Rotacoes ==='), nl,
    limpar_estado,
    assertz(rotacao_alta),
    assertz(luz_check_engine),
    assertz(sensor_oxigenio(1.0)), % valor fora do normal
    diagnosticar,
    limpar_estado.

caso_teste_4_ruidos_ao_acelerar :-
    write('=== Caso de Teste 4: Ruidos no Motor ao Acelerar ==='), nl,
    limpar_estado,
    assertz(barulho_incomum),
    assertz(temperatura_motor(90)),  % dentro da faixa normal
    diagnosticar,
    limpar_estado.

% Predicado para limpar o estado din�mico antes/depois dos testes
limpar_estado :-
    retractall(bateria(_)),
    retractall(temperatura_motor(_)),
    retractall(nivel_oleo(_)),
    retractall(sensor_oxigenio(_)),
    retractall(luz_check_engine),
    retractall(luz_bateria),
    retractall(falha_ignicao),
    retractall(barulho_incomum),
    retractall(rotacao_alta).

:- initialization(main).

main :-
    write('=== Executando varios casos de teste ==='), nl,
    caso_teste_1_partida_inconsistente,
    caso_teste_2_superaquecimento,
    caso_teste_3_motor_engasgado_altas_rotacoes,
    caso_teste_4_ruidos_ao_acelerar,
    halt.
