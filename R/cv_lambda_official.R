cv_lambda_official <- function(X, y, lambda_path, foldid) {
  K <- max(foldid)
  t0 <- proc.time()[3]
  fit_cv <- glmnet::cv.glmnet(
    X, y,
    family       = "binomial",
    lambda       = lambda_path,
    foldid       = foldid,
    type.measure = "deviance",
    keep         = TRUE
  )
  t1 <- proc.time()[3]
  nlam <- length(fit_cv$lambda)
  eta_all <- fit_cv$fit.preval
  cv_errors <- matrix(NA_real_, nrow = K, ncol = nlam)
  for (k in 1:K) {
    idx_k <- which(foldid == k)
    for (j in 1:nlam) {
      cv_errors[k, j] <- binom_dev(y[idx_k], eta_all[idx_k, j])
    }
  }
  beta_path <- as.matrix(stats::coef(fit_cv$glmnet.fit))[-1, ]
  list(
    method    = "official",
    lambda    = fit_cv$lambda,
    cvm       = as.numeric(fit_cv$cvm),
    cvs       = as.numeric(fit_cv$cvsd),
    best      = fit_cv$lambda.min,
    time      = t1 - t0,
    beta_path = beta_path,
    cv_raw    = cv_errors
  )
}
