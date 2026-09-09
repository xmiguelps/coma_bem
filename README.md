# Aplicativo Coma Bem

## Sobre o Projeto

O **Coma Bem** é um diário gastronômico pessoal: o usuário registra os
restaurantes que visitou, o prato que pediu, a nota que deu, a localização e
uma recomendação escrita. Este projeto foi construído como parte da unidade
curricular de Banco de Dados Mobile e foca na estruturação segura e eficiente
de dados.

## Tecnologias Utilizadas

* **Linguagem:** Dart
* **Framework:** Flutter
* **Banco de Dados:** MySQL (modelagem) e SQLite (`sqflite`) na aplicação
* **Padrões de Projeto:** Orientação a Objetos, DAO (Data Access Object)
* **Recursos do aparelho:** câmera e galeria (`image_picker`), GPS
  (`geolocator`)
* **Tipografia:** Playfair Display (em `assets/fonts`, licença OFL)

## Como Executar o Projeto

1. Clone este repositório.
2. Abra o projeto no VS Code.
3. Rode `flutter pub get` para baixar as dependências.
4. Só na primeira vez, e só se for testar no navegador, rode
   `dart run sqflite_common_ffi_web:setup` (isso gera `web/sqflite_sw.js` e
   `web/sqlite3.wasm`, que fazem o SQLite rodar no Chrome).
5. Rode com `flutter run` e escolha o dispositivo:
   * `flutter run -d windows` — janela no computador
   * `flutter run -d chrome` — navegador
   * `flutter run -d emulator-5554` — emulador Android

### Conta para testar

O banco já nasce com 5 usuários cadastrados. Para entrar:

```
e-mail: miguel@comabem.com
senha:  123456
```

Também é possível tocar em **Acessar como visitante** (navega e cadastra sem
conta, e a avaliação fica sem dono) ou em **Criar conta** para gravar um
usuário novo. O link "Esqueci a senha" mostra e preenche a conta de teste.

### Rodando os testes

```
flutter test
```

Os testes cobrem as regras de validação dos modelos (senha mínima, faixa da
nota, formato do e-mail, limites das coordenadas) e o banco de verdade:
criação das tabelas, INSERT nas três tabelas, o SELECT com INNER JOIN, a
restrição CHECK da nota e o DELETE em cascata.

## Telas

| Tela | O que faz |
|---|---|
| **Splash** | Abre o aplicativo mostrando a marca e vai para o login. |
| **Login** | Confere e-mail e senha na tabela `usuario`; tem modo visitante e criação de conta. |
| **Início** | Lista as memórias vindas do INNER JOIN, com busca por texto, filtro por culinária e os números do topo calculados pelo SQLite. |
| **Detalhe** | Mostra tudo que foi gravado do registro, permite reavaliar tocando nas estrelas, editar, compartilhar e excluir. |
| **Cadastro** | Formulário de INSERT (e de UPDATE, quando aberto pelo botão Editar), com foto, GPS e nota. |

Na barra de baixo, apenas a aba **Início** tem tela nesta versão; Mapa,
Ranking e Perfil aparecem no desenho e avisam que ainda não foram feitos.

## Organização das pastas

```
lib/
  main.dart                    aplicativo e tema
  estilo.dart                  cores, fontes e os pedaços de tela reutilizados
  database/
    database_helper.dart       o DAO: tabelas, dados de teste e todo o CRUD
    banco_io.dart              SQLite de Android, iOS e computador
    banco_web.dart             SQLite do navegador (WASM)
  models/                      Usuario, Cliente, Administrador, DonoRestaurante,
                               Restaurante, Prato, Avaliacao e Memoria
  screens/                     as cinco telas
  simulador_terminal.dart      exercícios das atividades anteriores
  teste_heranca.dart
  teste_fluxo.dart
```

O `banco_io.dart` e o `banco_web.dart` existem porque o SQLite é diferente em
cada plataforma e o Dart escolhe o arquivo certo em tempo de compilação, com
um import condicional dentro do `database_helper.dart`. Sem eles o aplicativo
só rodaria no celular.

## Modelagem do Banco de Dados

O banco de dados relacional foi construído respeitando as regras de
normalização (1FN, 2FN e 3FN) para evitar redundância.

As tabelas principais do sistema são:

1. **usuario** – Armazena as informações dos usuários cadastrados.
2. **restaurante** – Contém os dados dos restaurantes, localização e tipo de culinária.
3. **prato** – Armazena os pratos oferecidos por cada restaurante.
4. **avaliacao** – Registra as avaliações realizadas pelos usuários sobre os pratos.

### Relacionamentos

- Um restaurante pode possuir vários pratos.
- Um prato pertence a um único restaurante.
- Um usuário pode realizar várias avaliações.
- Um prato pode receber várias avaliações.

### Restrições Implementadas

- Chave primária (`PRIMARY KEY`) em todas as tabelas.
- Chaves estrangeiras (`FOREIGN KEY`) para manter a integridade referencial,
  com `ON DELETE CASCADE` de restaurante para prato e de prato para avaliação
  (apagar um restaurante apaga o prato e a avaliação dele).
- Restrição `UNIQUE` para impedir e-mails duplicados.
- Restrição `CHECK` garantindo notas entre **1 e 5**.
- `PRAGMA foreign_keys = ON` na abertura da conexão, sem o qual o SQLite
  ignora as chaves estrangeiras.

## Arquitetura e Orientação a Objetos

O sistema foi desenhado utilizando os pilares da Orientação a Objetos:

**Encapsulamento:** Todos os atributos das classes de modelo (como senha do
usuário) são privados (`_`), sendo acessados apenas de forma segura através de
`getters` e `setters` com validação de dados — a senha exige 6 caracteres, a
nota é normalizada para a faixa de 1 a 5 e as coordenadas recusam valores fora
dos limites geográficos.

**Herança:** Criação de perfis especializados (`Cliente`, `Administrador`,
`DonoRestaurante`) que herdam características de uma classe base abstrata
`Usuario`.

**Polimorfismo:** Implementação de menus e permissões dinâmicas. O método
`itensDoMenu()` adapta-se automaticamente dependendo de qual perfil de usuário
está logado no sistema.

**Agregação:** A classe `Memoria` junta em um único objeto o restaurante, o
prato e a avaliação que vêm da consulta com `INNER JOIN`, e é ela que as telas
usam.

## Transações e Regras de Negócio (CRUD)

A classe `DatabaseHelper` centraliza a conexão com o banco de dados físico no
dispositivo móvel. As rotinas implementadas possuem tratamento de erros e
proteção contra injeção de SQL (`SQL Injection`), pois todos os valores vão
como parâmetros (`?`) e nunca concatenados na consulta.

* **Create:** Cadastro de usuários e gravação de uma memória inteira
  (restaurante + prato + avaliação) dentro de uma única **transação**: se
  qualquer comando falhar, nada é gravado.
* **Read:** Listagem com `SELECT` e `INNER JOIN` entre as três tabelas,
  filtrando por tipo de culinária e por termo de busca; os números do topo da
  tela inicial saem de um `SELECT` com `COUNT`, `AVG` e `DISTINCT`.
* **Update:** Alteração da memória inteira pelo botão Editar, e alteração
  rápida só da nota ao tocar nas estrelas da tela de detalhe.
* **Delete:** Exclusão do restaurante, que leva o prato e a avaliação junto
  por causa do `ON DELETE CASCADE`.

## Dados de Teste

Na primeira execução o banco é criado e populado automaticamente com:

- 5 usuários;
- 5 restaurantes;
- 5 pratos;
- 5 avaliações.

As fotos dos restaurantes de teste vêm da internet; sem conexão o aplicativo
mostra um espaço reservado com a cor da marca e o ícone da culinária. As fotos
que o usuário tira ou escolhe são guardadas dentro do próprio banco, em
base64.

---

**Desenvolvido por Miguel Passos**
