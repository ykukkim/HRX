# Libraries ----
install.packages("pacman")
pacman::p_load(ggplot2, readr, dplyr,nlme,reshape2,emmeans,ggpubr,lme4,lmerTest,DHARMa,readxl,openxlsx,car, GGally,magrittr,MASS,klaR,psych,varhandle,ggemmeans)
rm(list = ls()) # clears the environment - the one with the variables.

# # Calculating the number of stimuli----
# stimuli_YO <- Href_gait_full %>% count(Condition)
# summary(stimuli_YO)
# View(stimuli_YO)

# Statistical Methods
# 1. Run a linear mixed model - association of outcome measures and predictor
# 2. Run anova on the linear mixed model
# 3. Run emmans with significant predictors

# LME & Posthoc for mean values of Hreflex and Bemg ----
Href_gait_full    <- read.xlsx("C:\\Users\\ykuk0\\OneDrive - ETH Zurich\\00_Publications\\00_UnderReview\\05_HRX_Young\\Result\\ExcelSheetData\\01_GaitandHMdata_Final_yk.xlsx", sheet = "Final_data_for_Stat_analysis")


# Headers modification----
cleanColumnHeaders <- function(myDF){
  myColNames <- colnames(myDF)
  myColNames <- gsub("%","per", myColNames)
  myColNames <- gsub(" ","_", myColNames)
  myColNames <- gsub("[(]","_",myColNames)
  myColNames <- gsub("[)]","",myColNames)
  myColNames <- gsub("-","_", myColNames)
  myColNames <- gsub("\\.","_", myColNames)
  return(myColNames)
}
colnames(Href_gait_full) <- cleanColumnHeaders(Href_gait_full)

# BEmg vs Conditions
Href_model_lme_mean_BEmg_interaction <-lmer(log(Bemg_mean_mV) ~ Condition + (1|Subject),  data=Href_gait_full)
Href_model_lme_mean_BEmg_posthoc_interaction <- emmeans(Href_model_lme_mean_BEmg_interaction, pairwise ~ Condition, adjust = "Tukey")

# H-wave vs conditions
# This model tests whether the relationship between log(H_Bemg_Norm) and Condition is different at different levels of log(Bemg_mean_mV).
#  Specifically, it tests whether the effect of Condition on log(H_Bemg_Norm) is moderated by log(Bemg_mean_mV).
Href_model_lme_mean_Href <- lmer(H_mean_mV_P_P ~ Condition +Bemg_mean_mV+ (1|Subject),  data=Href_gait_full)
Href_model_lme_mean_Href_posthoc <- emmeans(Href_model_lme_mean_Href, pairwise ~ Condition, adjust = "Tukey")

# This model tests whether the average level of log(H_Bemg_Norm) differs between the levels of Condition.
# Run this, if the interaction effect is low and to see the effect of Condition on log(H_Bemg_Norm)
Href_model_lme_mean_Href <- lmer(H_Bemg_Norm ~ Condition + Bemg_mean_mV+ (1|Subject),  data=Href_gait_full)
Href_model_lme_mean_Href_posthoc <- emmeans(Href_model_lme_mean_Href, pairwise ~ Condition, adjust = "Tukey")

# Tabulation LME models for H, Bemg and gait------------------------------------------------
mean_Href_table <- as.data.frame(anova(Href_model_lme_mean_Href))[c('Pr(>F)')]
mean_Bemg_table <- as.data.frame(anova(Href_model_lme_mean_BEmg_interaction))[c('Pr(>F)')]
names(mean_Href_table)[1] <- 'mean_Href'
names(mean_Bemg_table)[1] <- 'mean_BEmg'

mean_Href_table_posthoc <- as.data.frame(summary(Href_model_lme_mean_Href_posthoc$contrasts))[c('p.value')]
mean_Bemg_table_posthoc <- as.data.frame(summary(Href_model_lme_mean_BEmg_posthoc_interaction$contrasts))[c('p.value')]
names(mean_Href_table_posthoc)[1] <- 'mean_Href'
names(mean_Bemg_table_posthoc)[1] <- 'mean_BEmg'


# ------------  NO interaction - An examination of the impact of Conditions on gait parameters across different conditions -------#
# LME & Posthoc for gait + hreflex + BEmg -------
# Duration, stance phase, swing phase, dls,stride length step width, step length, mos_AP, mos_ML
# Mean gait

H_gait_model_lme_mean_strideTime <- lmer(log(durationGaitCycle_mean) ~ Condition + log(H_Bemg_Norm) +  log(Bemg_mean_mV)  +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_strideTime_posthoc <- emmeans(H_gait_model_lme_mean_strideTime, specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_mean_stancePhase <- lmer(log(stancePhase_mean) ~ Condition + log(H_Bemg_Norm) +  log(Bemg_mean_mV)   + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_stancePhase_posthoc <- emmeans(H_gait_model_lme_mean_stancePhase, specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_mean_swingPhase  <- lmer(log(swingPhase_mean) ~ Condition + log(H_Bemg_Norm) +  log(Bemg_mean_mV)  + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_swingPhase_posthoc <- emmeans(H_gait_model_lme_mean_swingPhase, specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_mean_dls <- lmer(log(dls_mean) ~ Condition  + log(H_Bemg_Norm) +  log(Bemg_mean_mV)   + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_dls_posthoc <- emmeans(H_gait_model_lme_mean_dls, specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_mean_strideLength <- lmer(log(stridelength_mean) ~ Condition +log(H_Bemg_Norm)  +  log(Bemg_mean_mV) + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_strideLength_posthoc <- emmeans(H_gait_model_lme_mean_strideLength, specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_mean_stepWidth <- lmer(log(stepwidth_mean) ~ Condition   + log(H_Bemg_Norm)  +  log(Bemg_mean_mV)  + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_stepWidth_posthoc <- emmeans(H_gait_model_lme_mean_stepWidth, specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_mean_stepLength<- lmer(log(steplength_mean) ~ Condition  + log(H_Bemg_Norm)  +  log(Bemg_mean_mV)  + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_stepLength_posthoc <- emmeans(H_gait_model_lme_mean_stepLength, specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_mean_Mos_AP <- lmer(log(MoS_AP_mean) ~ Condition   + log(H_Bemg_Norm) +  log(Bemg_mean_mV)   + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_Mos_AP_posthoc <- emmeans(H_gait_model_lme_mean_Mos_AP, specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_mean_Mos_ML <- lmer(log(MoS_medial_mean) ~ Condition   +log(H_Bemg_Norm) +  log(Bemg_mean_mV)   + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_Mos_ML_posthoc <- emmeans(H_gait_model_lme_mean_Mos_ML, specs = pairwise ~ Condition, adjust = "Tukey")

#STD parameters
H_gait_model_lme_std_strideTime <- lmer(log(durationGaitCycle_std) ~ Condition +log(H_Bemg_Norm) +  log(Bemg_mean_mV)   +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_strideTime_posthoc <- emmeans(H_gait_model_lme_std_strideTime, specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_std_stancePhase <- lmer(log(stancePhase_std) ~ Condition +log(H_Bemg_Norm)  +  log(Bemg_mean_mV) +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_stancePhase_posthoc <- emmeans(H_gait_model_lme_std_stancePhase,  specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_std_swingPhase  <- lmer(log(swingPhase_std) ~ Condition +log(H_Bemg_Norm) +  log(Bemg_mean_mV)  + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_swingPhase_posthoc <- emmeans(H_gait_model_lme_std_swingPhase,  specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_std_dls <- lmer(log(dls_std) ~ Condition +log(H_Bemg_Norm) +  log(Bemg_mean_mV)  +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_dls_posthoc <- emmeans(H_gait_model_lme_std_dls, specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_std_strideLength <- lmer(log(stridelength_std) ~ Condition +log(H_Bemg_Norm) +  log(Bemg_mean_mV)  +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_strideLength_posthoc <- emmeans(H_gait_model_lme_std_strideLength,  specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_std_stepWidth <- lmer(log(stepwidth_std) ~ Condition +log(H_Bemg_Norm) +  log(Bemg_mean_mV) +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_stepWidth_posthoc <- emmeans(H_gait_model_lme_std_stepWidth,  specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_std_stepLength <- lmer(log(steplength_std) ~ Condition +log(H_Bemg_Norm) +  log(Bemg_mean_mV)   +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_stepLength_posthoc <- emmeans(H_gait_model_lme_std_stepLength,  specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_std_Mos_AP <- lmer(log(MoS_AP_std) ~ Condition +log(H_Bemg_Norm) + log(Bemg_mean_mV) + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_Mos_AP_posthoc <- emmeans(H_gait_model_lme_std_Mos_AP,  specs = pairwise ~ Condition, adjust = "Tukey")

H_gait_model_lme_std_Mos_ML <- lmer(log(MoS_medial_std) ~ Condition + log(H_Bemg_Norm) +log(Bemg_mean_mV) + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_Mos_ML_posthoc <- emmeans(H_gait_model_lme_std_Mos_ML,  specs = pairwise ~ Condition, adjust = "Tukey")

# Tabulation of ANOVA models ----
# Duration, stance phase, swing phase, dls,stride length step width, step length, mos_AP, mos_ML
# Gait Cycle
STD_StrT_table   <- as.data.frame(anova(H_gait_model_lme_std_strideTime))[c('Pr(>F)')]
mean_StrT_table  <- as.data.frame(anova(H_gait_model_lme_mean_strideTime))[c('Pr(>F)')]
names(STD_StrT_table)[1]  <- 'STD_StrT'
names(mean_StrT_table)[1] <- 'mean_StrT'

# Stance Phase
STD_Stn_table <- as.data.frame(anova(H_gait_model_lme_std_stancePhase))[c('Pr(>F)')]
mean_Stn_table <- as.data.frame(anova(H_gait_model_lme_mean_stancePhase))[c('Pr(>F)')]
names(STD_Stn_table)[1] <- 'STD_Stn'
names(mean_Stn_table)[1] <- 'mean_Stn'

# Swing Phase
STD_Swp_table  <- as.data.frame(anova(H_gait_model_lme_std_swingPhase))[c('Pr(>F)')]
mean_Swp_table <- as.data.frame(anova(H_gait_model_lme_mean_swingPhase))[c('Pr(>F)')]
names(STD_Swp_table)[1]  <- 'STD_Swp'
names(mean_Swp_table)[1] <- 'mean_Swp'

# Double limb support time
STD_dls_table  <- as.data.frame(anova(H_gait_model_lme_std_dls))[c('Pr(>F)')]
mean_dls_table <- as.data.frame(anova(H_gait_model_lme_mean_dls))[c('Pr(>F)')]
names(STD_dls_table)[1]  <- 'STD_dls'
names(mean_dls_table)[1] <- 'mean_dls'

# Stride Length
STD_StrL_table <- as.data.frame(anova(H_gait_model_lme_std_strideLength))[c('Pr(>F)')]
mean_StrL_table <- as.data.frame(anova(H_gait_model_lme_mean_strideLength))[c('Pr(>F)')]
names(STD_StrL_table)[1] <- 'STD_StrL'
names(mean_StrL_table)[1] <- 'mean_StrL'

# StepWidth
STD_stepwidth_table  <- as.data.frame(anova(H_gait_model_lme_mean_stepWidth))[c('Pr(>F)')]
mean_stepwidth_table <- as.data.frame(anova(H_gait_model_lme_mean_stepWidth))[c('Pr(>F)')]
names(STD_stepwidth_table)[1]  <- 'STD_StepW'
names(mean_stepwidth_table)[1] <- 'mean_StepW'

# StepLength
STD_steplength_table   <- as.data.frame(anova(H_gait_model_lme_std_stepLength))[c('Pr(>F)')]
mean_steplength_table <- as.data.frame(anova(H_gait_model_lme_mean_stepLength))[c('Pr(>F)')]
names(STD_steplength_table)[1]   <- 'STD_StepL'
names(mean_steplength_table)[1] <- 'mean_StepL'

# MosAP
STD_MosAP_table   <- as.data.frame(anova(H_gait_model_lme_std_Mos_AP))[c('Pr(>F)')]
mean_MosAP_table <- as.data.frame(anova(H_gait_model_lme_mean_Mos_AP))[c('Pr(>F)')]
names(STD_MosAP_table)[1]   <- 'STD_MoSAP'
names(mean_MosAP_table)[1] <- 'mean_MoSAP'

# MoSML
STD_MosML_table   <- as.data.frame(anova(H_gait_model_lme_std_Mos_ML))[c('Pr(>F)')]
mean_MosML_table <- as.data.frame(anova(H_gait_model_lme_mean_Mos_ML))[c('Pr(>F)')]
names(STD_MosML_table)[1]   <- 'STD_MoSML'
names(mean_MosML_table)[1] <- 'mean_MoSML'

# Tabulation of posthoc models ----
# Duration, stance phase, swing phase, dls,stride length step width, step length, mos_AP, mos_ML
# Gait Cycle
STD_StrT_table_posthoc   <- as.data.frame(summary(H_gait_model_lme_std_strideTime_posthoc$contrasts))[c('p.value')]
mean_StrT_table_posthoc <- as.data.frame(summary(H_gait_model_lme_mean_strideTime_posthoc$contrasts))[c('p.value')]
names(STD_StrT_table_posthoc)[1]  <- 'STD_StrT'
names(mean_StrT_table_posthoc)[1] <- 'mean_StrT'

# Stance Phase
STD_Stn_table_posthoc   <- as.data.frame(summary(H_gait_model_lme_std_stancePhase_posthoc$contrasts))[c('p.value')]
mean_Stn_table_posthoc <- as.data.frame(summary(H_gait_model_lme_mean_stancePhase_posthoc$contrasts))[c('p.value')]
names(STD_Stn_table_posthoc)[1] <- 'STD_Stn'
names(mean_Stn_table_posthoc)[1] <- 'mean_Stn'

# Swing Phase
STD_Swp_table_posthoc   <- as.data.frame(summary(H_gait_model_lme_std_swingPhase_posthoc$contrasts))[c('p.value')]
mean_Swp_table_posthoc <- as.data.frame(summary(H_gait_model_lme_mean_swingPhase_posthoc$contrasts))[c('p.value')]
names(STD_Swp_table_posthoc)[1]  <- 'STD_Swp'
names(mean_Swp_table_posthoc)[1] <- 'mean_Swp'

# Double limb support time
STD_dls_table_posthoc   <- as.data.frame(summary(H_gait_model_lme_std_dls_posthoc$contrasts))[c('p.value')]
mean_dls_table_posthoc <- as.data.frame(summary(H_gait_model_lme_mean_dls_posthoc$contrasts))[c('p.value')]
names(STD_dls_table_posthoc)[1]  <- 'STD_dls'
names(mean_dls_table_posthoc)[1] <- 'mean_dls'

# Stride Length
STD_StrL_table_posthoc   <- as.data.frame(summary(H_gait_model_lme_std_strideLength_posthoc$contrasts))[c('p.value')]
mean_StrL_table_posthoc <- as.data.frame(summary(H_gait_model_lme_mean_strideLength_posthoc$contrasts))[c('p.value')]
names(STD_StrL_table_posthoc)[1] <- 'STD_StrL'
names(mean_StrL_table_posthoc)[1] <- 'mean_StrL'

# StepWidth
STD_stepwidth_table_posthoc   <- as.data.frame(summary(H_gait_model_lme_std_stepWidth_posthoc$contrasts))[c('p.value')]
mean_stepwidth_table_posthoc <- as.data.frame(summary(H_gait_model_lme_mean_stepWidth_posthoc$contrasts))[c('p.value')]
names(STD_stepwidth_table_posthoc)[1]  <- 'STD_StepW'
names(mean_stepwidth_table_posthoc)[1] <- 'mean_StepW'

# StepLength
STD_steplength_table_posthoc   <- as.data.frame(summary(H_gait_model_lme_std_stepLength_posthoc$contrasts))[c('p.value')]
mean_steplength_table_posthoc <- as.data.frame(summary(H_gait_model_lme_mean_stepLength_posthoc$contrasts))[c('p.value')]
names(STD_steplength_table_posthoc)[1]  <- 'STD_StepL'
names(mean_steplength_table_posthoc)[1] <- 'mean_StepL'

# MosAP
STD_MosAP_table_posthoc   <- as.data.frame(summary(H_gait_model_lme_std_Mos_AP_posthoc$contrasts))[c('p.value')]
mean_MosAP_table_posthoc <- as.data.frame(summary(H_gait_model_lme_mean_Mos_AP_posthoc$contrasts))[c('p.value')]
names(STD_MosAP_table_posthoc)[1]  <- 'STD_MoSAP'
names(mean_MosAP_table_posthoc)[1] <- 'mean_MoSAP'

# MoSML
STD_MosML_table_posthoc   <- as.data.frame(summary(H_gait_model_lme_std_Mos_ML_posthoc$contrasts))[c('p.value')]
mean_MosML_table_posthoc <- as.data.frame(summary(H_gait_model_lme_mean_Mos_ML_posthoc$contrasts))[c('p.value')]
names(STD_MosML_table_posthoc)[1] <- 'STD_MoSML'
names(mean_MosML_table_posthoc)[1] <- 'mean_MoSML'

# Duration, stance phase, swing phase, dls,stride length step width, step length, mos_AP, mos_ML
p_Values_gait_href_std   <- cbind(STD_StrT_table, STD_Stn_table,STD_Swp_table, STD_dls_table, STD_StrL_table, STD_stepwidth_table, STD_steplength_table,STD_MosAP_table, STD_MosML_table)
p_Values_gait_href_mean <- cbind(mean_StrT_table, mean_Stn_table,mean_Swp_table,mean_dls_table, mean_StrL_table,mean_stepwidth_table,mean_steplength_table, mean_MosAP_table, mean_MosML_table)
p_Values_gait_href_all  <- cbind(p_Values_gait_href_std, p_Values_gait_href_mean)

# Duration, stance phase, swing phase, dls,stride length step width, step length, mos_AP, mos_ML
p_Values_gait_href_std_posthoc  <- cbind(STD_StrT_table_posthoc, STD_Stn_table_posthoc,STD_Swp_table_posthoc,STD_dls_table_posthoc,STD_StrL_table_posthoc ,STD_stepwidth_table_posthoc, STD_steplength_table_posthoc, STD_MosAP_table_posthoc, STD_MosML_table_posthoc)
p_Values_gait_href_mean_posthoc <- cbind(mean_StrT_table_posthoc,mean_Stn_table_posthoc,mean_Swp_table_posthoc,mean_dls_table_posthoc,mean_StrL_table_posthoc, mean_stepwidth_table_posthoc, mean_steplength_table_posthoc,mean_MosAP_table_posthoc, mean_MosML_table_posthoc)
p_Values_gait_href_all_Posthoc  <- cbind(p_Values_gait_href_std_posthoc, p_Values_gait_href_mean_posthoc)


# interaction - An examination of the impact of Hreflex on gait parameters across different conditions -------


# LME & Posthoc for gait + hreflex + BEmg -------
# Duration, stance phase, swing phase, dls,stride length step width, step length, mos_AP, mos_ML
# Mean gait

H_gait_model_lme_mean_strideTime_interaction <- lmer(log(durationGaitCycle_mean) ~ Condition +Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm) +  log(Bemg_mean_mV)  +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_strideTime_posthoc_interaction <- emmeans(H_gait_model_lme_mean_strideTime_interaction, specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_mean_stancePhase_interaction <- lmer(log(stancePhase_mean) ~ Condition  +Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm) +  log(Bemg_mean_mV)   + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_stancePhase_posthoc_interaction <- emmeans(H_gait_model_lme_mean_stancePhase_interaction, specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_mean_swingPhase_interaction  <- lmer(log(swingPhase_mean) ~ Condition  +Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm) +  log(Bemg_mean_mV)  + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_swingPhase_posthoc_interaction <- emmeans(H_gait_model_lme_mean_swingPhase_interaction, specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_mean_dls_interaction <- lmer(log(dls_mean) ~ Condition  +Condition*log(H_Bemg_Norm) +log(H_Bemg_Norm) +  log(Bemg_mean_mV)   + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_dls_posthoc_interaction <- emmeans(H_gait_model_lme_mean_dls_interaction, specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_mean_strideLength_interaction <- lmer(log(stridelength_mean) ~ Condition   + Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm)  +  log(Bemg_mean_mV) + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_strideLength_posthoc_interaction <- emmeans(H_gait_model_lme_mean_strideLength_interaction, specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_mean_stepWidth_interaction <- lmer(log(stepwidth_mean) ~ Condition   + Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm)  +  log(Bemg_mean_mV)  + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_stepWidth_posthoc_interaction <- emmeans(H_gait_model_lme_mean_stepWidth_interaction, specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_mean_stepLength_interaction<- lmer(log(steplength_mean) ~ Condition  + Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm)  +  log(Bemg_mean_mV)  + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_stepLength_posthoc_interaction <- emmeans(H_gait_model_lme_mean_stepLength_interaction, specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_mean_Mos_AP_interaction <- lmer(log(MoS_AP_mean) ~ Condition   + Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm) +  log(Bemg_mean_mV)   + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_Mos_AP_posthoc_interaction <- emmeans(H_gait_model_lme_mean_Mos_AP_interaction, specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_mean_Mos_ML_interaction <- lmer(log(MoS_medial_mean) ~ Condition   + Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm) +  log(Bemg_mean_mV)   + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_mean_Mos_ML_posthoc_interaction <- emmeans(H_gait_model_lme_mean_Mos_ML_interaction, specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

#STD parameters
H_gait_model_lme_std_strideTime_interaction <- lmer(log(durationGaitCycle_std) ~ Condition +Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm) +  log(Bemg_mean_mV)   +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_strideTime_posthoc_interaction <- emmeans(H_gait_model_lme_std_strideTime_interaction, specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_std_stancePhase_interaction <- lmer(log(stancePhase_std) ~ Condition +Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm)  +  log(Bemg_mean_mV) +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_stancePhase_posthoc_interaction <- emmeans(H_gait_model_lme_std_stancePhase_interaction,  specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_std_swingPhase_interaction  <- lmer(log(swingPhase_std) ~ Condition +Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm) +  log(Bemg_mean_mV)  + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_swingPhase_posthoc_interaction <- emmeans(H_gait_model_lme_std_swingPhase_interaction,  specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_std_dls_interaction <- lmer(log(dls_std) ~ Condition +Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm) +  log(Bemg_mean_mV)  +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_dls_posthoc_interaction <- emmeans(H_gait_model_lme_std_dls_interaction, specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_std_strideLength_interaction <- lmer(log(stridelength_std) ~ Condition +Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm) +  log(Bemg_mean_mV)  +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_strideLength_posthoc_interaction <- emmeans(H_gait_model_lme_std_strideLength_interaction,  specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_std_stepWidth_interaction <- lmer(log(stepwidth_std) ~ Condition +Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm) +  log(Bemg_mean_mV) +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_stepWidth_posthoc_interaction <- emmeans(H_gait_model_lme_std_stepWidth_interaction,  specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_std_stepLength_interaction <- lmer(log(steplength_std) ~ Condition +Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm) +  log(Bemg_mean_mV)   +  (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_stepLength_posthoc_interaction <- emmeans(H_gait_model_lme_std_stepLength_interaction,  specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_std_Mos_AP_interaction <- lmer(log(MoS_AP_std) ~ Condition   + Condition*log(H_Bemg_Norm)+log(H_Bemg_Norm) +  log(Bemg_mean_mV) + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_Mos_AP_posthoc_interaction <- emmeans(H_gait_model_lme_std_Mos_AP_interaction,  specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")

H_gait_model_lme_std_Mos_ML_interaction <- lmer(log(MoS_medial_std) ~ Condition  + Condition*log(H_Bemg_Norm)+ log(H_Bemg_Norm) +  log(Bemg_mean_mV)  + (1|Subject),  data=Href_gait_full)
H_gait_model_lme_std_Mos_ML_posthoc_interaction <- emmeans(H_gait_model_lme_std_Mos_ML_interaction,  specs = pairwise ~ Condition|log(H_Bemg_Norm), adjust = "Tukey")



# ------------ interaction - An examination of the impact of Hreflex on gait parameters across different conditions -------#
# Tabulation of ANOVA models ----
# Duration, stance phase, swing phase, dls,stride length step width, step length, mos_AP, mos_ML
# Gait Cycle
STD_StrT_table_interaction   <- as.data.frame(anova(H_gait_model_lme_std_strideTime_interaction))[c('Pr(>F)')]
mean_StrT_table_interaction  <- as.data.frame(anova(H_gait_model_lme_mean_strideTime_interaction))[c('Pr(>F)')]
names(STD_StrT_table_interaction)[1]  <- 'STD_StrT'
names(mean_StrT_table_interaction)[1] <- 'mean_StrT'

# Stance Phase
STD_Stn_table_interaction <- as.data.frame(anova(H_gait_model_lme_std_stancePhase_interaction))[c('Pr(>F)')]
mean_Stn_table_interaction <- as.data.frame(anova(H_gait_model_lme_mean_stancePhase_interaction))[c('Pr(>F)')]
names(STD_Stn_table_interaction)[1] <- 'STD_Stn'
names(mean_Stn_table_interaction)[1] <- 'mean_Stn'

# Swing Phase
STD_Swp_table_interaction  <- as.data.frame(anova(H_gait_model_lme_std_swingPhase_interaction))[c('Pr(>F)')]
mean_Swp_table_interaction <- as.data.frame(anova(H_gait_model_lme_mean_swingPhase_interaction))[c('Pr(>F)')]
names(STD_Swp_table_interaction)[1]  <- 'STD_Swp'
names(mean_Swp_table_interaction)[1] <- 'mean_Swp'

# Double limb support time
STD_dls_table_interaction  <- as.data.frame(anova(H_gait_model_lme_std_dls_interaction))[c('Pr(>F)')]
mean_dls_table_interaction <- as.data.frame(anova(H_gait_model_lme_mean_dls_interaction))[c('Pr(>F)')]
names(STD_dls_table_interaction)[1]  <- 'STD_dls'
names(mean_dls_table_interaction)[1] <- 'mean_dls'

# Stride Length
STD_StrL_table_interaction <- as.data.frame(anova(H_gait_model_lme_std_strideLength_interaction))[c('Pr(>F)')]
mean_StrL_table_interaction <- as.data.frame(anova(H_gait_model_lme_mean_strideLength_interaction))[c('Pr(>F)')]
names(STD_StrL_table_interaction)[1] <- 'STD_StrL'
names(mean_StrL_table_interaction)[1] <- 'mean_StrL'

# StepWidth
STD_stepwidth_table_interaction  <- as.data.frame(anova(H_gait_model_lme_mean_stepWidth_interaction))[c('Pr(>F)')]
mean_stepwidth_table_interaction <- as.data.frame(anova(H_gait_model_lme_mean_stepWidth_interaction))[c('Pr(>F)')]
names(STD_stepwidth_table_interaction)[1]  <- 'STD_StepW'
names(mean_stepwidth_table_interaction)[1] <- 'mean_StepW'

# StepLength
STD_steplength_table_interaction   <- as.data.frame(anova(H_gait_model_lme_std_stepLength_interaction))[c('Pr(>F)')]
mean_steplength_table_interaction <- as.data.frame(anova(H_gait_model_lme_mean_stepLength_interaction))[c('Pr(>F)')]
names(STD_steplength_table_interaction)[1]   <- 'STD_StepL'
names(mean_steplength_table_interaction)[1] <- 'mean_StepL'

# MosAP
STD_MosAP_table_interaction   <- as.data.frame(anova(H_gait_model_lme_std_Mos_AP_interaction))[c('Pr(>F)')]
mean_MosAP_table_interaction <- as.data.frame(anova(H_gait_model_lme_mean_Mos_AP_interaction))[c('Pr(>F)')]
names(STD_MosAP_table_interaction)[1]   <- 'STD_MoSAP'
names(mean_MosAP_table_interaction)[1] <- 'mean_MoSAP'

# MoSML
STD_MosML_table_interaction   <- as.data.frame(anova(H_gait_model_lme_std_Mos_ML_interaction))[c('Pr(>F)')]
mean_MosML_table_interaction <- as.data.frame(anova(H_gait_model_lme_mean_Mos_ML_interaction))[c('Pr(>F)')]
names(STD_MosML_table_interaction)[1]   <- 'STD_MoSML'
names(mean_MosML_table_interaction)[1] <- 'mean_MoSML'

# Tabulation of posthoc models ----
# Duration, stance phase, swing phase, dls,stride length step width, step length, mos_AP, mos_ML
# Gait Cycle
STD_StrT_table_posthoc_interaction   <- as.data.frame(summary(H_gait_model_lme_std_strideTime_posthoc_interaction$contrasts))[c('p.value')]
mean_StrT_table_posthoc_interaction <- as.data.frame(summary(H_gait_model_lme_mean_strideTime_posthoc_interaction$contrasts))[c('p.value')]
names(STD_StrT_table_posthoc_interaction)[1]  <- 'STD_StrT'
names(mean_StrT_table_posthoc_interaction)[1] <- 'mean_StrT'

# Stance Phase
STD_Stn_table_posthoc_interaction   <- as.data.frame(summary(H_gait_model_lme_std_stancePhase_posthoc_interaction$contrasts))[c('p.value')]
mean_Stn_table_posthoc_interaction <- as.data.frame(summary(H_gait_model_lme_mean_stancePhase_posthoc_interaction$contrasts))[c('p.value')]
names(STD_Stn_table_posthoc_interaction)[1] <- 'STD_Stn'
names(mean_Stn_table_posthoc_interaction)[1] <- 'mean_Stn'

# Swing Phase
STD_Swp_table_posthoc_interaction   <- as.data.frame(summary(H_gait_model_lme_std_swingPhase_posthoc_interaction$contrasts))[c('p.value')]
mean_Swp_table_posthoc_interaction <- as.data.frame(summary(H_gait_model_lme_mean_swingPhase_posthoc_interaction$contrasts))[c('p.value')]
names(STD_Swp_table_posthoc_interaction)[1]  <- 'STD_Swp'
names(mean_Swp_table_posthoc_interaction)[1] <- 'mean_Swp'

# Double limb support time
STD_dls_table_posthoc_interaction   <- as.data.frame(summary(H_gait_model_lme_std_dls_posthoc_interaction$contrasts))[c('p.value')]
mean_dls_table_posthoc_interaction <- as.data.frame(summary(H_gait_model_lme_mean_dls_posthoc_interaction$contrasts))[c('p.value')]
names(STD_dls_table_posthoc_interaction)[1]  <- 'STD_dls'
names(mean_dls_table_posthoc_interaction)[1] <- 'mean_dls'

# Stride Length
STD_StrL_table_posthoc_interaction   <- as.data.frame(summary(H_gait_model_lme_std_strideLength_posthoc_interaction$contrasts))[c('p.value')]
mean_StrL_table_posthoc_interaction <- as.data.frame(summary(H_gait_model_lme_mean_strideLength_posthoc_interaction$contrasts))[c('p.value')]
names(STD_StrL_table_posthoc_interaction)[1] <- 'STD_StrL'
names(mean_StrL_table_posthoc_interaction)[1] <- 'mean_StrL'

# StepWidth
STD_stepwidth_table_posthoc_interaction   <- as.data.frame(summary(H_gait_model_lme_std_stepWidth_posthoc_interaction$contrasts))[c('p.value')]
mean_stepwidth_table_posthoc_interaction <- as.data.frame(summary(H_gait_model_lme_mean_stepWidth_posthoc_interaction$contrasts))[c('p.value')]
names(STD_stepwidth_table_posthoc_interaction)[1]  <- 'STD_StepW'
names(mean_stepwidth_table_posthoc_interaction)[1] <- 'mean_StepW'

# StepLength
STD_steplength_table_posthoc_interaction   <- as.data.frame(summary(H_gait_model_lme_std_stepLength_posthoc_interaction$contrasts))[c('p.value')]
mean_steplength_table_posthoc_interaction <- as.data.frame(summary(H_gait_model_lme_mean_stepLength_posthoc_interaction$contrasts))[c('p.value')]
names(STD_steplength_table_posthoc_interaction)[1]  <- 'STD_StepL'
names(mean_steplength_table_posthoc_interaction)[1] <- 'mean_StepL'

# MosAP
STD_MosAP_table_posthoc_interaction   <- as.data.frame(summary(H_gait_model_lme_std_Mos_AP_posthoc_interaction$contrasts))[c('p.value')]
mean_MosAP_table_posthoc_interaction <- as.data.frame(summary(H_gait_model_lme_mean_Mos_AP_posthoc_interaction$contrasts))[c('p.value')]
names(STD_MosAP_table_posthoc_interaction)[1]  <- 'STD_MoSAP'
names(mean_MosAP_table_posthoc_interaction)[1] <- 'mean_MoSAP'

# MoSML
STD_MosML_table_posthoc_interaction   <- as.data.frame(summary(H_gait_model_lme_std_Mos_ML_posthoc_interaction$contrasts))[c('p.value')]
mean_MosML_table_posthoc_interaction <- as.data.frame(summary(H_gait_model_lme_mean_Mos_ML_posthoc_interaction$contrasts))[c('p.value')]
names(STD_MosML_table_posthoc_interaction)[1] <- 'STD_MoSML'
names(mean_MosML_table_posthoc_interaction)[1] <- 'mean_MoSML'


p_Values_Href_mean_lme  <- cbind(mean_Href_table, mean_Bemg_table)
p_Values_Href_mean_lme_posthoc  <- cbind(mean_Href_table_posthoc,mean_Bemg_table_posthoc)

# Duration, stance phase, swing phase, dls,stride length step width, step length, mos_AP, mos_ML
p_Values_gait_href_std_interaction   <- cbind(STD_StrT_table_interaction, STD_Stn_table_interaction,STD_Swp_table_interaction, STD_dls_table_interaction, STD_StrL_table_interaction, STD_stepwidth_table_interaction, STD_steplength_table_interaction,STD_MosAP_table_interaction, STD_MosML_table_interaction)
p_Values_gait_href_mean_interaction <- cbind(mean_StrT_table_interaction, mean_Stn_table_interaction,mean_Swp_table_interaction,mean_dls_table_interaction, mean_StrL_table_interaction,mean_stepwidth_table_interaction,mean_steplength_table_interaction, mean_MosAP_table_interaction, mean_MosML_table_interaction)
p_Values_gait_href_all_interaction  <- cbind(p_Values_gait_href_std_interaction, p_Values_gait_href_mean_interaction)

# Duration, stance phase, swing phase, dls,stride length step width, step length, mos_AP, mos_ML
p_Values_gait_href_std_posthoc_interaction  <- cbind(STD_StrT_table_posthoc, STD_Stn_table_posthoc_interaction,STD_Swp_table_posthoc_interaction,STD_dls_table_posthoc_interaction,STD_StrL_table_posthoc_interaction ,STD_stepwidth_table_posthoc_interaction, STD_steplength_table_posthoc_interaction, STD_MosAP_table_posthoc_interaction, STD_MosML_table_posthoc_interaction)
p_Values_gait_href_mean_posthoc_interaction <- cbind(mean_StrT_table_posthoc_interaction,mean_Stn_table_posthoc_interaction,mean_Swp_table_posthoc_interaction,mean_dls_table_posthoc_interaction,mean_StrL_table_posthoc_interaction, mean_stepwidth_table_posthoc_interaction, mean_steplength_table_posthoc_interaction,mean_MosAP_table_posthoc_interaction, mean_MosML_table_posthoc_interaction)
p_Values_gait_href_all_Posthoc_interaction  <- cbind(p_Values_gait_href_std_posthoc_interaction, p_Values_gait_href_mean_posthoc_interaction)

# Writing to excel --------------------------------------------------------
# Final Data

wb <- loadWorkbook("C:\\Users\\ykuk0\\OneDrive - ETH Zurich\\00_Publications\\00_UnderReview\\05_HRX_Young\\Result\\ManuscirptsTable\\pValues_yk_FINAL_withBEmg_NSCorr_YK_3.xlsx")
addWorksheet(wb,"HrefbEMG_Condition")
writeData(wb,"HrefbEMG_Condition",p_Values_Href_mean_lme)

addWorksheet(wb,"HrefbEMG_Condition_Posthoc")
writeData(wb,"HrefbEMG_Condition_Posthoc",p_Values_Href_mean_lme_posthoc)
saveWorkbook(wb,"C:\\Users\\ykuk0\\OneDrive - ETH Zurich\\00_Publications\\00_UnderReview\\05_HRX_Young\\Result\\ManuscirptsTable\\pValues_yk_FINAL_withBEmg_NSCorr_YK_3.xlsx",overwrite = TRUE)

addWorksheet(wb,"ConditionvsGait")
writeData(wb,"ConditionvsGait",p_Values_gait_href_all)
saveWorkbook(wb,"C:\\Users\\ykuk0\\OneDrive - ETH Zurich\\00_Publications\\00_UnderReview\\05_HRX_Young\\Result\\ManuscirptsTable\\pValues_yk_FINAL_withBEmg_NSCorr_YK_3.xlsx",overwrite = TRUE)

addWorksheet(wb,"ConditionvsGait_posthoc")
writeData(wb,"ConditionvsGait_posthoc",p_Values_gait_href_all_Posthoc)
saveWorkbook(wb,"C:\\Users\\ykuk0\\OneDrive - ETH Zurich\\00_Publications\\00_UnderReview\\05_HRX_Young\\Result\\ManuscirptsTable\\pValues_yk_FINAL_withBEmg_NSCorr_YK_3.xlsx",overwrite = TRUE)

addWorksheet(wb,"GaitvsHref_interaction")
writeData(wb,"GaitvsHref_interaction",p_Values_gait_href_all_interaction)
saveWorkbook(wb,"C:\\Users\\ykuk0\\OneDrive - ETH Zurich\\00_Publications\\00_UnderReview\\05_HRX_Young\\Result\\ManuscirptsTable\\pValues_yk_FINAL_withBEmg_NSCorr_YK_3.xlsx",overwrite = TRUE)

addWorksheet(wb,"GaitvsHref_interaction_posthoc")
writeData(wb,"GaitvsHref_interaction_posthoc",p_Values_gait_href_all_Posthoc_interaction)
saveWorkbook(wb,"C:\\Users\\ykuk0\\OneDrive - ETH Zurich\\00_Publications\\00_UnderReview\\05_HRX_Young\\Result\\ManuscirptsTable\\pValues_yk_FINAL_withBEmg_NSCorr_YK_3.xlsx",overwrite = TRUE)
