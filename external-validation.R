library(pacman)
p_load(tidyverse, lavaan, semTools, MplusAutomation, psych, ggplot2, sjlabelled, janitor,
       tidymodels, parsnip, dials, tune, finetune, xgboost, recipes, data.table, doParallel,
       vip, DALEX, modelDown, corrgram, hablar, SHAPforxgboost, ADNIMERGE, vetiver, pins,
       haven, magrittr, mirt, cowplot, patchwork, data.table, winch, broom.mixed, knitr, pander,
       kableExtra, easystats, fastshap, gt, shapviz, vetiver, pins, readxl, tableone, ggbeeswarm)

adni_gm_all_mod0 <- lmer(ADNI_EF ~ (male + edu_12.bl + amnart45_st.bl + age_70.bl)*(gm_st.bl*Years.bl + gm_d0) +
                           (1 + Years.bl | RID),
                         data = adni_pred_cr)

adni_gm_all_mod1 <- update(adni_gm_all_mod0, ~ . + predmemr.bl + predmemr.bl:Years.bl)

adni_gm_all_mod2 <- update(adni_gm_all_mod1, ~ . + predmemr.bl:gm_st.bl)

adni_gm_all_mod3 <- update(adni_gm_all_mod2, ~ . + predmemr.bl:gm_d0 + predmemr.bl*Years.bl*gm_st.bl)

adni_gm_all_par_plot <- plot_models(adni_gm_all_mod0, adni_gm_all_mod1, adni_gm_all_mod2, adni_gm_all_mod3,
                                    m.labels = c("Covariates Only", "No Moderation", "Intercept Moderation",
                                                 "Slope Moderation"
                                    ))

adni_wbv_all_par <- compare_parameters(adni_gm_all_mod0, adni_gm_all_mod1, adni_gm_all_mod2, adni_gm_all_mod3, 
                                       column_names = c("Covariates Only", "No Moderation", "Intercept Moderation",
                                                        "Slope Moderation"
                                       ))

adni_wbv_all_anova <- anova(adni_gm_all_mod0, adni_gm_all_mod1, adni_gm_all_mod2, adni_gm_all_mod3
) %>%
  data.frame() %>%
  rename(p = `Pr..Chisq.`) %>%
  set_rownames(c("Covariates Only", "No Moderation", "Intercept Moderation",
                 "Slope Moderation"
  ))