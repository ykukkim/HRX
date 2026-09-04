# Plotting interaction effect for each parameter
library(emmeans)
library(gridExtra)
library(ggplot2)

ggplot(Href_gait_full, aes(x = H_mean_mV_P_P, y = stancePhase_std, color = Condition)) +
  geom_point() +
  scale_color_manual(values = c("#270181", "coral"))

model <- c("H_gait_model_lme_mean_strideTime_interaction","H_gait_model_lme_mean_stancePhase_interaction",
           "H_gait_model_lme_mean_swingPhase_interaction","H_gait_model_lme_mean_dls_interaction",
           "H_gait_model_lme_mean_strideLength_interaction","H_gait_model_lme_mean_stepWidth_interaction",
           "H_gait_model_lme_mean_stepLength_interaction","H_gait_model_lme_mean_Mos_AP_interaction",
           "H_gait_model_lme_mean_Mos_ML_interaction",

           "H_gait_model_lme_std_strideTime_interaction",
           "H_gait_model_lme_std_stancePhase_interaction","H_gait_model_lme_std_swingPhase_interaction",
           "H_gait_model_lme_std_dls_interaction","H_gait_model_lme_std_strideLength_interaction",
           "H_gait_model_lme_std_stepWidth_interaction","H_gait_model_lme_std_stepLength_interaction",
           "H_gait_model_lme_std_Mos_AP_interaction", "H_gait_model_lme_std_Mos_ML_interaction")

# Create a list to store all the emmip plots
plot_list <- list()
cond_order <- c("har40", "har20", "normg", "wei20", "wei40")

# loop over each gait parameter and create an emmip plot
# generates marginal effects plots for linear models or mixed effects models
# effect of H reflex on the intersted parameter for each level of the condition.
for (param in model) {
  model_obj <- get(param) # retrieve the actual model object

  # Change the order of the factor levels for the Condition variable
  #Href_gait_full$Condition <- factor(Href_gait_full$Condition, levels = cond_order)

  # Create the emmip plot with the desired order
  p <- emmip(model_obj, log(H_mean_mV_P_P) ~ Condition, cov.reduce = range,
             ylim = NULL, xlab = "Condition", ylab = paste("Log(", param, ")"))

  # Print and save the plot
  print(p)
  ggsave(filename = paste0(param, "_interaction_new.png"), plot = p, path = "C:\\Users\\ykuk0\\OneDrive - ETH Zurich\\HRX_MANU\\Result")
}

# Combine all the plots into a single grid
grid.arrange(grobs = plot_list, ncol = 10)
