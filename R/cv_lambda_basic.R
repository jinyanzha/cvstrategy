cv_lambda_basic <- function(X, y, lambda_path, foldid) {
  K <- max(foldid)
  nlam <- length(lambda_path)
  p <- ncol(X)
  cv_errors <- matrix(NA_real_, nrow = K, ncol = nlam)
  beta_path <- matrix(0, nrow = p, ncol = nlam)
  t0 <- proc.time()[3]
  for (k in 1:K) {
    train <- which(foldid != k)
    test  <- which(foldid == k)
    fit_full <- glmnet::glmnet(X[train, ], y[train],
                       family = "binomial",
                       lambda = lambda_path,
                       standardize = TRUE)
    tmp_beta <- as.matrix(fit_full$beta)
    if (ncol(tmp_beta) < nlam) {
      diff <- nlam - ncol(tmp_beta)
      tmp_beta <- cbind(tmp_beta, matrix(tmp_beta[, ncol(tmp_beta)], p, diff))
    }
    beta_path <- beta_path + tmp_beta
    eta_mat <- stats::predict(fit_full, X[test, ], s = lambda_path, type = "link")
    for (j in seq_along(lambda_path)) {
      cv_errors[k, j] <- binom_dev(y[test], eta_mat[, j])
    }
  }
  t1 <- proc.time()[3]
  beta_path <- beta_path / K
  list(
    method    = "basic",
    lambda    = lambda_path,
    cvm       = colMeans(cv_errors, na.rm = TRUE),
    cvs       = apply(cv_errors, 2, sd, na.rm = TRUE) / sqrt(K),
    best      = which.min(colMeans(cv_errors, na.rm = TRUE)),
    time      = t1 - t0,
    beta_path = beta_path,
    cv_raw    = cv_errors
  )
}
