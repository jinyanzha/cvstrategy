#' Compare four CV strategies and return a summary table
#'
#' @param X Numeric design matrix (n x p), no intercept column.
#' @param y Numeric binary response vector in {0,1}.
#' @param lambda_path Optional numeric vector of lambdas.
#' @param K Number of folds if foldid is NULL.
#' @param foldid Optional integer vector in 1:K.
#' @param seed Random seed used only when foldid is NULL.
#' @param n_lambda_coarse Number of coarse lambdas for adaptive CV.
#' @param n_lambda_fine Number of fine lambdas for adaptive CV.
#' @param threshold Classification threshold for accuracy.
#' @return A data.frame comparing four methods.
#' @export
#'
#' @examples
#' if (requireNamespace("mlbench", quietly = TRUE)) {
#'   data(Sonar, package = "mlbench")
#'   X <- as.matrix(Sonar[, 1:60])
#'   y <- ifelse(Sonar$Class == "M", 1, 0)
#'
#'   tab <- compare_cv_methods(X, y, K = 5, seed = 1)
#'   print(tab)
#' }
compare_cv_methods <- function(
    X, y,
    lambda_path = NULL,
    K = 10,
    foldid = NULL,
    seed = 123,
    n_lambda_coarse = 20,
    n_lambda_fine = 40,
    threshold = 0.5
) {
  # --- checks ---
  if (!is.matrix(X)) X <- as.matrix(X)
  storage.mode(X) <- "double"
  if (!is.numeric(y)) y <- as.numeric(y)
  if (!all(y %in% c(0, 1))) stop("y must be numeric and take values in {0,1}.")
  if (nrow(X) != length(y)) stop("nrow(X) must equal length(y).")

  n <- nrow(X)

  # --- lambda_path ---
  if (is.null(lambda_path)) {
    fit_init <- glmnet::glmnet(X, y, family = "binomial")
    lambda_path <- fit_init$lambda
  }

  # --- foldid ---
  if (is.null(foldid)) {
    set.seed(seed)
    foldid <- sample(rep(seq_len(K), length.out = n))
  } else {
    K <- max(foldid)
  }

  # --- run methods (you already have these functions) ---
  res_list <- list(
    basic    = cv_lambda_basic(X, y, lambda_path, foldid),
    warm     = cv_lambda_warm(X, y, lambda_path, foldid),
    adaptive = cv_lambda_adaptive(X, y, lambda_path, foldid,
                                  n_lambda_coarse = n_lambda_coarse,
                                  n_lambda_fine   = n_lambda_fine),
    official = cv_lambda_official(X, y, lambda_path, foldid)
  )

  # --- helper to extract best lambda consistently ---
  get_best_lambda <- function(res) {
    if (identical(res$method, "official")) {
      return(as.numeric(res$best))   # lambda.min
    } else {
      return(res$lambda[res$best])   # best is index
    }
  }

  # --- build table ---
  out <- data.frame(
    method      = names(res_list),
    best_lambda = NA_real_,
    best_cvm    = NA_real_,
    train_mse   = NA_real_,
    accuracy    = NA_real_,
    auc         = NA_real_,
    stability_sd_best   = NA_real_,
    stability_mean_sd   = NA_real_,
    runtime     = NA_real_,
    stringsAsFactors = FALSE
  )

  for (i in seq_along(res_list)) {
    res <- res_list[[i]]
    if (identical(res$method, "official")) {
      best_idx <- which.min(res$cvm)
    } else {
      best_idx <- res$best
    }
    best_lambda <- get_best_lambda(res)

    fit <- glmnet::glmnet(X, y, lambda = best_lambda, family = "binomial")
    pred_prob <- as.numeric(stats::predict(fit, X, type = "response"))

    out$best_lambda[i] <- best_lambda
    out$best_cvm[i]    <- min(res$cvm, na.rm = TRUE)
    out$train_mse[i]   <- mean((y - pred_prob)^2)
    out$accuracy[i]    <- mean(ifelse(pred_prob > threshold, 1, 0) == y)
    out$auc[i]         <- as.numeric(pROC::auc(y, pred_prob))
    out$stability_sd_best[i] <-
      sd(res$cv_raw[, best_idx], na.rm = TRUE)

    out$stability_mean_sd[i] <-
      mean(apply(res$cv_raw, 2, sd, na.rm = TRUE), na.rm = TRUE)
    out$runtime[i]     <- as.numeric(res$time)

  }

  out
}
