library(readxl)
library(lme4)
library(ggplot2)
library(sjPlot)
library(sjmisc)
library(ggeffects)
library(dplyr)
library(lubridate)
library(ggpubr)
library(performance)
library(DHARMa)
library(tidyverse)
library(MCMCglmm)

TE_data <- read.csv("custom_TE_gen_data_Ch2.csv")

#### Set necessary priors ####
prior_2 = list(R = list(V = diag(1), nu = 0.004),
               G = list(G1 = list(V = diag(1), nu = 2,
                                  alpha.mu = rep(0,1),
                                  alpha.V = diag(25^2,1,1)),
                        G2 = list(V = diag(1), nu = 2,
                                  alpha.mu = rep(0,1),
                                  alpha.V = diag(25^2,1,1)),
                        G3 = list(V = diag(1), nu = 2,
                                  alpha.mu = rep(0,1),
                                  alpha.V = diag(25^2,1,1))))
prior_3 = list(R = list(V = diag(1), nu = 0.004),
               G = list(G1 = list(V = diag(1), nu = 2,
                                  alpha.mu = rep(0,1),
                                  alpha.V = diag(25^2,1,1))))

#### Run parental TE contributions model ####
MCMC_TE_cont <- MCMCglmm(lGCF2 ~ lGCD2+lGCS2+FFlarge + FDlarge + FSlarge + scale(dam_age) + scale(sire_age) + scale(RainWindow) +
                           scale(Dam_RainWindow) + #scale(I(Dam_RainWindow^2))+
                           scale(Sire_RainWindow) + #scale(I(Sire_RainWindow^2))+
                           scale(Dam_RainVar) + #scale(I(Dam_RainVar^2))+
                           scale(Sire_RainVar) + #scale(I(Sire_RainVar^2))+
                           scale(Focal_RainVarBlood) +# scale(I(Focal_RainVarBlood^2))+
                           Sex + helpers_cat + GroupSize, random=~dam+sire+BirthYear,
                         #rcov = ~ us(units),
                         data = TE_data,
                         prior = prior_2,
                         burnin = 100000,
                         nitt = 300000,
                         family = "gaussian",
)

#### Check model diagnostics ####
summary(MCMC_TE_cont)
plot(autocorr(MCMC_TE_cont$VCV))
plot(MCMC_TE_cont$VCV)
plot(MCMC_TE_cont$Sol)
heidel.diag(MCMC_TE_cont$VCV)
geweke.diag(MCMC_TE_cont$VCV)
round(sort(effectiveSize(MCMC_TE_cont$VCV)))

#### Run parental somatic TE accumulation model ####
Mother_model <- MCMCglmm(lGCD2 ~ FDlarge + scale(Dam_RainWindow) + scale(Dam_RainVarBlood) +  
                          FDlarge*scale(Dam_RainVarBlood), random=~Dam_BirthYear,
                        #rcov = ~ us(units),
                        data = TE_data,
                        prior = prior_3,
                        burnin = 100000,
                        nitt = 300000,
                        family = "gaussian")
Father_model <- MCMCglmm(lGCS2 ~ FSlarge + scale(Sire_RainWindow) + scale(Sire_RainVarBlood)
                        , random=~Sire_BirthYear,
                        #rcov = ~ us(units),
                        data = TE_data,
                        prior = prior_3,
                        burnin = 100000,
                        nitt = 300000,
                        family = "gaussian")

#### Run parental TE somatic accumulation model diagnostics ####
plot(autocorr(Mother_model$VCV))
plot(Mother_model$VCV)
plot(Mother_model$Sol)
heidel.diag(Mother_model$VCV)
geweke.diag(Mother_model$VCV)
round(sort(effectiveSize(Mother_model$VCV)))

plot(autocorr(Father_model$VCV))
plot(Father_model$VCV)
plot(Father_model$Sol)
heidel.diag(Father_model$VCV)
geweke.diag(Father_model$VCV)
round(sort(effectiveSize(Father_model$VCV)))

#### Obtain the mode for all posterior distributions ####
MCMC_TE_modes <- posterior.mode(MCMC_TE_cont$Sol)
MCMC_TE_modes_ran <- posterior.mode(MCMC_TE_cont$VCV)

Mom_TE_modes <- posterior.mode(Mother_model$Sol)
Mom_TE_modes_ran <- posterior.mode(Mother_model$VCV)

Dad_TE_modes <- posterior.mode(Father_model$Sol)
Dad_TE_modes_ran <- posterior.mode(Father_model$VCV)

#### Get model predictions using MCMCpredict ####
MCMC_pred_cont <-predict.MCMCglmm(MCMC_TE_cont, newdata = TE_data, type = "terms", interval = "confidence")
dim(MCMC_pred_cont)

MCMC_pred_cont_data <- cbind(TE_data, MCMC_pred_cont)

#### Plot model predictions ####
data <- MCMC_pred_cont_data

# Get ribbons to plot data
ribbons <- data %>%
  nest() %>%
  mutate(
    out = map(data, function(data) {
      
      # Get ribbons
      tibble(
        upr2 = loess(upr ~ lGCD2, data = data)$fitted,
        lwr2 = loess(lwr ~ lGCD2, data = data)$fitted
      )
      
    })
  ) %>%
  unnest(data, out)

# Plot
Mother_plot<- data %>%
  ggplot(aes(x = lGCD2, y = fit)) +
  geom_point(aes(y = lGCF2), alpha = 0.2) +
  geom_point() +
  #geom_segment(aes(y = lwr, yend = upr)) +
  geom_ribbon(data = ribbons, aes(ymin = lwr2, ymax = upr2, y = NULL), alpha = 0.25) +
  geom_smooth(color = "black", se = FALSE, linewidth = 0.6) + theme_bw()+
  labs(x="log of maternal TE genomic content",
       y="Predicted log of offspring TE genomic content")+
  scale_x_continuous(limits = c(-3.75,-2), breaks = seq(-4,-2,0.5))


ribbons2 <- data %>%
  nest() %>%
  mutate(
    out = map(data, function(data) {
      
      # Get ribbons
      tibble(
        upr3 = loess(upr ~ lGCS2, data = data)$fitted,
        lwr3 = loess(lwr ~ lGCS2, data = data)$fitted
      )
      
    })
  ) %>%
  unnest(data, out)

Father_plot<- data %>%
  ggplot(aes(x = lGCS2, y = fit)) +
  geom_point(aes(y = lGCF2), alpha = 0.2) +
  geom_point() +
  #geom_segment(aes(y = lwr, yend = upr)) +
  geom_ribbon(data = ribbons2, aes(ymin = lwr3, ymax = upr3, y = NULL), alpha = 0.25) +
  geom_smooth(color = "black", se = FALSE, linewidth = 0.6)+theme_bw()+
  labs(x="log of paternal TE genomic content",
       y="Predicted log of offspring TE genomic content")+
  scale_x_continuous(limits = c(-3.75,-2.0), breaks = seq(-4,-2.0,0.5))

#### Get somatic model predictions using MCMCpredict ####
MCMC_pred_somatic <-predict.MCMCglmm(Mother_model, newdata = TE_data, type = "terms", interval = "confidence")
dim(MCMC_pred_somatic)

MCMC_pred_somatic_data <- cbind(TE_data, MCMC_pred_somatic)

#### Plot model predictions ####

#Get ranges of maternal inbreeding
break1<- range(MCMC_pred_somatic_data$FDlarge)[1]+(range(MCMC_pred_somatic_data$FDlarge)[2]-range(MCMC_pred_somatic_data$FDlarge)[1])/3
break2<- break1 +(range(MCMC_pred_somatic_data$FDlarge)[2]-range(MCMC_pred_somatic_data$FDlarge)[1])/3
breaks_F<- c(range(MCMC_pred_somatic_data$FDlarge)[1], break1, break2, range(MCMC_pred_somatic_data$FDlarge)[2])
labels_F<- c("Low","Medium","High") 
MCMC_pred_somatic_data$Range_FD <- cut(MCMC_pred_somatic_data$FDlarge, breaks = breaks_F, labels = labels_F, include.lowest = TRUE)

data <- MCMC_pred_somatic_data

ribbons3 <- data %>%
  group_by(Range_FD) %>%
  nest() %>%
  mutate(
    out = map(data, function(data) {
      
      # Get ribbons
      tibble(
        upr3 = loess(upr ~ Dam_RainVarBlood, data = data)$fitted,
        lwr3 = loess(lwr ~ Dam_RainVarBlood, data = data)$fitted
      )
      
    })
  ) %>%
  unnest(data, out)


Inbreeding_plotD<- data %>%
  ggplot(aes(x = Dam_RainVarBlood, y = fit, color=Range_FD)) +
  geom_point(aes(y = lGCD2, color=Range_FD), alpha = 0.2) +
  geom_point() +
  #geom_segment(aes(y = lwr, yend = upr)) +
  geom_ribbon(data = ribbons3, aes(ymin = lwr3, ymax = upr3, y = NULL, fill=Range_FD), alpha = 0.25) +
  geom_smooth(color = "black", se = FALSE, linewidth = 0.6,aes(color=Range_FD)) + theme_bw()+
  labs(x="Lifetime variance in precipitation (mm)",
       y="Predicted log of maternal TE genomic content", fill="Inbreeding level", color="Inbreeding level")+
  facet_grid(~Range_FD)+scale_color_viridis_d()+scale_fill_viridis_d()

library(ggpubr)

TE_cont_plot <- ggarrange(Mother_plot,Father_plot, nrow = 1, labels = c("A","B"))
ggsave("Figure1_parental_GTEC.tiff", TE_cont_plot, dpi = 'retina', height = 14, width = 25, units = "cm")
ggsave("Figure2_Inbreeding_vs_GTEC.tiff", Inbreeding_plotD, dpi = 'retina', height = 16, width = 20, units = "cm")
