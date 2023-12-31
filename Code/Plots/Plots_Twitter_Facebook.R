Presented below is the data visualization derived from information acquired via the Twitter API and Facebook with web scraping methodologies.

---
title: "Twitter & Facebook Plots"
author: "Pablo Fdez."
date: "`r Sys.Date()`"
output: html_document
---

```{r Library, include=FALSE}

library(ggplot2)
library(readxl)
library(writexl)
library(haven)
library(dplyr)
library(forcats)
library(grid)
library(tidyverse)
library(extrafont)
library(knitr)
library(kableExtra)
library(magick)
library(rstudioapi)
library(rtweet)
library(hrbrthemes)
library(viridis)
library(wordcloud)
library(RColorBrewer)
library(reshape)

```

```{r Upload Dataframes, include=FALSE}

publicaciones_unificadas <- read_excel(path)

cuentas_unificadas <- read_excel(path)

```

```{r Tweets and Post}

cuentas_unificadas %>% 
  group_by(institucion, red_social) %>% 
  mutate(media = mean(publicaciones)) %>%
  mutate(institucion = case_when(institucion == "local" ~ "Adm. local",
                                 institucion == "autonomico" ~ "Adm. autonómica",
                                 institucion == "comunicacion" ~ "Emp. Comunicación",
                                 institucion == "empresas" ~ "Empresa",
                                 institucion == "bancos" ~ "E. Financiera",
                                 institucion == "estatal" ~ "Adm. Gob. estatal",
                                 institucion == "organizaciones empresariales" ~ "Org. empresarial",
                                 institucion == "ong" ~ "Org. social",
                                 institucion == "partidos politicos" ~ "Partido Político",
                                 institucion == "sindicatos" ~ "Sindicato",
                                 institucion == "universidad" ~ "Universidad"),
         red_social = case_when(red_social == "facebook" ~ "Facebook",
                                red_social == "twitter" ~ "Twitter")) %>%
  ggplot(aes(x= institucion, y= media, fill = red_social)) +
  geom_bar(position="dodge", stat="identity") +
  geom_text(aes(label = round(media, 1)), hjust= -0.2, position = position_dodge(width = 0.9), color = "black", size = 3) +
  coord_flip() +
  scale_y_continuous(limits = c(0, 600),
                     breaks = seq(0, 600, by = 100),
                     position = "right")+
  scale_x_discrete(expand = expansion(add = c(0, 0.5))) +
  scale_fill_manual(values = c("#3b5998", "#00acee")) +
  labs(x = NULL, 
       y = NULL,
       title = "Media de Tweets y Post",
       subtitle = "Datos correspondientes a publicaciones entre el 15.08.2022 y el 15.10.2022",
       caption = "Fuente: Datos recogidos desde Twitter y Facebook",
       fill = NULL) +
  theme(plot.title = element_text(face= "bold",
                                  size = 12),
        plot.subtitle = element_text(size = 9),
        plot.caption = element_text(face = "italic",
                                    size = 9),
        legend.position = c(0.9, 0.9),
        legend.background = element_rect(fill="lightblue", 
                                         size=0.5, linetype="solid"))

ggsave(filename, last_plot(), width = 9.02, height = 5.76, dpi = 300)

```

```{r Tweets and Post + Interaction}

plot <- cuentas_unificadas %>%
  group_by(institucion, red_social) %>%
  summarise(publicaciones = mean(publicaciones),
            likes = mean(like_publi),
            compartidos = mean(compartido_publi))%>%
  mutate(institucion = case_when(institucion == "local" ~ "Adm. local",
                                 institucion == "autonomico" ~ "Adm. autonómica",
                                 institucion == "comunicacion" ~ "Emp. Comunicación",
                                 institucion == "empresas" ~ "Empresa",
                                 institucion == "bancos" ~ "E. Financiera",
                                 institucion == "estatal" ~ "Adm. Gob. estatal",
                                 institucion == "organizaciones empresariales" ~ "Org. empresarial",
                                 institucion == "ong" ~ "Org. social",
                                 institucion == "partidos politicos" ~ "Partido Político",
                                 institucion == "sindicatos" ~ "Sindicato",
                                 institucion == "universidad" ~ "Universidad"),
         red_social = case_when(red_social == "facebook" ~ "Facebook",
                                red_social == "twitter" ~ "Twitter"))

plot1 <- plot[, c("institucion", "red_social", "publicaciones")]

plot2 <- plot[, c("institucion", "red_social", "likes", "compartidos")] %>%
  as.data.frame() %>%
  melt(id = c("institucion", "red_social")) %>%
  mutate(variable = case_when((red_social == "Facebook" & variable == "likes") ~ "Likes (Facebook)",
                              (red_social == "Facebook" & variable == "compartidos") ~ "Compartidos (Facebook)",
                              (red_social == "Twitter" & variable == "likes") ~ "Favoritos (Twitter)",
                              (red_social == "Twitter" & variable == "compartidos") ~ "RTweets (Twitter)")) %>%
  drop_na(variable)

ggplot() + 
  geom_bar(data = plot1, aes(x = institucion, y = publicaciones, fill = red_social), position="dodge", stat="identity") +
  scale_fill_manual(values = c("#3b5998", "#00acee")) +
  geom_line(data = plot2, aes(x = institucion, y = value/0.25, group = variable, col = variable), size= 0.8) +
  scale_color_manual(values = c("#E69F00","#CC79A7","#009E73","#F0E442")) +
  scale_y_continuous(limits = c(0, 650),
                     breaks = seq(0, 650, by = 100),
                     name = NULL,
                     sec.axis = sec_axis(trans = ~.*0.25, 
                                         name= NULL,
                                         breaks = seq(0, 163, by = 25)))+
  scale_x_discrete(expand = expansion(add = c(0, 0.5))) +
  labs(x = NULL,
       title = "Media de publicaciones y reacciones al contenido por cada publicación",
       subtitle = "Datos correspondientes a publicaciones entre el 15.08.2022 y el 15.10.2022",
       caption = "Fuente: Datos recogidos desde Twitter y Facebook",
       fill = NULL,
       color= NULL) +
  theme(plot.title = element_text(face= "bold",
                                  size = 12),
        plot.subtitle = element_text(size = 9),
        plot.caption = element_text(face = "italic",
                                    size = 9),
        axis.text.x = element_text(angle = 20,
                                   size = 9))

ggsave(fillname, last_plot(), width = 9.02, height = 5.76, dpi = 300)

```

```{r Boxplot. Followers}

cuentas_unificadas %>%
  drop_na(followers) %>%
  mutate(institucion = case_when(institucion == "local" ~ "Adm. local",
                                 institucion == "autonomico" ~ "Adm. autonómica",
                                 institucion == "comunicacion" ~ "Emp. Comunicación",
                                 institucion == "empresas" ~ "Empresa",
                                 institucion == "bancos" ~ "E. Financiera",
                                 institucion == "estatal" ~ "Adm. Gob. estatal",
                                 institucion == "organizaciones empresariales" ~ "Org. empresarial",
                                 institucion == "ong" ~ "Org. social",
                                 institucion == "partidos politicos" ~ "Partido Político",
                                 institucion == "sindicatos" ~ "Sindicato",
                                 institucion == "universidad" ~ "Universidad"),
         red_social = case_when(red_social == "facebook" ~ "Facebook",
                                red_social == "twitter" ~ "Twitter")) %>%
  ggplot(aes(x= as.factor(institucion), y= followers/1000, colour= red_social)) + 
  geom_boxplot(fill = "#CCFFFF",
               alpha=0.2,
               outlier.colour="red",
               outlier.size=1) +
  scale_y_continuous(limits = c(0, 150),
                     breaks = seq(0, 150, by = 25)) +
  scale_colour_manual(values = c("#3b5998", "#00acee")) +
  labs(x = NULL, 
       y = NULL,
       title = "Followers (en miles) según el tipo de organismo o institución",
       subtitle = "Datos correspondientes al 17.11.2022",
       caption = "Fuente: Datos recogidos desde Twitter y Facebook
       
       Nota: Existen 31 valores atípicos que no aparecen representados en la gráfica por motivo de espacio.",
       colour = NULL,
       mtext = "Hola hola") +
  theme(plot.title = element_text(face= "bold",
                                  size = 12),
        plot.subtitle = element_text(size = 10),
        plot.caption = element_text(face = "italic",
                                    size = 10),
        axis.text.x = element_text(angle = 15,
                                   size = 9)) 

ggsave(fillname, last_plot(), width = 9.02, height = 5.76, dpi = 300)

```

```{r Frequency}

frecuencias <- publicaciones_unificadas %>%
  group_by(cuenta, institucion, red_social, fecha) %>%
  summarise(n = n(), .groups = 'drop')%>%
  group_by(institucion, red_social, fecha) %>%
  mutate(N = sum(n))

n_institucion <- cuentas_unificadas %>%
  group_by(institucion, red_social) %>%
  mutate(n_institucion = length(cuenta)) %>%
  summarise("institucion" = institucion, "n_institucion" = n_institucion, .groups = 'drop') %>%
  distinct()

frecuencias <- merge(frecuencias, n_institucion, all.x = TRUE)

frecuencias %>%
  mutate(institucion = case_when(institucion == "local" ~ "Adm. local",
                                 institucion == "autonomico" ~ "Adm. autonómica",
                                 institucion == "comunicacion" ~ "Emp. Comunicación",
                                 institucion == "empresas" ~ "Empresa",
                                 institucion == "bancos" ~ "E. Financiera",
                                 institucion == "estatal" ~ "Adm. Gob. estatal",
                                 institucion == "organizaciones empresariales" ~ "Org. empresarial",
                                 institucion == "ong" ~ "Org. social",
                                 institucion == "partidos politicos" ~ "Partido Político",
                                 institucion == "sindicatos" ~ "Sindicato",
                                 institucion == "universidad" ~ "Universidad"),
         red_social = case_when(red_social == "facebook" ~ "Facebook",
                                red_social == "twitter" ~ "Twitter")) %>%
  subset(institucion != "E. Financiera") %>%
  ggplot() +
  geom_line(aes(x=fecha, y=N/n_institucion, color=red_social), size=0.6)+
  scale_y_continuous(limits = c(0, 9),
                     breaks = seq(0, 9, by = 2),
                     name = NULL) +
  scale_colour_manual(values = c("#3b5998", "#00acee")) +
  theme_ipsum() +
  labs(x = NULL, 
       y = NULL,
       title = "Frecuencia media de Tweets y Post diarios",
       subtitle = "Datos correspondientes a los días desde el 15.08.2022 al 15.10.2022",
       caption = "Fuente: Datos recogidos desde Twitter y Facebook",
       color = NULL) +
  theme(plot.title = element_text(face= "bold",
                                  size = 12),
        strip.text.x = element_text(face = "italic",
                                    size = 10),
        panel.grid = element_blank(),
        plot.subtitle = element_text(size = 10),
        plot.caption = element_text(face = "italic",
                                    size = 9),
        axis.text.x = element_text(angle = 0,
                                   size = 6),
        axis.text.y = element_text(size= 6),
        legend.title = element_text(face= "bold"),
        legend.position = c(0.6, 0.1)) +
  facet_wrap(~institucion)

ggsave(fillname, last_plot(), width = 9.02, height = 5.76, dpi = 300)

```
