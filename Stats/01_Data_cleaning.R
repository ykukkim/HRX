# Libraries ----
install.packages("pacman")
pacman::p_load(ggplot2, readr, dplyr,nlme,reshape2,emmeans,ggpubr,lme4,lmerTest,DHARMa,readxl,openxlsx,car, GGally,magrittr,MASS,klaR,psych,varhandle,tidyverse)
rm(list = ls()) # clears the environment - the one with the variables.

# Import data from csv file ----
getwd()
setwd('C:\\Users\\ykuk0\\Desktop\\HRX\\Stats')
Href_gait_full_temp <- read.xlsx("C:\\Users\\ykuk0\\OneDrive - ETH Zurich\\00_Publications\\00_UnderReview\\05_HRX_Young\\Result\\ExcelSheetData\\01_GaitandHMdata_Final_yk.xlsx", sheet = "HreflexData_mean")
Href_gait      <- read.xlsx("C:\\Users\\ykuk0\\OneDrive - ETH Zurich\\00_Publications\\00_UnderReview\\05_HRX_Young\\Result\\ExcelSheetData\\01_GaitandHMdata_Final_yk.xlsx", sheet = "RLGaitData")
Href_gait_full_temp[Href_gait_full_temp == 0] <- NA # Replacing zero with NA as 0 values affects stats
Href_gait[,-(1:4)][Href_gait[,-(1:4)] == 0] <- NA # Replacing zero with NA as 0 values affects stats
Href_gait[,-(1:4)] <- abs(Href_gait[,-(1:4)])

# Stimulus or non_stimulus ----
Href_gait_stim_OFF    <- split(Href_gait,Href_gait$Stimulus)$'0'
Href_gait_stim_ON     <- split(Href_gait,Href_gait$Stimulus)$'1'
Href_gait_stim_ON_LR  <- split(Href_gait_stim_ON,Href_gait_stim_ON$LorR)$L[,-(1:4)] +  split(Href_gait_stim_ON,Href_gait_stim_ON$LorR)$R[,-(1:4)]
Href_gait_full        <- cbind(Href_gait_full_temp[order(Href_gait_full_temp$Subject),],Href_gait_stim_ON_LR/2)

# Outlier Removal ----
Href_gait_full <-filter(Href_gait_full,Href_gait_full$durationGaitCycle_mean < 2)
rm.all.but(c("Href_gait_full"))
cond_order <- c("har40", "har20", "normg", "wei20", "wei40")
Href_gait_full <- Href_gait_full %>% arrange(factor(Condition, levels = cond_order))

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

# Define a function to remove outliers based on the Tukey method ----
remove_outliers <- function(x) {
  qnt <- quantile(x, probs=c(.25, .75), na.rm = TRUE)
  H <- 1.5 * IQR(x, na.rm = TRUE)
  x[x < (qnt[1] - H)] <- NA
  x[x > (qnt[2] + H)] <- NA
  return(x)
}

# Loop through each gait parameter and condition to remove outliers ----

gait_params <- c("H_mean_mV_P_P","H_std", "M_mean_mV_P_P", "M_std", "Hmax_mV_P_P", "Mmax_mV_P_P",
                 "Bemg_mean_mV","Bemg_std",
                 "SWP_Bemg_mean_mV","SWP_Bemg_std","dls_mean", "durationGaitCycle_mean",
                 "stancePhase_mean", "steplength_mean", "stepwidth_mean", "stridelength_mean",
                 "swingPhase_mean", "MoS_medial_mean", "MoS_AP_mean","Bemg_mean_mV", "dls_std", "durationGaitCycle_std",
                 "stancePhase_std", "steplength_std", "stepwidth_std", "stridelength_std",
                 "swingPhase_std", "MoS_medial_std", "MoS_AP_std","H_Bemg_Norm","H_SWPBemg_Norm")


for (param in gait_params) {

  for (cond in c("har40", "har20","normg","wei20","wei40")) {
    # Get the subset of data for the current parameter and condition
    subset <- Href_gait_full[Href_gait_full$Condition == cond, c("Subject", "Condition", param)]
    # Remove outliers using the remove_outliers function
    #subset[[param]] <- remove_outliers(subset[[param]])
    # Replace the original data with the subset including outlier-removed data
    Href_gait_full[Href_gait_full$Condition == cond, c(param)] <- subset[[param]]
  }
}

# Plot ----

# Loop through each gait parameter
for (param in gait_params) {

  # Create a plot for the current gait parameter
  p <- ggplot(data = Href_gait_full, aes(x = Condition, y = log(!!sym(param)), group = Subject)) +
    geom_line(aes(color = Subject)) +
    geom_point(size = 2.5, aes(color = Subject)) +
    stat_summary(fun.y = mean, geom = "point", size = 3, color = "black", shape = 21, fill = "white") +
    stat_summary(fun.y = mean, geom = "line", size = 1, color = "black", linetype = "dashed") +
    labs(x = "Condition", y = paste0("Log(", param, " [mV])"), color = "Subject") +
    theme_classic() + scale_x_discrete(limits = cond_order)

  # Print the plot
  print(p)
  ggsave(filename = paste0(param, ".png"), plot = p, path = "C:\\Users\\ykuk0\\OneDrive - ETH Zurich\\00_Publications\\00_UnderReview\\05_HRX_Young\\Result\\Parametersforeverysubjects")
}

# Create a boxplot of H-reflex and background EMG by condition ----

HvsBemg <- Href_gait_full%>%gather(key="variable", value="value", H_Bemg_Norm, Bemg_mean_mV)
HvsBemg$Condition <- factor(HvsBemg$Condition, levels = cond_order)
ggplot(HvsBemg, aes(x=Condition, y=value, fill=variable)) +
  geom_boxplot(position=position_dodge(width=0.8)) +
  ggtitle("H-Reflex and SWP_Background EMG by Condition") +
  xlab("Condition") +
  ylab("Value") +
  scale_fill_manual(values=c("blue", "red")) +
  theme_bw()

# Create a boxplot of H-reflex and background EMG by condition ----
HvsSWPBemg <- Href_gait_full%>%gather(key="variable", value="value", H_SWPBemg_Norm, Bemg_mean_mV)
HvsSWPBemg$Condition <- factor(HvsSWPBemg$Condition, levels = cond_order)
ggplot(HvsSWPBemg, aes(x=Condition, y=value, fill=variable)) +
  geom_boxplot(position=position_dodge(width=0.8)) +
  ggtitle("H-Reflex and SWP_Background EMG by Condition") +
  xlab("Condition") +
  ylab("Value") +
  scale_fill_manual(values=c("blue", "red")) +
  theme_bw()

# Create a boxplot of H-reflex and background EMG by condition ----
HvsSWPBemg <- Href_gait_full%>%gather(key="variable", value="value", H_SWPBemg_Norm, H_Bemg_Norm)
HvsSWPBemg$Condition <- factor(HvsSWPBemg$Condition, levels = cond_order)
ggplot(HvsSWPBemg, aes(x=Condition, y=value, fill=variable)) +
  geom_boxplot(position=position_dodge(width=0.8)) +
  ggtitle("H-Reflex and SWP_Background EMG by Condition") +
  xlab("Condition") +
  ylab("Value") +
  scale_fill_manual(values=c("blue", "red")) +
  theme_bw()

# Create a boxplot of H-reflex and background EMG by condition ----
HrawvsBemg <- Href_gait_full%>%gather(key="variable", value="value", H_mean_mV_P_P, Bemg_mean_mV)
HrawvsBemg$Condition <- factor(HrawvsBemg$Condition, levels = cond_order)
ggplot(HrawvsBemg, aes(x=Condition, y=value, fill=variable)) +
  geom_boxplot(position=position_dodge(width=0.8)) +
  ggtitle("H-Reflex and SWP_Background EMG by Condition") +
  xlab("Condition") +
  ylab("Value") +
  scale_fill_manual(values=c("blue", "red")) +
  theme_bw()


# Create the scatterplot with a smooth curve ----
ggplot(Href_gait_full, aes(x=H_mean_mV_P_P, y=Bemg_mean_mV)) +
  geom_point() +
  geom_smooth(method="loess", color="red", se=FALSE) +
  ggtitle("Scatterplot of H-Reflex vs SWP_Background EMG with Smooth Curve") +
  xlab("H-Reflex") +
  ylab("Background EMG")
