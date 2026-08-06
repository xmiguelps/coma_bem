# Aplicativo Coma Bem

## Sobre o Projeto

O **Coma Bem** é um aplicativo mobile desenvolvido para conectar amantes da culinária a bons restaurantes locais. Este projeto foi construído como parte da unidade curricular de Banco de Dados Mobile e foca na estruturação segura e eficiente de dados.

## Tecnologias Utilizadas

* **Linguagem:** Dart
* **Framework:** Flutter
* **Banco de Dados:** MySQL (modelagem) e SQLite (`sqflite`) na aplicação
* **Padrões de Projeto:** Orientação a Objetos, DAO (Data Access Object)

## Modelagem do Banco de Dados

O banco de dados relacional foi construído respeitando as regras de normalização (1FN, 2FN e 3FN) para evitar redundância.

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
- Chaves estrangeiras (`FOREIGN KEY`) para manter a integridade referencial.
- Restrição `UNIQUE` para impedir e-mails duplicados.
- Restrição `CHECK` garantindo notas entre **1 e 5**.

## Arquitetura e Orientação a Objetos

O sistema foi desenhado utilizando os pilares da Orientação a Objetos:

**Encapsulamento:** Todos os atributos das classes de modelo (como senha do usuário) são privados (`_`), sendo acessados apenas de forma segura através de `getters` e `setters` com validação de dados.

**Herança:** Criação de perfis especializados (`Cliente`, `Administrador`, `DonoRestaurante`) que herdam características de uma classe base abstrata `Usuario`.

**Polimorfismo:** Implementação de menus e permissões dinâmicas. O método `exibirMenu()` adapta-se automaticamente dependendo de qual perfil de usuário está logado no sistema.

## Transações e Regras de Negócio (CRUD)

A classe `DatabaseHelper` centraliza a conexão com o banco de dados físico no dispositivo móvel. As rotinas implementadas possuem tratamento de erros (`try-catch`) e proteção contra injeção de SQL (`SQL Injection`).

* **Create:** Cadastro de usuários, restaurantes, pratos e avaliações utilizando comandos `INSERT`.
* **Read:** Consulta de restaurantes por tipo de culinária e listagem de pratos avaliados através de consultas `SELECT` com `INNER JOIN`.
* **Update:** Alteração da nota e da recomendação de uma avaliação utilizando `UPDATE`.
* **Delete:** Exclusão de avaliações cadastradas utilizando `DELETE`.

## Consultas Implementadas

O banco de dados possui exemplos de consultas para demonstrar seu funcionamento:

- Buscar restaurantes do tipo de culinária **Italiana**.
- Listar pratos com avaliação máxima (5 estrelas).
- Atualizar a nota e recomendação de uma avaliação.
- Excluir uma avaliação do banco de dados.

## Dados de Teste

O script realiza a inserção automática de:

- 5 usuários;
- 5 restaurantes;
- 5 pratos;
- 5 avaliações.

## Como Executar o Projeto

1. Clone este repositório.
2. Abra o projeto no VS Code.
3. Certifique-se de ter um Emulador Android configurado.
4. Execute o comando `flutter pub get` no terminal para baixar as dependências (`sqflite` e `path`).
5. Pressione `F5` ou execute `flutter run` para compilar e testar o aplicativo no emulador.

---

**Desenvolvido por Miguel Passos**