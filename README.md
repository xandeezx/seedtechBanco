# seedtechBanco

#  SemenTech - Sistema de Recomendação Agrícola Inteligente

Projeto de Banco de Dados desenvolvido para a disciplina de Banco de Dados - DQL e DTL do curso de Tecnologia em Análise e Desenvolvimento de Sistemas (SenacPE).

## 📖 Sobre o Projeto (Minimundo)

O **SemenTech** é um sistema projetado para auxiliar agricultores na tomada de decisões de plantio através de dados técnicos e ambientais.

O sistema funciona centralizando o cadastro de **Agricultores** e suas respectivas **Áreas** de cultivo geolocalizadas. Para cada área, o sistema monitora:
* **Dados Climáticos:** Leituras de temperatura, umidade e chuvas (integrado com fontes como INMET e NASA).
* **Análises de Solo:** Registros de pH, nutrientes e textura do solo coletados em amostras.

O núcleo do sistema é a inteligência de **Recomendações**. O banco de dados armazena um catálogo de **Sementes** e suas **Condições Ideais** de cultivo (temperatura, umidade e solo preferido). Cruzando os dados da área do agricultor com as necessidades de cada semente, o sistema gera recomendações de plantio (pendentes, aceitas ou recusadas).

Além disso, a plataforma oferece um módulo educacional com **Aulas** (vídeos, PDFs) para capacitação técnica e um sistema de **Feedback**, onde o agricultor avalia se a recomendação gerou sucesso na colheita, retroalimentando a confiança do sistema.

## 📂 Estrutura do Repositório

Este projeto foi organizado em scripts SQL numerados para execução sequencial, garantindo a integridade e dependência dos objetos de banco de dados.

| Arquivo | Descrição | Requisito Atendido |
| Criação do Schema, Tabelas e Relacionamentos (PK/FK). | DDL (Create) |
| Inserção de dados de teste (Mín. 20 registros/tabela). | DML (Insert) |
| 20 Consultas complexas com JOINs para relatórios. | DQL (Select) |
| 10 Views para encapsular relatórios frequentes. | Views |
| 14 Rotinas (Functions e Procedures) de lógica de negócio. | PL/SQL |
| Script para execução e teste das rotinas criadas. | Testes |
| 12 Triggers de Auditoria (Logs de Insert/Update/Delete). | Triggers |
| Script para validação dos gatilhos de auditoria. | Testes |

## 🚀 Como Executar

Para rodar este projeto em seu ambiente local (MySQL Workbench ):

1.  Clone este repositório.
2.  Abra o seu SGBD MySQL.
3.  Execute os scripts **exatamente na ordem numérica** (de 01 a 06).
    * *Nota:* O script `01` apaga o banco `agro_app` se ele já existir e o recria do zero.
4.  Após a execução do script `06_B`, verifique a tabela `auditoria_geral` para confirmar que as triggers funcionaram.

## 🛠️ Tecnologias Utilizadas

* **Modelagem:** MySQL Workbench / DBDesigner / BRmodelo
* **Linguagem:** SQL (DDL, DML, DQL, DTL)

## 📝 Autoria

**Aluno:** Arthur Alexandre, Felipe Diogo, Lucas Araujo Gomes, Hugo Pires, Julio Augusto, Wesley Telles 
**Professor:** Danilo Farias Soares da Silva
**Instituição:** SenacPE - Análise e Desenvolvimento de Sistemas
**Ano:** 2025
