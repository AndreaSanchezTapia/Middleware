#!/usr/bin/env Rscript

# Esse é o script R usado para fazer modelagens com o Model-R usando 2 níveis de
# paralelismo: por algoritmo e por espécie.
#
# Define-se uma função do_alg() que recebe por parâmetro
# * um algortimo
# * uma espécie
# * suas coordenadas
# * demais parâmetros de modelagem
#
# do_alg() é chamada via clusterMap() do pacote parallel. clusterMap() é uma
# versão multivariável de clusterApply() (análoga a mapply() e Map()) e aqui
# itera sobre 3 listas: uma de algortimos, uma de espécies e uma de coordenadas

library(parallel)

devtools::load_all()

cl <- makeCluster(32, type = "MPI", outfile="/tmp/teste.log")

# 1ª parte: preparação dos dados.
#
# É necessário que exista uma lista de algoritmos, uma de espécies e uma de
# coordenadas que juntas representem cada combinação possível desses parâmetros
#
# Pensando nos dados de exemplo do pacote, teremos ao final dessa etapa as
# seguintes listas
#
#        alg                  esp                                  coord
# 1   maxent Abarema langsdorffii  (-40.615 -19.921, 40.729 -20.016 ...)
# 2       rf Abarema langsdorffii  (-40.615 -19.921, 40.729 -20.016 ...)
# 3      svm Abarema langsdorffii  (-40.615 -19.921, 40.729 -20.016 ...)
# 4  BioClim Abarema langsdorffii  (-40.615 -19.921, 40.729 -20.016 ...)
# 5      glm Abarema langsdorffii  (-40.615 -19.921, 40.729 -20.016 ...)
# 6     svm2 Abarema langsdorffii  (-40.615 -19.921, 40.729 -20.016 ...)
# 7   Domain Abarema langsdorffii  (-40.615 -19.921, 40.729 -20.016 ...)
# 8    Mahal Abarema langsdorffii  (-40.615 -19.921, 40.729 -20.016 ...)
# 9   maxent Eugenia florida DC.  (-35.019  -6.379, -34.858  -7.775 ...)
# 10      rf Eugenia florida DC.  (-35.019  -6.379, -34.858  -7.775 ...)
# 11     svm Eugenia florida DC.  (-35.019  -6.379, -34.858  -7.775 ...)
# 12 BioClim Eugenia florida DC.  (-35.019  -6.379, -34.858  -7.775 ...)
# 13     glm Eugenia florida DC.  (-35.019  -6.379, -34.858  -7.775 ...)
# 14    svm2 Eugenia florida DC.  (-35.019  -6.379, -34.858  -7.775 ...)
# 15  Domain Eugenia florida DC.  (-35.019  -6.379, -34.858  -7.775 ...)
# 16   Mahal Eugenia florida DC.  (-35.019  -6.379, -34.858  -7.775 ...)
# 17  maxent Leandra carassana    (-39.331 -15.165, -39.575 -15.382 ...)
# 18      rf Leandra carassana    (-39.331 -15.165, -39.575 -15.382 ...)
# 19     svm Leandra carassana    (-39.331 -15.165, -39.575 -15.382 ...)
# 20 BioClim Leandra carassana    (-39.331 -15.165, -39.575 -15.382 ...)
# 21     glm Leandra carassana    (-39.331 -15.165, -39.575 -15.382 ...)
# 22    svm2 Leandra carassana    (-39.331 -15.165, -39.575 -15.382 ...)
# 23  Domain Leandra carassana    (-39.331 -15.165, -39.575 -15.382 ...)
# 24   Mahal Leandra carassana    (-39.331 -15.165, -39.575 -15.382 ...)
# 25  maxent Ouratea semiserrata  (-40.027 -16.364, -42.482 -20.701 ...)
# 26      rf Ouratea semiserrata  (-40.027 -16.364, -42.482 -20.701 ...)
# 27     svm Ouratea semiserrata  (-40.027 -16.364, -42.482 -20.701 ...)
# 28 BioClim Ouratea semiserrata  (-40.027 -16.364, -42.482 -20.701 ...)
# 29     glm Ouratea semiserrata  (-40.027 -16.364, -42.482 -20.701 ...)
# 30    svm2 Ouratea semiserrata  (-40.027 -16.364, -42.482 -20.701 ...)
# 31  Domain Ouratea semiserrata  (-40.027 -16.364, -42.482 -20.701 ...)
# 32   Mahal Ouratea semiserrata  (-40.027 -16.364, -42.482 -20.701 ...)

algoritmos <- c("maxent", "rf", "svm", "BioClim", "glm", "svm2", "Domain", "Mahal")

especies <- unique(coordenadas$sp)
especies <- especies[order(especies)]

coordenadas_especies <- split(coordenadas, coordenadas$sp)
coordenadas_especies <- lapply(coordenadas_especies, function(x) x[,c('lon', 'lat')])

alg = rep(algoritmos, length(especies))
esp = rep(especies, each = length(algoritmos))
coord = rep(coordenadas_especies, each = length(algoritmos))

# 2ª parte: definição da função do_alg()
#
# A função receberá um algoritmo, uma espécie e uma lista de ocorrências e fará
# a modelagem com esses parâmetros.
#
# Demais parâmetros aceitos pela funções de modelagem do pacote são passados via
# ...

do_alg <- function(alg, esp, coord, ...){
  devtools::load_all()
  switch(alg,
         BioClim = modelr::do_bioclim(esp, coord, ...),
         maxent = modelr::do_maxent(esp, coord, ...),
         rf = modelr::do_randomForest(esp, coord, ...),
         svm = modelr::do_SVM(esp, coord, ...),
         glm = modelr::do_GLM(esp, coord, ...),
         svm2 = modelr::do_SVM2(esp, coord, ...),
         Domain = modelr::do_domain(esp, coord, ...),
         Mahal = modelr::do_mahal(esp, coord, ...))
  paste(alg, esp, coord, Sys.getpid())
}

pai <- Sys.getpid()

# 3ª parte: chamar do_alg() paralelamente sobre as listas construídas na 1ª
# parte
#
# As listas sobre as quais se deseja iterar são passadas por parâmetro logo após
# a função (parâmetro fun). Os parâmetros fixos em todas as chamadas devem ser
# passados via MoreArgs.

out <- clusterMap(cl,
                  fun = do_alg,
                  alg,
                  esp,
                  coord,
                  MoreArgs = list(partitions = 3,
                                  buffer = FALSE,
                                  seed = 512,
                                  predictors = variaveis_preditoras,
                                  models.dir = "/tmp/modelos",
                                  project.model = F,
                                  projections = NULL,
                                  mask = mascara,
                                  n.back = 500))

save.image('modelr2.RData')

stopCluster(cl)
