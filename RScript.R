install.packages(c("tidyverse", "GGally", "psych", "scales", "broom", "pROC", "plumber", "dplyr"))
library(tidyverse)
library(psych)
library(GGally)
library(scales)
library(broom)
library(pROC)
library(plumber)
library(dplyr)

# Metadados do dataset
link_dataset <- "https://www.kaggle.com/datasets/samayashar/startup-growth-and-funding-trends/data"
num_registros <- 500
num_variaveis <- 12
variaveis <- c("Industry", "Funding Rounds", "Funding Amount (M USD)",
               "Valuation (M USD)", "Revenue (M USD)", "Employees",
               "Market Share (%)", "Profitable", "Year Founded",
               "Region", "Exit Status")

justificativa <- paste(
  "1. Diversidade de métricas financeiras",
  "2. Atributos categóricos e temporais",
  "3. Relevância prática para modelos preditivos",
  sep = "\n"
)

# Exibição das informações básicas
cat("=== METADADOS DO DATASET ===\n",
    "Link: ", link_dataset, "\n",
    "Registros: ", num_registros, "\n",
    "Variáveis: ", num_variaveis, "\n",
    "Variáveis principais: ", paste(variaveis, collapse = ", "), "\n",
    "Justificativa:\n", justificativa, "\n\n")

# Leitura dos dados
dados <- read_csv("startup_data.csv") %>%
  rename(
    Funding_Amount = `Funding Amount (M USD)`,
    Valuation = `Valuation (M USD)`,
    Revenue = `Revenue (M USD)`,
    Market_Share = `Market Share (%)`,
    Year_Founded = `Year Founded`,
    Exit_Status = `Exit Status`
  )

# Processamento inicial
dados_clean <- dados %>%
  mutate(
    Profitable = as.factor(Profitable),
    Industry = as.factor(Industry),
    Region = as.factor(Region),
    Exit_Status = as.factor(Exit_Status)
  ) %>%
  filter(
    Funding_Amount > 0,
    Valuation > 0,
    Revenue >= 0,
    Employees > 0,
    between(Year_Founded, 1900, 2025)
  )

# Estatísticas descritivas
cat("=== ESTATÍSTICAS DESCRITIVAS ===\n")
dados_clean %>%
  select(Funding_Rounds = `Funding Rounds`, Funding_Amount, Valuation, Revenue, Employees) %>%
  describe() %>%
  print()

# Teste de normalidade
cat("\n=== TESTE DE NORMALIDADE ===\n")
shapiro_test <- shapiro.test(dados_clean$Valuation)
cat("Variável: Valuation\n",
    "W =", round(shapiro_test$statistic, 4), "\n",
    "p-value =", format(shapiro_test$p.value, scientific = TRUE), "\n\n")

# Análise de correlação
cat("=== ANÁLISE DE CORRELAÇÃO ===\n")
cor_spearman <- cor.test(
  dados_clean$Funding_Amount,
  dados_clean$Valuation,
  method = "spearman",
  exact = FALSE
)

cat("Método: Spearman\n",
    "Variáveis: Funding Amount vs Valuation\n",
    "ρ =", round(cor_spearman$estimate, 3), "\n",
    "p-value =", scales::scientific(cor_spearman$p.value), "\n",
    "R² =", round(cor_spearman$estimate^2, 3), "\n",
    "Interpretação: Correlação forte positiva (",
    case_when(
      cor_spearman$estimate >= 0.8 ~ "Muito Forte",
      cor_spearman$estimate >= 0.6 ~ "Forte",
      TRUE ~ "Moderada"
    ), ")\n\n")


# Histograma de Valuation
ggplot(dados_clean, aes(x = Valuation)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30,
                 fill = "steelblue", alpha = 0.7) +
  geom_density(color = "red", linewidth = 1) +
  labs(title = "Distribuição do Valuation",
       subtitle = expression(paste("Shapiro-Wilk: ", italic(p), " = 3.400928e-12")),
       x = "Valuation (US$ Mi)",
       y = "Densidade") +
  theme_minimal()

# Gráfico de correlação
ggplot(dados_clean, aes(x = Funding_Amount, y = Valuation)) +
  geom_point(alpha = 0.6, color = "#2E86C1") +
  geom_smooth(method = "lm", color = "#E74C3C", se = FALSE) +
  scale_x_continuous(labels = dollar) +
  scale_y_continuous(labels = dollar) +
  labs(
    title = "Relação entre Investimento e Valuation",
    subtitle = paste("Correlação de Spearman ρ =", round(cor_spearman$estimate, 3)),
    x = "Valor Captado (US$ milhões)",
    y = "Valuation (US$ milhões)",
    caption = "Fonte: Startup Growth and Funding Trends"
  ) +
  theme_minimal()

dados <- read_csv("startup_data.csv") %>%
  rename(
    Funding_Amount = `Funding Amount (M USD)`,
    Valuation = `Valuation (M USD)`
  ) %>%
  filter(Funding_Amount > 0, Valuation > 0)

# Criação do modelo de regressão linear simples
modelo <- lm(Valuation ~ Funding_Amount, data = dados)

# Resumo do modelo
summary_modelo <- summary(modelo)
cat("=== Resumo do Modelo ===\n")
print(summary_modelo)

# Avaliação do modelo
# Calcular métricas de avaliação
r_squared <- summary_modelo$r.squared
mae <- mean(abs(dados$Valuation - predict(modelo)))
rmse <- sqrt(mean((dados$Valuation - predict(modelo))^2))

cat("\n=== Métricas de Avaliação ===\n")
cat("R²:", round(r_squared, 3), "\n")
cat("MAE:", round(mae, 3), "\n")
cat("RMSE:", round(rmse, 3), "\n")

# Visualização dos resultados
ggplot(dados, aes(x = Funding_Amount, y = Valuation)) +
  geom_point(alpha = 0.6, color = "#2E86C1") +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Funding Amount vs Valuation",
    subtitle = paste("R² =", round(r_squared, 3), "| MAE =", round(mae, 3), "| RMSE =", round(rmse, 3)),
    x = "Funding Amount (M USD)",
    y = "Valuation (M USD)"
  ) +
  theme_minimal()

# Preparação dos dados para classificação 
# Definir variável-alvo (Y) e preditora (X)
dados_class <- dados_clean %>%
  select(Profitable, Funding_Amount, Revenue, Employees) %>%
  drop_na()

# Treinar modelo de regressão logística 
modelo_log <- glm(Profitable ~ Funding_Amount, 
                  family = binomial(link = "logit"), 
                  data = dados_class)

# Resumo do modelo
cat("\n=== RESUMO DO MODELO DE CLASSIFICAÇÃO ===\n")
print(summary(modelo_log))

# Avaliação de performance
# Prever probabilidades
probabilidades <- predict(modelo_log, type = "response")

# Converter probabilidades em classes (threshold = 0.5)
predicoes <- factor(ifelse(probabilidades > 0.5, 1, 0), levels = c(0, 1))

# Matriz de confusão
matriz_confusao <- table(Real = dados_class$Profitable, Predito = predicoes)

# Métrica de performance
acuracia <- sum(diag(matriz_confusao)) / sum(matriz_confusao)

cat("\n=== MÉTRICAS DE PERFORMANCE ===\n")
cat("Acurácia:", round(acuracia, 3), "\n")
cat("Matriz de Confusão:\n")
print(matriz_confusao)

# Visualização da curva ROC
roc_curve <- roc(dados_class$Profitable, probabilidades)
plot(roc_curve, main = "Curva ROC", col = "#2E86C1")
text(0.6, 0.4, paste("AUC =", round(auc(roc_curve), 3)), cex = 1.2)

# Gráfico de decisão
ggplot(dados_class, aes(x = Funding_Amount, y = as.numeric(as.character(Profitable)))) +
  geom_point(alpha = 0.6, color = "#2E86C1") +
  geom_smooth(method = "glm", method.args = list(family = "binomial"), 
              color = "#E74C3C", se = FALSE) +
  scale_x_continuous(labels = dollar) +
  labs(title = "Regressão Logística: Funding Amount vs Profitable",
       subtitle = paste("Acurácia =", round(acuracia, 3)),
       x = "Valor Captado (US$ milhões)",
       y = "Probabilidade de Ser Lucrativo") +
  theme_minimal()

saveRDS(modelo, "modelo_regressao.rds")
saveRDS(modelo_log, "modelo_logistico.rds")

# Carregar os modelos previamente treinados
modelo_regressao <- readRDS("modelo_regressao.rds") 
modelo_logistico <- readRDS("modelo_logistico.rds") 
