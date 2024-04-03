library(pacman)
p_load(tidyverse, lavaan, semTools, MplusAutomation, psych, ggplot2, sjlabelled, janitor,
       tidymodels, parsnip, dials, tune, finetune, xgboost, recipes, data.table, doParallel,
       vip, DALEX, modelDown, corrgram, hablar, SHAPforxgboost, ADNIMERGE, vetiver, pins,
       haven, magrittr, mirt, cowplot, patchwork, data.table, winch, broom.mixed, knitr, pander,
       kableExtra, easystats, fastshap, gt, shapviz, vetiver, pins, readxl, tableone, ggbeeswarm)

vfold_repeats <- 1

set.seed(90210)
cr_split <- initial_split(cr_dat_xgb)
cr_train <- training(cr_split)
cr_test <- testing(cr_split)

cr_rec <- recipe(memr ~ ., data = cr_train) %>%
  update_role(rid, cohort, new_role = "ID") %>%
  step_zv(all_predictors()) %>%
  step_corr(all_predictors(), threshold = .9)

prep(cr_rec)

set.seed(42845)
cr_folds <- vfold_cv(cr_train, v = 10, repeats = vfold_repeats)
cr_folds

xgb_spec <- boost_tree(tree_depth = tune(), 
                       learn_rate = tune(), 
                       loss_reduction = tune(), 
                       min_n = tune(), 
                       sample_size = tune(), 
                       mtry = tune(),
                       trees = tune()
) %>% 
  set_engine("xgboost") %>% 
  set_mode("regression")

xgb_wf <- workflow() %>%
  add_model(xgb_spec) %>%
  add_recipe(cr_rec)

bayes_param <- xgb_wf %>%
  extract_parameter_set_dials() %>% 
  update(mtry = finalize(mtry(), cr_train))

cl <- makePSOCKcluster(20)
registerDoParallel(cl)

xgb_rs <- tune_bayes(
  xgb_wf,
  resamples = cr_folds,
  param_info = bayes_param,
  metrics = metric_set(rmse, rsq, ccc),
  control = control_bayes(verbose = TRUE,
                          verbose_iter = TRUE,
                          no_improve = 100,
                          save_pred = TRUE,
                          seed = 1300),
  initial = 8,
  iter = 200
)

stopCluster(cl)
unregister_dopar()