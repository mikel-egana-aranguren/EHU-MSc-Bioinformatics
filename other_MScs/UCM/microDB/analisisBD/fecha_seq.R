tab <- read.table(file = "SEQfecha.txt",
                  header = FALSE, sep = "\t")

colnames(tab) = c("FECHA","SECUENCIAS","SECUENCIAS TOTALES")

tab
fecha <- tab[,1]
secuencias <- tab[,2]
secuencias_total <- tab[,3]
FECHAS <- fecha[fecha<=2011]
SECUENCIAS <- secuencias[fecha<=2011]
SEQ_TOTAL <- secuencias_total[fecha<=2011]

plot(FECHAS,SEQ_TOTAL)
lines(FECHAS,SEQ_TOTAL, col=3)
lines(FECHAS,SECUENCIAS, col=6)
