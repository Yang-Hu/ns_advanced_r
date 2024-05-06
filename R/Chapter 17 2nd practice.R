library(rlang)
library(lobstr)


# 17.2 Code is data

# expr() lets you capture code that you’ve typed.
expr(mean(x, na.rm = TRUE))

expr(10 + 100 + 1000)


# Use !! to preserve the content:
x <- names(iris)

expr(!!x)



# You need a different tool to capture code passed to a function because expr() doesn’t work:
capture_it <- function(x) {

  expr(x)

}

capture_it(a + b + c)  # This won't work


# This will work, as enexpr() is a function specifically designed to capture user input in a function argument:
capture_it <- function(x) {

  enexpr(x)

}

capture_it(a + b + c)



capture_both <- function(x, y, method) {

  x <- enexpr(x)
  y <- enexpr(y)

  switch(method,

         add      = expr(!!x + !!y),
         subtract = expr(!!x - !!y),
         multiply = expr(!!x * !!y),
         divide   = expr(!!x / !!y)
  )
}


capture_both(x = 1, y = 2, method = "add")
capture_both(x = 1, y = 2, method = "subtract")
capture_both(x = 1, y = 2, method = "multiply")
capture_both(x = 1, y = 2, method = "divide")


# Once you have captured an expression, you can inspect and modify it:
f <- expr(f(x = 1, y = 2))

# Complex expressions behave much like lists. That means you can modify them using [[ and $:
f$z <- 3

f[["h"]] <- "Hello"


code_sample <- expr(sample(x = 1:10, replace = FALSE))

# Add a new argument `size`, with the value 1:
code_sample[["size"]] <- 1

# Test the result:
code_sample |> eval()

# Change the size from 1 to 3:
code_sample[["size"]] <- 3

# Test the result:
code_sample |> eval()


# Code is data, then the results can be altered by changing code:
subject_sample <- function(size, mood) {

  # Dynamic argument value:
  code <- expr(sample(x = 1:10, size = !!size))

  if (mood == "Happy") {

    code[["x"]] <- rep(x = 6, times = 5)
    code[["size"]] <- 5

    # Dynamic new argument based on condition:
    code[["replace"]] <- TRUE

  }

  code

}

# Normal result:
subject_sample(size = 2, mood = "ok"); subject_sample(size = 2, mood = "ok") |> eval()

# Conditional result, note that the arguments for the function are being modified:
subject_sample(size = 2, mood = "Happy"); subject_sample(size = 2, mood = "Happy") |> eval()



# 17.3 Code is a tree (abstract syntax tree 抽象语法树)

ast(1 + 2)

ast(1 + 2 + 3)

ast(1 + 2 + 3 + 4 + 5 + 6 + 7)



# 17.4 Code can generate code; !! (pronounced bang-bang), the unquote operator:

# f(1, 2, 3)

n <- expr(c(1, 2, 3))

expr(f(!!n))

# or

call2(.fn = "f", 1, 2, 3)



# A dynamic function that generate random numbers based on the input, if n is smaller than the size, return normal sample,
# If n is larger than the size, return replaced results:

smart_sample <- function(n) {

  map(seq_len(n), \(.x) {

    code <- expr(sample(x = 1:10))

    code[["size"]] <- .x


    if (.x > 10) {

      code[["replace"]] <- TRUE

    }

    code

  })
}

# Eval each line:
map(smart_sample(n = 15), \(expression) {

  eval(expression)

})



# Example from the book:

xx <- expr(x + x)

yy <- expr(y + y)

expr(!!xx / !!yy)



cv <- function(var) {

  var <- enexpr(var)

  expr(sd(!!var) / mean(!!var))

}

cv(x)

cv(x + y)

cv(c(1, 2, 3))

# Dealing with weird names is another good reason to avoid paste() when generating R code.




# 17.5 Evaluation runs code
x <- y <- 10

eval(expr = expr(x + y))

# envir argument has the top priority over the global environment:
eval(expr = expr(x + y), envir = env(x = 1, y = 1))



# Another attempt to modify the code directly:
always_get_a_result <- function(code) {

  code <- enexpr(code)

  tryCatch(

    # Things to evaluate:
    {eval(code)},

    # If error, then:
    error = function(e) {

      # To temporarily override functions to implement a domain specific language:
      eval(expr = expr(!!code), envir = env(x = 1, y = 2))

    }
  )
}

# To add a data mask so you can refer to variables in a data frame as if they are variables in an environment:
eval(expr = expr(Sepal.Length), envir = env(Sepal.Length = iris$Sepal.Length))



# 17.6
string_math <- function(x) {
  e <- env(
    caller_env(),
    `+` = function(x, y) paste0(x, y),
    `*` = function(x, y) strrep(x, y)
  )

  eval(enexpr(x), e)
}

name <- "Hadley"

string_math("Hello " + name)

string_math(("x" * 2 + "-y") * 3)



# dplyr takes this idea to the extreme, running code in an environment that generates SQL for execution in a remote
# database:
library(dplyr)

con <- DBI::dbConnect(RSQLite::SQLite(), filename = ":memory:")
mtcars_db <- copy_to(con, mtcars)

mtcars_db %>%
  filter(cyl > 2) %>%
  select(mpg:hp) %>%
  head(10) %>%
  show_query()

DBI::dbDisconnect(con)


































