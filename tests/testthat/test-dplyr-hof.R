context("dplyr-hof")

test_requires("dplyr")

sc <- testthat_spark_connection()
test_tbl <- testthat_tbl(
  name = "hof_test_data",
  data = tibble::tibble(
    x = list(c(1, 2, 3, 4, 5), c(6, 7, 8, 9, 10)),
    y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
    z = c(11, 12)
  )
)

single_col_tbl <- testthat_tbl(
  name = "hof_test_data_single_col",
  data = tibble::tibble(x = list(1:5, 6:10))
)

test_that("'hof_transform' creating a new column", {
  test_requires_version("2.4.0")

  sq <- test_tbl %>%
    hof_transform(dest_col = w, expr = x, func = x %->% (x * x)) %>%
    sdf_collect()

  expect_equivalent(
    sq,
    tibble::tibble(
      x = list(c(1, 2, 3, 4, 5), c(6, 7, 8, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12),
      w = list(c(1, 4, 9, 16, 25), c(36, 49, 64, 81, 100))
    )
  )
})

test_that("'hof_transform' overwriting an existing column", {
  test_requires_version("2.4.0")

  sq <- test_tbl %>%
    hof_transform(dest_col = x, expr = x, func = x %->% (x * x)) %>%
    sdf_collect()

  expect_equivalent(
    sq,
    tibble::tibble(
      x = list(c(1, 4, 9, 16, 25), c(36, 49, 64, 81, 100)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_transform' works with array(...) expression", {
  test_requires_version("2.4.0")

  sq <- test_tbl %>%
    hof_transform(dest_col = z, expr = array(z - 9, z - 8), func = x %->% (x * x)) %>%
    sdf_collect()

  expect_equivalent(
    sq,
    tibble::tibble(
      x = list(c(1, 2, 3, 4, 5), c(6, 7, 8, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = list(c(4, 9), c(9, 16))
    )
  )
})

test_that("'hof_transform' works with formula", {
  test_requires_version("2.4.0")

  sq <- test_tbl %>%
    hof_transform(dest_col = x, expr = x, func = ~ .x * .x) %>%
    sdf_collect()

  expect_equivalent(
    sq,
    tibble::tibble(
      x = list(c(1, 4, 9, 16, 25), c(36, 49, 64, 81, 100)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_transform' works with default args", {
  test_requires_version("2.4.0")

  sq <- single_col_tbl %>%
    hof_transform(~ .x * .x) %>%
    sdf_collect()

  expect_equivalent(
    sq,
    tibble::tibble(
      x = list(c(1, 4, 9, 16, 25), c(36, 49, 64, 81, 100)),
    )
  )
})

test_that("'hof_filter' creating a new column", {
  test_requires_version("2.4.0")

  filtered <- test_tbl %>%
    hof_filter(dest_col = mod_3_is_0_or_1, expr = x, func = x %->% (x %% 3 != 2)) %>%
    sdf_collect()

  expect_equivalent(
    filtered,
    tibble::tibble(
      x = list(c(1, 2, 3, 4, 5), c(6, 7, 8, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12),
      mod_3_is_0_or_1 = list(c(1, 3, 4), c(6, 7, 9, 10))
    )
  )
})

test_that("'hof_filter' overwriting an existing column", {
  test_requires_version("2.4.0")

  filtered <- test_tbl %>%
    hof_filter(dest_col = x, expr = x, func = x %->% (x %% 3 != 2)) %>%
    sdf_collect()

  expect_equivalent(
    filtered,
    tibble::tibble(
      x = list(c(1, 3, 4), c(6, 7, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_filter' works with array(...) expression", {
  test_requires_version("2.4.0")

  filtered <- test_tbl %>%
    hof_filter(dest_col = z, expr = array(8, z - 1, z + 1), func = x %->% (x %% 3 == 2)) %>%
    sdf_collect()

  expect_equivalent(
    filtered,
    tibble::tibble(
      x = list(c(1, 2, 3, 4, 5), c(6, 7, 8, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = list(c(8), c(8, 11))
    )
  )
})

test_that("'hof_filter' works with formula", {
  test_requires_version("2.4.0")

  filtered <- test_tbl %>%
    hof_filter(dest_col = x, expr = x, func = ~ .x %% 3 != 2) %>%
    sdf_collect()

  expect_equivalent(
    filtered,
    tibble::tibble(
      x = list(c(1, 3, 4), c(6, 7, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_filter' works with default args", {
  test_requires_version("2.4.0")

  sq <- single_col_tbl %>%
    hof_filter(~ .x %% 2 == 1) %>%
    sdf_collect()

  expect_equivalent(
    sq,
    tibble::tibble(
      x = list(c(1, 3, 5), c(7, 9)),
    )
  )
})

test_that("'hof_aggregate' creating a new column", {
  test_requires_version("2.4.0")

  agg <- test_tbl %>%
    hof_aggregate(
      dest_col = sum,
      expr = x,
      start = z,
      merge = .(sum_so_far, num) %->% (sum_so_far + num)
    ) %>%
    sdf_collect()

  expect_equivalent(
    agg,
    tibble::tibble(
      x = list(c(1, 2, 3, 4, 5), c(6, 7, 8, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12),
      sum = c(26, 52)
    )
  )
})

test_that("'hof_aggregate' overwriting an existing column", {
  test_requires_version("2.4.0")

  agg <- test_tbl %>%
    hof_aggregate(
      dest_col = x,
      expr = x,
      start = z,
      merge = .(sum_so_far, num) %->% (sum_so_far + num)
    ) %>%
    sdf_collect()

  expect_equivalent(
    agg,
    tibble::tibble(
      x = c(26, 52),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_aggregate' works with array(...) expression", {
  test_requires_version("2.4.0")

  agg <- test_tbl %>%
    hof_aggregate(
      dest_col = sum,
      expr = array(1, 2, z, 3),
      start = z,
      merge = .(sum_so_far, num) %->% (sum_so_far + num)
    ) %>%
    sdf_collect()

  expect_equivalent(
    agg,
    tibble::tibble(
      x = list(c(1, 2, 3, 4, 5), c(6, 7, 8, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12),
      sum = c(28, 30)
    )
  )
})

test_that("'hof_aggregate' applies 'finish' transformation correctly", {
  test_requires_version("2.4.0")

  agg <- test_tbl %>%
    hof_aggregate(
      dest_col = x,
      expr = x,
      start = z,
      merge = .(sum_so_far, num) %->% (sum_so_far + num),
      finish = sum %->% (sum * sum)
    ) %>%
    sdf_collect()

  expect_equivalent(
    agg,
    tibble::tibble(
      x = c(676, 2704),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_aggregate' can apply formula as 'finish' transformation", {
  test_requires_version("2.4.0")

  agg <- test_tbl %>%
    hof_aggregate(
      dest_col = x,
      expr = x,
      start = z,
      merge = ~ .x + .y,
      finish = ~ .x * .x
    ) %>%
    sdf_collect()

  expect_equivalent(
    agg,
    tibble::tibble(
      x = c(676, 2704),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_aggregate' works with formula", {
  test_requires_version("2.4.0")

  agg <- test_tbl %>%
    hof_aggregate(
      dest_col = x,
      expr = x,
      start = z,
      merge = ~ .x + .y
    ) %>%
    sdf_collect()

  expect_equivalent(
    agg,
    tibble::tibble(
      x = c(26, 52),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_aggregate' works with default args", {
  test_requires_version("2.4.0")

  agg <- single_col_tbl %>%
    hof_aggregate("", ~ CONCAT(.y, .x), ~ CONCAT("(", .x, ")")) %>%
    sdf_collect()

  expect_equivalent(
    agg,
    tibble::tibble(x = c("(12345)", "(678910)"))
  )
})

test_that("'hof_exists' creating a new column", {
  test_requires_version("2.4.0")

  res <- test_tbl %>%
    hof_exists(
      dest_col = found,
      expr = x,
      pred = num %->% (num == 5)
    ) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = list(c(1, 2, 3, 4, 5), c(6, 7, 8, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12),
      found = c(TRUE, FALSE)
    )
  )
})

test_that("'hof_exists' overwriting an existing column", {
  test_requires_version("2.4.0")

  res <- test_tbl %>%
    hof_exists(
      dest_col = x,
      expr = x,
      pred = num %->% (num == 5)
    ) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = c(TRUE, FALSE),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_exists' works with array(...) expression", {
  test_requires_version("2.4.0")

  res <- test_tbl %>%
    hof_exists(
      dest_col = x,
      expr = array(10, z, 13, 14),
      pred = num %->% (num == 12)
    ) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = c(FALSE, TRUE),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )

  res <- test_tbl %>%
    hof_exists(
      dest_col = x,
      expr = array(10, z, 13, 14),
      pred = num %->% (num == 10)
    ) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = c(TRUE, TRUE),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )

  res <- test_tbl %>%
    hof_exists(
      dest_col = x,
      expr = array(10, z, 13, 14),
      pred = num %->% (num == 17)
    ) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = c(FALSE, FALSE),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_exists' works with formula", {
  test_requires_version("2.4.0")

  res <- test_tbl %>%
    hof_exists(
      dest_col = x,
      expr = x,
      pred = ~ .x == 5
    ) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = c(TRUE, FALSE),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_exists' works with default args", {
  test_requires_version("2.4.0")

  res <- single_col_tbl %>%
    hof_exists(~ .x == 5) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(x = c(TRUE, FALSE))
  )
})

test_that("'hof_zip_with' creating a new column", {
  test_requires_version("2.4.0")

  res <- test_tbl %>%
    hof_zip_with(
      dest_col = product,
      left = x,
      right = y,
      func = .(x, y) %->% (x * y)
    ) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = list(c(1, 2, 3, 4, 5), c(6, 7, 8, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12),
      product = list(c(1, 8, 6, 32, 25), c(42, 7, 32, 18, 80))
    )
  )
})

test_that("'hof_zip_with' overwriting an existing column", {
  test_requires_version("2.4.0")

  res <- test_tbl %>%
    hof_zip_with(
      dest_col = x,
      left = x,
      right = y,
      func = .(x, y) %->% (x * y)
    ) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = list(c(1, 8, 6, 32, 25), c(42, 7, 32, 18, 80)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_zip_with' works with array(...) expression", {
  test_requires_version("2.4.0")

  res <- test_tbl %>%
    hof_zip_with(
      dest_col = x,
      left = array(3, 1, z, 4),
      right = array(2, z, 5, 17),
      func = .(x, y) %->% (x * y)
    ) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = list(c(6, 11, 55, 68), c(6, 12, 60, 68)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_zip_with' works with formula", {
  test_requires_version("2.4.0")

  res <- test_tbl %>%
    hof_zip_with(
      dest_col = x,
      left = x,
      right = y,
      func = ~ .x * .y
    ) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = list(c(1, 8, 6, 32, 25), c(42, 7, 32, 18, 80)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12)
    )
  )
})

test_that("'hof_zip_with' works with default args", {
  test_requires_version("2.4.0")

  res <- test_tbl %>%
    hof_zip_with(~ .x * .y) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = list(c(1, 2, 3, 4, 5), c(6, 7, 8, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = list(c(1, 8, 6, 32, 25), c(42, 7, 32, 18, 80))
    )
  )
})

test_that("accessing struct field inside lambda expression", {
  test_requires_version("2.4.0")

  res <- test_tbl %>%
    dplyr::mutate(array_of_structs = array(struct(z), named_struct("z", -1))) %>%
    hof_transform(
      dest_col = w,
      expr = array_of_structs,
      func = s %->% (s$z)
    ) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = list(c(1, 2, 3, 4, 5), c(6, 7, 8, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12),
      array_of_structs = list(list(list(z = 11), list(z = -1)), list(list(z = 12), list(z = -1))),
      w = list(c(11, -1), c(12, -1))
    )
  )
})

test_that("accessing struct field inside formula", {
  test_requires_version("2.4.0")

  res <- test_tbl %>%
    dplyr::mutate(array_of_structs = array(struct(z), named_struct("z", -1))) %>%
    hof_transform(
      dest_col = w,
      expr = array_of_structs,
      func = ~ .x$z
    ) %>%
    sdf_collect()

  expect_equivalent(
    res,
    tibble::tibble(
      x = list(c(1, 2, 3, 4, 5), c(6, 7, 8, 9, 10)),
      y = list(c(1, 4, 2, 8, 5), c(7, 1, 4, 2, 8)),
      z = c(11, 12),
      array_of_structs = list(list(list(z = 11), list(z = -1)), list(list(z = 12), list(z = -1))),
      w = list(c(11, -1), c(12, -1))
    )
  )
})
