/*********************************************
 * 1. DECLARAÇÃO DE PREDICADOS DINÂMICOS
 *********************************************/
:- dynamic(bateria/1).              % Voltagem da bateria
:- dynamic(temperatura_motor/1).    % Temperatura do motor em °C
:- dynamic(nivel_oleo/1).          % Nível do óleo do motor
:- dynamic(sensor_oxigenio/1).     % Leitura do sensor de oxigênio (lambda)
:- dynamic(falha_ignicao/0).       % Indica falha na ignição/partida
:- dynamic(barulho_incomum/0).     % Indica presença de ruídos anômalos
:- dynamic(rotacao_alta/0).        % Indica problemas em alta rotação
:- dynamic(luz_check_engine/0).    % Luz check engine acesa
:- dynamic(luz_bateria/0).         % Luz da bateria acesa no painel
:- dynamic(velocidade_veiculo/1).  % Velocidade do veículo em km/h
:- dynamic(consumo_combustivel/1). % Consumo em L/100 km
:- dynamic(nivel_combustivel/1).   % Nível de combustivel em %
:- dynamic(perda_potencia/0).      % Indica perda de potência
:- dynamic(falha_partida_frio/0).  % Indica dificuldade na partida a frio
:- dynamic(historico_manutencao/2). % historico_manutencao(Componente, Dias)

/*********************************************
 * 2. FATOS BÁSICOS (SINTOMAS E CAUSAS)
 *    - Aqui definimos sintomas e as possíveis
 *      causas associadas a cada um deles. (não mexer)
 *********************************************/

/* Exemplos de causas representadas por termos que
   indicam possíveis problemas */
causa(bateria_fraca).              % Bateria com baixa carga
causa(alternador_defeituoso).      % Alternador não funciona adequadamente
causa(sistema_arrefecimento).      % Problemas no sistema de refrigeração
causa(baixo_nivel_oleo).          % Nível de óleo insuficiente
causa(vela_ignicao_defeituosa).   % Velas de ignição com defeito
causa(sensor_oxigenio_defeituoso). % Sensor lambda defeituoso
causa(problema_injecao).          % Sistema de injeção com problemas
causa(problema_transmissao).      % Transmissão/câmbio com defeito
causa(problema_interno_motor).    % Ex.: biela, pistão, etc.
causa(filtro_combustivel_entupido). % Filtro de combustivel bloqueado
causa(bomba_combustivel_defeituosa). % Bomba de combustivel com problema

/*********************************************
 * 3. REGRAS DE DIAGNÓSTICO PRINCIPAIS
 *    - Se determinados sintomas e leituras
 *      de sensores estiverem presentes,
 *      inferimos a causa provável.
 *********************************************/

% 3.1 Diagnóstico de bateria fraca
%    - Se há falha de ignição, luz de bateria acesa
%      e tensão da bateria < 12, conclui-se bateria_fraca.
diagnostico(bateria_fraca) :-
    falha_ignicao,                 % Carro não pega
    luz_bateria,                   % Luz da bateria acesa
    bateria(Voltage),              % Obtém voltagem da bateria
    Voltage < 12.                  % Voltagem baixa (< 12V)

% 3.2 Diagnóstico de alternador defeituoso
%    - Se a bateria está fraca mesmo após recarga,
%      ou se a luz de bateria acende durante o uso,
%      suspeita do alternador.
diagnostico(alternador_defeituoso) :-
    luz_bateria,                   % Luz da bateria acesa
    \+ diagnostico(bateria_fraca). % MAS não é bateria fraca
    /* Se não foi diagnosticada bateria_fraca,
       mas a luz continua acesa, pode ser alternador. */

% 3.3 Diagnóstico de superaquecimento / sistema de arrefecimento
%    - Se temperatura do motor > 100°C e/ou check engine aceso,
%      indicamos problema de arrefecimento.
diagnostico(sistema_arrefecimento) :-
    temperatura_motor(T),          % Obtém temperatura do motor
    T > 100.                       % Superaquecimento crítico (> 100°C)

diagnostico(sistema_arrefecimento) :-
    luz_check_engine,              % Check engine acesa E
    temperatura_motor(T),          % Temperatura elevada
    T > 90.                        % Temperatura preocupante (> 90°C)

% 3.4 Diagnóstico de baixo nível de óleo
%    - Se nível do óleo está abaixo do mínimo,
%      sugerimos problema relacionado ao óleo.
diagnostico(baixo_nivel_oleo) :-
    nivel_oleo(Nivel),             % Obtém nível atual do óleo
    Nivel < 1.0.                   % Nível crítico (< 1.0 litro)

% 3.5 Diagnóstico de vela de ignição defeituosa
%    - Se há falha de ignição frequente, mas a bateria está boa,
%      suspeitamos da vela de ignição.
diagnostico(vela_ignicao_defeituosa) :-
    falha_ignicao,                 % Falha na ignição
    \+ diagnostico(bateria_fraca), % MAS bateria não está fraca
    bateria(Voltage),              % Confirma voltagem da bateria
    Voltage >= 12.                 % Bateria boa (>= 12V)

% 3.6 Diagnóstico de sensor de oxigênio defeituoso
%    - Se o sensor de oxigênio marca valor fora da faixa normal
%      e a luz de check engine pisca somente em alta rotação,
%      pode ser o sensor de oxigênio.
diagnostico(sensor_oxigenio_defeituoso) :-
    sensor_oxigenio(Valor),        % Obtém leitura do sensor lambda
    (Valor < 0.1; Valor > 0.9),   % Valor anormal (fora de 0.1-0.9)
    rotacao_alta,                  % Problema em alta rotação
    luz_check_engine.              % Check engine acesa

% 3.7 Diagnóstico de problema na injeção
%    - Se há falha em alta rotação e a leitura do sensor de
%      oxigênio está na faixa normal, pode ser a injeção.
diagnostico(problema_injecao) :-
    rotacao_alta,                  % Problema em alta rotação
    luz_check_engine,              % Check engine acesa
    sensor_oxigenio(Valor),        % Obtém leitura do sensor
    Valor >= 0.1,                  % Sensor funcionando normalmente
    Valor =< 0.9.                  % (faixa normal: 0.1 a 0.9)

% 3.8 Diagnóstico de ruídos no motor (problema interno ou transmissão)
%    - Se há barulho incomum e perda de potência, mas a check engine
%      não acende, pode ser mecânico (bielas, transmissão etc.).
diagnostico(problema_interno_motor) :-
    barulho_incomum,               % Ruídos estranhos no motor
    \+ luz_check_engine,           % Check engine NÃO acesa
    temperatura_motor(T),          % Verifica temperatura
    T < 100,                       % Temperatura normal (< 100°C)
    !.                             % Corte para evitar backtracking

diagnostico(problema_transmissao) :-
    barulho_incomum,               % Ruídos estranhos
    rotacao_alta,                  % Problema em alta rotação
    \+ luz_check_engine.           % Check engine NÃO acesa

% 3.9 Diagnóstico de filtro de combustível entupido:
diagnostico(filtro_combustivel_entupido) :-
    perda_potencia,                % Perda de potência
    falha_partida_frio,           % Dificuldade na partida a frio
    rotacao_alta,                 % Problemas em alta rotação
    historico_manutencao(filtro_combustivel, Dias),
    Dias > 365.                   % Filtro não trocado há mais de 1 ano

% 3.10 Diagnóstico de bomba de combustível defeituosa:
diagnostico(bomba_combustivel_defeituosa) :-
    falha_ignicao,                % Falha na ignição
    nivel_combustivel(Nivel),     % Nível de combustível
    Nivel > 20,                   % Combustível suficiente
    bateria(Voltage),             % Bateria boa
    Voltage >= 12,                % Voltagem corrigida
    perda_potencia.               % Perda de potência

/*********************************************
 * 4. RECOMENDAÇÕES DE AÇÃO
 *    - Associa cada causa a uma recomendação
 *      de manutenção / correção.
 *********************************************/

recomendacao(bateria_fraca, 'Recarregar ou substituir a bateria').
recomendacao(alternador_defeituoso, 'Verificar correia do alternador ou trocar alternador').
recomendacao(sistema_arrefecimento, 'Checar radiador, bomba d\'água, ventoinha e fluido de arrefecimento').
recomendacao(baixo_nivel_oleo, 'Completar o nível de óleo do motor ou verificar vazamentos').
recomendacao(vela_ignicao_defeituosa, 'Verificar e substituir velas de ignição defeituosas').
recomendacao(sensor_oxigenio_defeituoso, 'Substituir sensor de oxigênio (sonda lambda)').
recomendacao(problema_injecao, 'Verificar sistema de injeção e fazer limpeza dos bicos injetores').
recomendacao(problema_transmissao, 'Verificar transmissão e trocar óleo da caixa se necessário').
recomendacao(problema_interno_motor, 'Inspeção detalhada do motor - possível problema em bielas, pistões ou válvulas').
recomendacao(bomba_combustivel_defeituosa, 'Verificar e substituir bomba de combustível').
recomendacao(filtro_combustivel_entupido, 'Substituir filtro de combustível').

% Sistema de criticidade
criticidade(bateria_fraca, media).
criticidade(vela_ignicao_defeituosa, media).
criticidade(problema_injecao, media).
criticidade(bomba_combustivel_defeituosa, alta).
criticidade(filtro_combustivel_entupido, baixa).
criticidade(_, baixa).

/*********************************************
 * 5. PREDICADO PRINCIPAL DE DIAGNÓSTICO
 *    - Identifica todas as causas possíveis,
 *      exibe as recomendações. (não mexer)
 *********************************************/
diagnosticar :-
    % Encontra todas as causas que satisfazem as regras
    findall(Causa, diagnostico(Causa), ListaCausas),
    (   ListaCausas \= []          % Se encontrou pelo menos uma causa
    ->  format('Possiveis problemas diagnosticados: ~w~n',[ListaCausas]),
        listar_recomendacoes(ListaCausas) % Lista as recomendações
    ;   write('Nenhum problema foi diagnosticado com as informacoes atuais.'), nl
    ).

listar_recomendacoes([]).          % Caso base: lista vazia
listar_recomendacoes([Causa|Resto]) :-
    recomendacao(Causa, Rec),      % Busca recomendação para a causa
    format(' -> Para ~w, recomenda-se: ~w~n', [Causa, Rec]),
    listar_recomendacoes(Resto).   % Processa resto da lista

/*********************************************
 * 6. EXEMPLOS DE CASOS DE TESTE
 *    - Cada cenário insere (assert) valores
 *      de sintomas e sensores, chama
 *      diagnosticar/0 e depois limpa o estado.
 * * (não mexer)
 *********************************************/

caso_teste_1_partida_inconsistente :-
    write('=== Caso de Teste 1: Partida Inconsistente ==='), nl,
    limpar_estado,                 % Limpa estado anterior
    assertz(falha_ignicao),        % Adiciona falha de ignição
    assertz(luz_bateria),          % Adiciona luz da bateria acesa
    assertz(bateria(11.8)),        % Bateria com 11.8V (fraca)
    diagnosticar,                  % Executa diagnóstico
    limpar_estado.                 % Limpa para próximo teste

caso_teste_2_superaquecimento :-
    write('=== Caso de Teste 2: Superaquecimento no Motor ==='), nl,
    limpar_estado,                 % Limpa estado anterior
    assertz(temperatura_motor(105)), % Motor superaquecendo (105°C)
    assertz(nivel_oleo(1.5)),      % Nível de óleo normal (1.5L)
    assertz(luz_check_engine),     % Check engine acesa
    diagnosticar,                  % Executa diagnóstico
    limpar_estado.                 % Limpa para próximo teste

caso_teste_3_motor_engasgado_altas_rotacoes :-
    write('=== Caso de Teste 3: Motor Engasgado em Altas Rotacoes ==='), nl,
    limpar_estado,                 % Limpa estado anterior
    assertz(rotacao_alta),         % Problema em alta rotação
    assertz(luz_check_engine),     % Check engine acesa
    assertz(sensor_oxigenio(1.0)), % Sensor lambda anormal (1.0)
    diagnosticar,                  % Executa diagnóstico
    limpar_estado.                 % Limpa para próximo teste

caso_teste_4_ruidos_ao_acelerar :-
    write('=== Caso de Teste 4: Ruidos no Motor ao Acelerar ==='), nl,
    limpar_estado,                 % Limpa estado anterior
    assertz(barulho_incomum),      % Adiciona ruído anômalo
    assertz(temperatura_motor(90)), % Temperatura normal (90°C)
    diagnosticar,                  % Executa diagnóstico
    limpar_estado.                 % Limpa para próximo teste

% Casos de teste adicionais para os novos diagnósticos
caso_teste_5_filtro_entupido :-
    write('=== Caso de Teste 5: Filtro de Combustivel Entupido ==='), nl,
    limpar_estado,
    assertz(perda_potencia),
    assertz(falha_partida_frio),
    assertz(rotacao_alta),
    assertz(historico_manutencao(filtro_combustivel, 400)),
    diagnosticar,
    limpar_estado.

caso_teste_6_bomba_combustivel :-
    write('=== Caso de Teste 6: Bomba de Combustivel Defeituosa ==='), nl,
    limpar_estado,
    assertz(falha_ignicao),
    assertz(nivel_combustivel(50)),
    assertz(bateria(12.5)),
    assertz(perda_potencia),
    diagnosticar,
    limpar_estado.

% Predicado para limpar o estado dinâmico antes/depois dos testes
limpar_estado :-
    retractall(bateria(_)),        % Remove fatos da bateria
    retractall(temperatura_motor(_)), % Remove fatos de temperatura
    retractall(nivel_oleo(_)),     % Remove fatos do nível de óleo
    retractall(sensor_oxigenio(_)), % Remove fatos do sensor lambda
    retractall(luz_check_engine),  % Remove fato check engine
    retractall(luz_bateria),       % Remove fato luz bateria
    retractall(falha_ignicao),     % Remove fato falha ignição
    retractall(barulho_incomum),   % Remove fato barulho
    retractall(rotacao_alta),      % Remove fato rotação alta
    retractall(velocidade_veiculo(_)), % Corrigido
    retractall(nivel_combustivel(_)),
    retractall(consumo_combustivel(_)),
    retractall(perda_potencia),    % Novos predicados
    retractall(falha_partida_frio),
    retractall(historico_manutencao(_, _)).

:- initialization(main).           % Inicializa programa com main

main :-
    write('=== Executando varios casos de teste ==='), nl,
    caso_teste_1_partida_inconsistente,     % Teste 1: Bateria fraca
    caso_teste_2_superaquecimento,          % Teste 2: Superaquecimento
    caso_teste_3_motor_engasgado_altas_rotacoes, % Teste 3: Alta rotação
    caso_teste_4_ruidos_ao_acelerar,        % Teste 4: Ruídos no motor
    caso_teste_5_filtro_entupido,           % Teste 5: Filtro entupido
    caso_teste_6_bomba_combustivel,         % Teste 6: Bomba combustível
    halt. 
/*********************************************
 * 7. EXPLICABILIDADE: COMO E POR QUE NAO
 *********************************************/

% O predicado explica/1 fornece justificativas detalhadas para cada causa diagnosticada.
% Ele utiliza os sintomas e leituras atuais dos sensores para relatar por que uma falha foi identificada.

% Justificativa para "bateria_fraca"
explica(bateria_fraca) :-
    falha_ignicao,               % Há falha ao tentar dar partida no motor
    luz_bateria,                 % Luz da bateria acesa indica alerta no sistema elétrico
    bateria(V),                  % Lê a voltagem da bateria
    V < 12,                      % A voltagem está abaixo do mínimo recomendado
    format('Diagnostico: bateria_fraca porque:\n'),
    format('- Falha de ignicao detectada.\n'),
    format('- Luz de bateria acesa.\n'),
    format('- Voltagem de ~1fV < 12V.\n', [V]).

% Justificativa para "alternador_defeituoso"
explica(alternador_defeituoso) :-
    luz_bateria,                 % Luz da bateria acesa durante o funcionamento do motor
    bateria(V),                  % Leitura da voltagem da bateria
    V >= 12,                     % A bateria está carregada, descartando sua falha
    format('Diagnostico: alternador_defeituoso porque:\n'),
    format('- Luz da bateria acesa durante uso.\n'),
    format('- Bateria com ~1fV >= 12V, descartando problema na bateria.\n', [V]).

% Justificativa para "sistema_arrefecimento"
explica(sistema_arrefecimento) :-
    temperatura_motor(T),        % Leitura da temperatura do motor
    T > 100,                     % Temperatura acima do valor seguro
    format('Diagnostico: sistema_arrefecimento porque:\n'),
    format('- Temperatura do motor acima de 100°C: ~1f°C.\n', [T]).

% Justificativa para "baixo_nivel_oleo"
explica(baixo_nivel_oleo) :-
    nivel_oleo(N),               % Lê o nível atual de óleo
    N < 1.0,                     % Verifica se está abaixo do nível mínimo
    format('Diagnostico: baixo_nivel_oleo porque:\n'),
    format('- Nivel de oleo critico: ~1fL < 1.0L.\n', [N]).

% Justificativa para "vela_ignicao_defeituosa"
explica(vela_ignicao_defeituosa) :-
    falha_ignicao,               % Há falha na ignição
    bateria(V),                  % Leitura da voltagem da bateria
    V >= 12,                     % Bateria está boa
    format('Diagnostico: vela_ignicao_defeituosa porque:\n'),
    format('- Falha de ignicao presente.\n'),
    format('- Bateria com ~1fV >= 12V, descartando problema na bateria.\n', [V]).

% Justificativa para "sensor_oxigenio_defeituoso"
explica(sensor_oxigenio_defeituoso) :-
    sensor_oxigenio(Val),        % Leitura do sensor de oxigênio
    (Val < 0.1 ; Val > 0.9),     % Valor fora da faixa ideal (0.1 a 0.9)
    rotacao_alta,                % Problemas surgem em alta rotação
    luz_check_engine,            % Check Engine acesa
    format('Diagnostico: sensor_oxigenio_defeituoso porque:\n'),
    format('- Sensor de oxigenio fora da faixa: ~1f (esperado: 0.1 a 0.9).\n', [Val]),
    format('- Problemas em alta rotacao.\n'),
    format('- Luz de check engine acesa.\n').

% Justificativa para "problema_injecao"
explica(problema_injecao) :-
    rotacao_alta,                % Problemas ocorrem em alta rotação
    luz_check_engine,            % Luz de alerta acesa
    sensor_oxigenio(Val),        % Leitura do sensor está dentro da faixa
    Val >= 0.1,
    Val =< 0.9,
    format('Diagnostico: problema_injecao porque:\n'),
    format('- Sensor de oxigenio dentro da faixa (~1f).\n', [Val]),
    format('- Problemas detectados em alta rotacao com check engine acesa.\n').

% Justificativa para "problema_transmissao"
explica(problema_transmissao) :-
    barulho_incomum,             % Há ruídos no sistema
    rotacao_alta,                % Problemas se manifestam com rotação alta
    \+ luz_check_engine,         % Luz de check engine não está acesa
    format('Diagnostico: problema_transmissao porque:\n'),
    format('- Barulho incomum com rotacao alta e sem check engine acesa.\n').

% Justificativa para "problema_interno_motor"
explica(problema_interno_motor) :-
    barulho_incomum,             % Há ruídos no motor
    \+ luz_check_engine,         % Sem luz de check engine
    temperatura_motor(T),        % Temperatura estável
    T < 100,
    format('Diagnostico: problema_interno_motor porque:\n'),
    format('- Barulho incomum com temperatura normal (~1f°C) e sem luz de check engine.\n', [T]).

% Justificativa para "filtro_combustivel_entupido"
explica(filtro_combustivel_entupido) :-
    perda_potencia,              % Perda de desempenho
    falha_partida_frio,         % Dificuldade de partida a frio
    rotacao_alta,               % Falhas com rotação alta
    historico_manutencao(filtro_combustivel, Dias), % Histórico de manutenção
    Dias > 365,                  % Última troca há mais de um ano
    format('Diagnostico: filtro_combustivel_entupido porque:\n'),
    format('- Perda de potencia e falha na partida a frio.\n'),
    format('- Rotacao alta com filtro de combustivel sem manutencao ha ~w dias.\n', [Dias]).

% Justificativa para "bomba_combustivel_defeituosa"
explica(bomba_combustivel_defeituosa) :-
    falha_ignicao,               % Falha ao tentar dar partida
    nivel_combustivel(N),       % Há combustível suficiente
    N > 20,
    bateria(V),                 % Bateria está boa
    V >= 12,
    perda_potencia,             % Perda de potência identificada
    format('Diagnostico: bomba_combustivel_defeituosa porque:\n'),
    format('- Falha de ignicao mesmo com combustivel (~1f%%) e bateria boa (~1fV).\n', [N, V]),
    format('- Perda de potencia identificada.\n').

% O predicado por_que_nao/1 fornece uma justificativa genérica para causas nao diagnosticadas.
por_que_nao(Causa) :-
    \+ diagnostico(Causa),      % A causa não foi detectada pelo sistema  
    format('A causa ~w nao foi diagnosticada porque uma ou mais condicoes nao foram satisfeitas.\n', [Causa]).  % Encerra o programa
