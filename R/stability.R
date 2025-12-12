
stability_sd_best <- function(res) {
  sd(res$cv_raw[, res$best], na.rm = TRUE)
}


stability_mean_sd <- function(res) {
  mean(apply(res$cv_raw, 2, sd, na.rm = TRUE), na.rm = TRUE)
}
