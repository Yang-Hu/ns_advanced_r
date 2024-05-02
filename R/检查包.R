library(rlang)
library(purrr)

required_packages <- c("bench",
                       "bookdown",
                       "dbplyr",
                       "desc",
                       "emo",
                       "ggbeeswarm",
                       "ggplot2",
                       "knitr",
                       "lobstr",
                       "memoise",
                       "png",
                       "profvis",
                       "Rcpp",
                       "rlang",
                       "rmarkdown",
                       "RSQLite",
                       "scales",
                       "sessioninfo",
                       "sloop",
                       "testthat",
                       "tidyr",
                       "vctrs",
                       "zeallot")


results <- map(required_packages, \(.x) {
  
  tryCatch(
    {expr(library(!!.x)) |> eval()},
    
    error = function(x) {
      expr(install.packages(!!.x) |> eval())
    }
  )
  
})


result_df <- tibble(
  package = required_packages,
  result = map_chr(results, \(.x){typeof(.x)})) |> 
  
  filter(result == "language") |> 
  
  pull(package) |> 
  
  str_flatten_comma()




