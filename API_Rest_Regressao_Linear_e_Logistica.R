#* @apiTitle API de Predição e Classificação

#* Endpoint para predição usando o modelo de regressão linear
#* @param x:numeric Valor de entrada (Funding Amount em milhões de USD)
#* @get /predicao
function(x) {
  # Validar entrada
  if (is.null(x) || !is.numeric(as.numeric(x))) {
    return(list(error = "Por favor, forneça um valor numérico válido para 'x'."))
  }
  
  # Predição com o modelo linear
  x <- as.numeric(x)
  predicao <- predict(modelo, newdata = data.frame(Funding_Amount = x))
  
  # Retornar resultado
  list(
    input = x,
    predicao = round(predicao, 2)
  )
}

#* Endpoint para classificação usando o modelo de regressão logística
#* @param x:numeric Valor de entrada (Funding Amount em milhões de USD)
#* @get /classificacao
function(x) {
  # Validar entrada
  if (is.null(x) || !is.numeric(as.numeric(x))) {
    return(list(error = "Por favor, forneça um valor numérico válido para 'x'."))
  }
  
  # Classificação com o modelo logístico
  x <- as.numeric(x)
  probabilidade <- predict(modelo_log, newdata = data.frame(Funding_Amount = x), type = "response")
  classe_prevista <- ifelse(probabilidade > 0.5, "Lucrativo", "Não Lucrativo")
  
  # Retornar resultado
  list(
    input = x,
    probabilidade = round(probabilidade, 3),
    classe_prevista = classe_prevista
  )
}
