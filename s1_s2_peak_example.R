library(data.table)

library (tidyverse)

library(ggplot2)
#primero que nada cargo las librerias necesarias para algunos de los comandos que usar

theme_set(theme_bw())#####este es el formato de las gràficas

#esta es lìnea es necesaria cambiarla de donde se encuentran los datos 

setwd("F:/EXP_IF_2019/DATOS/TESIS DATOS/PICO 20%_50%")

fi_files = list.files(pattern ="2019", recursive = T)####elige los archivos que tienen el 2019 en un inicio 
#se puede cambiar por 2019 alguna letra o algo que permita seleccionar todos los archivos


if_ratones = lapply (fi_files, function(x) {
  options(stringsAsFactors = F)#no permite que los datos que se extraen se conviertan a factores, por lo que los deja como caracteres.
  if_com = read.table(x, skip=2, na.strings = "NA", fill=TRUE,#se salta algunas líneas del archivo y posteriormente extrae algunos datos  
                      col.names = paste0("V",seq_len(6)))
  
  
  sujeto=as.character(if_com[3,2]) # extraer dato de sujeto
  fecha=as.character(if_com[1,3]) #fecha de la sesion
  group=as.character(if_com[5,2]) #grupo
  
  
  hasta = which(if_com$V1=="L:") - 1 # lo qu hace es saltar lineas para recortarse hasta L
  inicio = which(if_com$V1 == "C:") + 1 #lo qu hace es saltar lineas para recortarse desde la primera línea debajo de la letra C
  if.1 <- slice(if_com, inicio:hasta) #silice lo que realiza es cortar de inicio a hasta
  
  if.1[1]=NULL#quita la primera columna que se forma de lado izquierdo
  
  # Convertir caracteres a valores numericos, ya que son caracteres 
  
  for (c in 1:ncol(if.1)) {
    if.1[ ,c] = as.numeric(if.1[ ,c])
  }
  
  if.1= na.omit(stack(if.1)) #quita los NA generados
  if.1[2]<-NULL #borra la comlumna 2 donde estaban las V1,V2...
  if.1<- data.frame(val=sort(if.1$values)) #aqu? acomoda la columna values en orden..
  if1 = if.1 %>% mutate(sujeto = sujeto,
                        fecha = fecha,
                        group = group) %>%
    separate(val, c("t","evento"), sep="\\.",convert = T) %>% as.data.frame()
  
  return(if1)
  
} 

) %>% bind_rows()


if_ratones$mark <- ifelse(if_ratones$evento == 4 | if_ratones$evento == 41,1,0)#se realiza una marca con un 1 en donde aparecen 
#esos n?meros en la columna de evento.
# cada que mark==1, suma acumulativamente, permitiendo crear identificadores
# para el programa de Pico o IF que este participando. 


if_ratones = if_ratones[order(as.Date(if_ratones$fecha, format="%m/%d/%Y")),]# este comando ayuda a acomodar las sesiones por orden de 
#acuerdo a la fecha. 

setDT(if_ratones)[ ,sesiones := rleid(fecha),by = .(sujeto)]# setDT pone las sesiones de acuerdo a la fecha y el sujeto
#cambiando la fecha por sesion. Este comando evita que se copie de nuevo toda la tabla y asi solo se modifica esa columna.


if_ratones <- if_ratones %>%
  group_by(sujeto,sesiones) %>%
  mutate(ensayos = cumsum(mark)) %>%
  as.data.frame() #aqui primero que nada se agrupa por sujeto y sesiones; y de acuerdo a
#esto se suma donde estan las marcas de los ensayos; en este caso de pico. 


if_ratones = if_ratones %>% 
  group_by(ensayos,sujeto,sesiones) %>%  
  filter (cumsum(evento == 4) !=0) %>% 
  as.data.frame()#aqui primero que nada se agrupa por sujeto, sesiones y ensayos (creado en la l?nea anterior); y de acuerdo a
#esto se suma donde est?n las marcas de los ensayos; en este caso de pico. 


if_ratones <- if_ratones %>%
  group_by(sujeto,sesiones,group,ensayos) %>%
  mutate(periodo = c(0,diff(t)))#aqui primero que nada se agrupa por sujeto, sesiones, grupo y ensayos; 
#lo que aqui realiza es hacer una resta en el tiempo para ver exactamente en que segundo ocurrio y el tiempo ya no esta acumulado,
#esto permite que posteriormente se realice la conversion en segundos de cada uno de los ensayos y poder agruparlos. 

if_ratones <- if_ratones %>%
  group_by(sujeto, group, ensayos,sesiones) %>%
  mutate(r_times = cumsum(periodo)/10) %>%# dividir entre 10 para convertir a segundos
  filter(r_times > 0)#aqui primero que nada se agrupa por sujeto, sesiones, grupo y ensayos; 
#lo que aqu? realiza es dividir el tiempo que se sac? en el apartado anterior en segundos, es por eso que se divide entre 10 
#esto re realiza para posteriormente poder tener el momento del ensayo en el que se dieron las respuestas. 

################################################
#para esto es necesario correr el script FUNCION_low_high_low_ENSAYOS DE PICO
df_all = data.frame()

for(s in unique(if_ratones$sujeto)){#le pido que saque algunos datos de la tabla que realic? en los pasos anteriores 
  for(ses in unique(if_ratones$sesiones)){
    for(gr in unique(if_ratones$group)){
      for(trials in unique(if_ratones$ensayos)){
        rtimes = if_ratones$r_times[if_ratones$sujeto == s & if_ratones$sesiones == ses & if_ratones$group == gr & if_ratones$ensayos == trials]
        #le digo que rtimes se va a sacar de los datos que tengan las caracter?sticas correspondientes 
        df_lhl = low_high_low(rtimes) #en otro archivo le digo que realice y guarde todo lo uqe el script low_high_low
        df_lhl$sujeto = s
        df_lhl$sesiones = ses
        df_lhl$group = gr
        df_lhl$trial = trials
        df_all = bind_rows(df_all,df_lhl)
      }
    }
  }
}


df_all$r3 = ifelse(df_all$r3 == "NaN", 0 ,df_all$r3)#se quitan los NaN generados en la columna r3 y se pone cero

df_all= na.omit(df_all)#quita los Na generados en todo el documento 

write.csv(df_all1, "starts-stops.csv", row.names = F)#escribe el archivo con los datos de los star stop en un cvs

###################a continuación utilicè este scrip solo para mis datos dado que en el grupo no estaban 
#correctos los nombres por lo que tuve que usar estas lìneas para separar los grupos de forma adecuada.
