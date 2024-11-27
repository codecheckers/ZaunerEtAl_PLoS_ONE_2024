library(pacman)
packages <- c("quarto", "tidyverse", "broom", "cowplot", "gt", "gtsummary", 
              "gghighlight", "patchwork", "readxl", "lme4", "lmerTest",
              "ggridges", "osfr")

p_load(packages, character.only = TRUE)

load("Nonwear_summary.Rda")
Nonwear_summary %>% 
   gtsummary::tbl_summary(
     statistic = list(NonWear ~"{min} - {max}"),
     label = list(NonWear ~ "Non-Wear Time",
                  valid_Day ~ "Valid Days"),
     by = valid_Day)
