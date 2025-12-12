# ---- Internal helper: reshape coefficient paths ----

#' Convert coefficient paths to long format
#'
#' @param beta_mat Matrix of coefficients (p x n_lambda)
#' @param lambda Numeric vector of lambda values
#' @return A long-format data.frame
make_coef_df <- function(beta_mat, lambda) {
  beta_t <- t(beta_mat)  # n_lambda x p
  df <- as.data.frame(beta_t)
  df$lambda <- lambda

  tidyr::pivot_longer(
    df,
    cols = -lambda,
    names_to = "variable",
    values_to = "coef"
  )
}

# ---- Single-method coefficient path plot ----

#' Plot coefficient paths along lambda
#'
#' @param df Data frame from `make_coef_df()`
#' @param title Plot title
#' @return A ggplot object
plot_coef_path <- function(df, title) {
  ggplot2::ggplot(
    df,
    ggplot2::aes(
      x = log(.data$lambda),
      y = .data$coef,
      group = .data$variable
    )
  ) +
    ggplot2::geom_line(
      alpha = 0.6,
      color = "steelblue",
      linewidth = 0.7
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = title,
      x = "log(lambda)",
      y = "Coefficient"
    ) +
    ggplot2::theme(legend.position = "none")
}

# ---- Multi-method comparison (exported) ----

#' Compare coefficient paths across CV methods
#'
#' @param res_list Named list of CV results, each with `beta_path` and `lambda`
#' @return A grob object
#' @export
plot_coef_paths_compare <- function(res_list) {

  dfs <- lapply(names(res_list), function(m) {
    r <- res_list[[m]]
    make_coef_df(r$beta_path, r$lambda) |>
      dplyr::mutate(method = m)
  })

  dfs <- dplyr::bind_rows(dfs)

  plots <- lapply(split(dfs, dfs$method), function(df_m) {
    plot_coef_path(df_m, unique(df_m$method))
  })

  gridExtra::grid.arrange(grobs = plots, nrow = 2)
}
