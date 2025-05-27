/*********************************************
 * 1. DECLARA��O DE PREDICADOS DIN�MICOS
 *********************************************/
:- dynamic(bateria/1).              % Voltagem da bateria
:- dynamic(temperatura_motor/1).    % Temperatura do motor em �C
:- dynamic(nivel_oleo/1).          % N�vel do �leo do motor
:- dynamic(sensor_oxigenio/1).     % Leitura do sensor de oxig�nio (lambda)
:- dynamic(falha_ignicao/0).       % Indica falha na igni��o/partida
:- dynamic(barulho_incomum/0).     % Indica presen�a de ru�dos an�malos
:- dynamic(rotacao_alta/0).        % Indica problemas em alta rota��o
:- dynamic(luz_check_engine/0).    % Luz check engine acesa
:- dynamic(luz_bateria/0).         % Luz da bateria acesa no painel


/*********************************************
 * 2. FATOS B�SICOS (SINTOMAS E CAUSAS)
 *    - Aqui definimos sintomas e as poss�veis
 *      causas associadas a cada um deles. (n�o mexer)
 *********************************************/

/* Exemplos de causas representadas por termos que
   indicam poss�veis problemas */
causa(bateria_fraca).              % Bateria com baixa carga
causa(alternador_defeituoso).      % Alternador n�o funciona adequadamente
causa(sistema_arrefecimento).      % Problemas no sistema de refrigera��o
causa(baixo_nivel_oleo).          % N�vel de �leo insuficiente
causa(vela_ignicao_defeituosa).   % Velas de igni��o com defeito
causa(sensor_oxigenio_defeituoso). % Sensor lambda defeituoso
causa(problema_injecao).          % Sistema de inje��o com problemas
causa(problema_transmissao).      % Transmiss�o/c�mbio com defeito
causa(problema_interno_motor).    % Ex.: biela, pist�o, etc.

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
    falha_ignicao,                 % Carro n�o pega
    luz_bateria,                   % Luz da bateria acesa
    bateria(Voltage),              % Obt�m voltagem da bateria
    Voltage < 12.                  % Voltagem baixa (< 12V)

% 3.2 Diagn�stico de alternador defeituoso
%    - Se a bateria est� fraca mesmo ap�s recarga,
%      ou se a luz de bateria acende durante o uso,
%      suspeita do alternador.
diagnostico(alternador_defeituoso) :-
    luz_bateria,                   % Luz da bateria acesa
    \+ diagnostico(bateria_fraca). % MAS n�o � bateria fraca
    /* Se n�o foi diagnosticada bateria_fraca,
       mas a luz continua acesa, pode ser alternador. */

% 3.3 Diagn�stico de superaquecimento / sistema de arrefecimento
%    - Se temperatura do motor > 100�C e/ou check engine aceso,
%      indicamos problema de arrefecimento.
diagnostico(sistema_arrefecimento) :-
    temperatura_motor(T),          % Obt�m temperatura do motor
    T > 100.                       % Superaquecimento cr�tico (> 100�C)

diagnostico(sistema_arrefecimento) :-
    luz_check_engine,              % Check engine acesa E
    temperatura_motor(T),          % Temperatura elevada
    T > 90.                        % Temperatura preocupante (> 90�C)

% 3.4 Diagn�stico de baixo n�vel de �leo
%    - Se n�vel do �leo est� abaixo do m�nimo,
%      sugerimos problema relacionado ao �leo.
diagnostico(baixo_nivel_oleo) :-
    nivel_oleo(Nivel),             % Obt�m n�vel atual do �leo
    Nivel < 1.0.                   % N�vel cr�tico (< 1.0 litro)

% 3.5 Diagn�stico de vela de igni��o defeituosa
%    - Se h� falha de igni��o frequente, mas a bateria est� boa,
%      suspeitamos da vela de igni��o.
diagnostico(vela_ignicao_defeituosa) :-
    falha_ignicao,                 % Falha na igni��o
    \+ diagnostico(bateria_fraca), % MAS bateria n�o est� fraca
    bateria(Voltage),              % Confirma voltagem da bateria
    Voltage >= 12.                 % Bateria boa (= 12V)

% 3.6 Diagn�stico de sensor de oxig�nio defeituoso
%    - Se o sensor de oxig�nio marca valor fora da faixa normal
%      e a luz de check engine pisca somente em alta rota��o,
%      pode ser o sensor de oxig�nio.
diagnostico(sensor_oxigenio_defeituoso) :-
    sensor_oxigenio(Valor),        % Obt�m leitura do sensor lambda
    (Valor < 0.1; Valor > 0.9),   % Valor anormal (fora de 0.1-0.9)
    rotacao_alta,                  % Problema em alta rota��o
    luz_check_engine.              % Check engine acesa

% 3.7 Diagn�stico de problema na inje��o
%    - Se h� falha em alta rota��o e a leitura do sensor de
%      oxig�nio est� na faixa normal, pode ser a inje��o.
diagnostico(problema_injecao) :-
    rotacao_alta,                  % Problema em alta rota��o
    luz_check_engine,              % Check engine acesa
    sensor_oxigenio(Valor),        % Obt�m leitura do sensor
    Valor >= 0.1,                  % Sensor funcionando normalmente
    Valor =< 0.9.                  % (faixa normal: 0.1 a 0.9)

% 3.8 Diagn�stico de ru�dos no motor (problema interno ou transmiss�o)
%    - Se h� barulho incomum e perda de pot�ncia, mas a check engine
%      n�o acende, pode ser mec�nico (bielas, transmiss�o etc.).
diagnostico(problema_interno_motor) :-
    barulho_incomum,               % Ru�dos estranhos no motor
    \+ luz_check_engine,           % Check engine N�O acesa
    temperatura_motor(T),          % Verifica temperatura
    T < 100,                       % Temperatura normal (< 100�C)
    !.                             % Corte para evitar backtracking

diagnostico(problema_transmissao) :-
    barulho_incomum,               % Ru�dos estranhos
    rotacao_alta,                  % Problema em alta rota��o
    \+ luz_check_engine.           % Check engine N�O acesa

/*********************************************
 * 4. RECOMENDA��ES DE A��O
 *    - Associa cada causa a uma recomenda��o
 *      de manuten��o / corre��o.
 *********************************************/
recomendacao(bateria_fraca, 'Recarregar ou substituir a bateria').
recomendacao(alternador_defeituoso, 'Verificar correia do alternador ou trocar alternador').
recomendacao(sistema_arrefecimento, 'Checar radiador, bomba d\'�gua, ventoinha e fluido de arrefecimento').
recomendacao(baixo_nivel_oleo, 'Completar o n�vel de �leo do motor ou verificar vazamentos').
recomendacao(vela_ignicao_defeituosa, 'Verificar e substituir velas de igni��o defeituosas').
recomendacao(sensor_oxigenio_defeituoso, 'Substituir sensor de oxig�nio (sonda lambda)').
recomendacao(problema_injecao, 'Verificar sistema de inje��o e fazer limpeza dos bicos injetores').
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
    (   ListaCausas \= []          % Se encontrou pelo menos uma causa
    ->  format('Possiveis problemas diagnosticados: ~w~n',[ListaCausas]),
        listar_recomendacoes(ListaCausas) % Lista as recomenda��es
    ;   write('Nenhum problema foi diagnosticado com as informacoes atuais.'), nl
    ).

listar_recomendacoes([]).          % Caso base: lista vazia
listar_recomendacoes([Causa|Resto]) :-
    recomendacao(Causa, Rec),      % Busca recomenda��o para a causa
    format(' -> Para ~w, recomenda-se: ~w~n', [Causa, Rec]),
    listar_recomendacoes(Resto).   % Processa resto da lista


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
    limpar_estado,                 % Limpa estado anterior
    assertz(falha_ignicao),        % Adiciona falha de igni��o
    assertz(luz_bateria),          % Adiciona luz da bateria acesa
    assertz(bateria(11.8)),        % Bateria com 11.8V (fraca)
    diagnosticar,                  % Executa diagn�stico
    limpar_estado.                 % Limpa para pr�ximo teste

caso_teste_2_superaquecimento :-
    write('=== Caso de Teste 2: Superaquecimento no Motor ==='), nl,
    limpar_estado,                 % Limpa estado anterior
    assertz(temperatura_motor(105)), % Motor superaquecendo (105�C)
    assertz(nivel_oleo(1.5)),      % N�vel de �leo normal (1.5L)
    assertz(luz_check_engine),     % Check engine acesa
    diagnosticar,                  % Executa diagn�stico
    limpar_estado.                 % Limpa para pr�ximo teste

caso_teste_3_motor_engasgado_altas_rotacoes :-
    write('=== Caso de Teste 3: Motor Engasgado em Altas Rotacoes ==='), nl,
    limpar_estado,                 % Limpa estado anterior
    assertz(rotacao_alta),         % Problema em alta rota��o
    assertz(luz_check_engine),     % Check engine acesa
    assertz(sensor_oxigenio(1.0)), % Sensor lambda anormal (1.0)
    diagnosticar,                  % Executa diagn�stico
    limpar_estado.                 % Limpa para pr�ximo teste

caso_teste_4_ruidos_ao_acelerar :-
    write('=== Caso de Teste 4: Ruidos no Motor ao Acelerar ==='), nl,
    limpar_estado,                 % Limpa estado anterior
    assertz(barulho_incomum),      % Adiciona ru�do an�malo
    assertz(temperatura_motor(90)), % Temperatura normal (90�C)
    diagnosticar,                  % Executa diagn�stico
    limpar_estado.                 % Limpa para pr�ximo teste

% Predicado para limpar o estado din�mico antes/depois dos testes
limpar_estado :-
    retractall(bateria(_)),        % Remove fatos da bateria
    retractall(temperatura_motor(_)), % Remove fatos de temperatura
    retractall(nivel_oleo(_)),     % Remove fatos do n�vel de �leo
    retractall(sensor_oxigenio(_)), % Remove fatos do sensor lambda
    retractall(luz_check_engine),  % Remove fato check engine
    retractall(luz_bateria),       % Remove fato luz bateria
    retractall(falha_ignicao),     % Remove fato falha igni��o
    retractall(barulho_incomum),   % Remove fato barulho
    retractall(rotacao_alta).      % Remove fato rota��o alta

:- initialization(main).           % Inicializa programa com main

main :-
    write('=== Executando varios casos de teste ==='), nl,
    caso_teste_1_partida_inconsistente,     % Teste 1: Bateria fraca
    caso_teste_2_superaquecimento,          % Teste 2: Superaquecimento
    caso_teste_3_motor_engasgado_altas_rotacoes, % Teste 3: Alta rota��o
    caso_teste_4_ruidos_ao_acelerar,        % Teste 4: Ru�dos no motor
    halt.                          % Encerra o programa
