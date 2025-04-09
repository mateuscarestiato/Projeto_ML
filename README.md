# 📊 Projeto de Machine Learning – AP1

## 👥 Dupla:
- Ian Esteves
- Mateus Padilha

Este projeto foi desenvolvido como parte da Avaliação Parcial da disciplina de Machine Learning. O objetivo é aplicar técnicas estatísticas e modelos básicos de Machine Learning sobre um conjunto de dados real, passando por todas as etapas do fluxo de um projeto de ciência de dados — desde a análise exploratória até a disponibilização dos modelos por meio de uma API REST.

## 🧠 Objetivos

- Aplicar regressão linear simples (predição)
- Aplicar regressão logística (classificação)
- Realizar análise exploratória de dados
- Testar normalidade e correlação entre variáveis
- Construir e avaliar modelos de Machine Learning
- Disponibilizar os modelos por meio de uma API REST

## ⚙️ Etapas Realizadas

1. **Escolha do Dataset**  
   - Selecionamos um dataset público da plataforma Kaggle contendo uma variável numérica contínua e uma categórica binária.
   - Foram consideradas a qualidade, aplicabilidade e diversidade das variáveis.

2. **Pré-processamento & Análise Exploratória**  
   - Tratamento de valores ausentes e inconsistentes  
   - Estatísticas descritivas  
   - Visualizações gráficas (dispersão, distribuição, etc.)

3. **Testes de Normalidade**  
   - Aplicação do teste de Shapiro-Wilk  
   - Discussão sobre a adequação à regressão linear

4. **Coeficiente de Correlação**  
   - Cálculo da correlação (Pearson ou Spearman) entre duas variáveis numéricas  
   - Interpretação de força e direção

5. **Regressão Linear Simples (Predição)**  
   - Treinamento de modelo preditivo  
   - Avaliação com R², MAE e RMSE  
   - Gráfico com linha de regressão

6. **Regressão Logística (Classificação)**  
   - Treinamento com variável binária  
   - Avaliação com matriz de confusão e acurácia

7. **API REST com R**  
   - Endpoint `/predicao`: recebe valor X e retorna Y (modelo de regressão linear)  
   - Endpoint `/classificacao`: recebe valor X e retorna classe prevista (modelo logístico)  
   - Documentação Swagger

## 🚀 Como Executar

1. Clone este repositório:
   ```bash
   git clone https://github.com/mateuscarestiato/Projeto_ML.git

