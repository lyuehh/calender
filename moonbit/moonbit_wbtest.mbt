// Whitebox tests run within the package scope.
// Use them to validate internal helpers or invariants.
// Keep them focused; public behavior belongs in `_test.mbt`.

///|
test "local date crosses month and year boundaries with time zones" {
  let previous = @env.get_env_var("TZ")
  @env.set_env_var("TZ", "UTC")
  let utc = local_date(0L)
  @env.set_env_var("TZ", "Etc/GMT+12")
  let west = local_date(0L)
  @env.set_env_var("TZ", "Etc/GMT-14")
  let east = local_date(-36000L)
  match previous {
    Some(zone) => @env.set_env_var("TZ", zone)
    None => @env.unset_env_var("TZ")
  }
  assert_eq(utc, (1970, 1, 1))
  assert_eq(west, (1969, 12, 31))
  assert_eq(east, (1970, 1, 1))
}
