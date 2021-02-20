# low1_s1_high_s2_low2.r
# Church two step breakpoint algorithm, from Church et al, 1994.
# Author: Emmanuel Alcala
# Date: 5 may 2019
#
# ------------------------------------------------------------------------------ #
#   Description: ----
# This is an improved version of lhl_old. It is just marginally faster, but
# cleaner and more intuitive. It sets first all possible combinations of s1
# and s2 (start and stop), then it computes the differences between the overall
# rate r and the state rates r1, r2 and r3, weighted by their respective
# durations t1, t2 and t3. Then it computes the index (i.e., an integer of the
# position in the vector) at which the differences were maximized, with which
# all other metrics can be solved.
# ------------------------------------------------------------------------------ #
# inputs: two arguments
#        - r_times: every time at which there was a response
#        - trial_duration: the duration of peak trial
#
# output: a data frame with start, stop, spread, peak time and the response
#         rates r1, r2 and r3.
#
# ------------------------------------------------------------------------------ #

low1_s1_high_s2_low2 <- function(r_times, trial_duration) {
  # Number of responses
  nr <- length(r_times)
  # overall response rate
  r <- nr / trial_duration
  # Vector of putative starts (all the times of responses except the last)
  s1 <- r_times[1:(nr - 1)]
  # Vector of putative stops (except the first)
  s2 <- r_times[2:nr]

  # Get all combinations of s1 and s2 with s1 less than s2.
  #   For example, if s1 can be 1, 2, 3, and s2 = 2, 3, 4,
  #   the combinations are (1, 2), (1, 3), (1, 4), (2, 3), (2, 4), (3, 4)
  #   for (start,stop).
  grid <- expand.grid(s1, s2) # matrix of nx2; n = all possible combinations
  grid <- grid[grid[, 1] < grid[, 2], ] # select n with s1 < s2
  # Vector of 0 to store results
  A <- numeric(nrow(grid))

  # Computations of differences between the r and r_i, with i = 1, 2, 3
  # which are the rates at the low, high and low states.

  # Store the results of the differences in A[j], where j is every combination
  # of s1 and s2 (start and stop)
  for (j in 1:nrow(grid)) { # loop trough all combinations of s1 & s2

    # Note: beware that t1 is equal to s1, but t2 is not equal to s2; while
    # t2 is tue duration of a state (an interval since start of r2), s2 is the
    # time since the beggining of the trial. To obtain t2 we must take
    # the difference between s2 and s1, and for t3, the difference between
    # trial duration and s3.
    # This diagram explains it:
    # 0----s1------s2-----trial end
    # 0----t1
    #       0------t2
    #               0------t3

    # Set t1, the duration of r1, as the j row and first column.
    t1 <- grid[j, 1]
    # Set t2, the duration of r2, as the j row and second column minus the t1.
    t2 <- grid[j, 2] - t1
    # Set t3, the duration of r3, as the difference between s2 and trial duration
    t3 <- trial_duration - grid[j, 2]

    # Compute the rates r1, r2 and r3

    r1 <- sum(r_times <= t1) / t1
    r2 <- sum(r_times > t1 & r_times <= grid[j, 2]) / t2
    r3 <- sum(r_times > grid[j, 2]) / t3
    # This is the index we want to maximize: the sum of the areas made by
    # the product of durations and differences of response rates.
    A[j] <- sum(t1 * abs(r - r1), t2 * abs(r2 - r), t3 * abs(r - r3), na.rm = T)
  }

  # Get the index which maximizes A (i.e., which j maximize A)
  argmaxA <- which.max(A)
  # Vector of 2 at which A were maximum. column 1 is s1, 2 is s2
  s1s2 <- as.numeric(grid[argmaxA, ])
  # High rate state duration: s2 - s1
  t2 <- s1s2[2] - s1s2[1]
  # Low rate 1 is the number of responses emitted at a time t less than or equal
  # than s1, devided by the duration of s1.
  r1 <- sum(r_times <= s1s2[1]) / s1s2[1]
  # Low rate 2. As r1, is the number of responses emmited at t greter than s1,
  # but less than or equal than s2, devided by the duration of s2
  r2 <- sum(r_times > s1s2[1] & r_times <= s1s2[2]) / t2

  # The responses emmited at t greater than s2, divided by the duration of t3.
  r3 <- sum(r_times > s1s2[2]) / (trial_duration - s1s2[2])

  # Middle time is the sum of s1 and s2 divided by 2
  mid <- sum(s1s2) / 2
  # Return results
  data.frame(
    start = s1s2[1],
    stop = s1s2[2],
    spread = t2,
    r2 = r2, # high rate
    mid = mid,
    r1 = r1,
    r3 = r3
  )
}
