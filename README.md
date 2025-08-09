# DataManager

Este gerenciador de banco de dados foi feito para poder criar, renomear, excluir, fazer backup e restore de bancos de dados postgres.
Não é possível criar, renomear, excluir, ou faz restore de bancos de dados de terceiros, ou seja, com owner diferente de PRODFAB_ADMIN. Porém o backup ainda é possível.
Não é possível criar, renomear, excluir, ou faz restore de bancos de dados em versões de postgres abaixo da 17. Porém o backup ainda é possível.
O proprietário do banco é o PRODFAB_ADMIN, podendo ser trocado no fonte caso queiram usar para suas aplicações personalizadas.
O backup e restore tem barra de progresso fluida.
O backup e restore tem logs em tela e guarda logs na pasta do arquivo do database.
A operação de backup ou restore pode ser cancelada no meio do processo.
