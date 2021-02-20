# low-high-low or two step breakpoint algorithm, implemented from Church et al 1994

Please cite:

Buritica, J., & Alcala, E. (2019). Increased generalization in a peak procedure after delayed reinforcement. Behavioural processes, 169, 103978.

Eudave-Patiño, M., Alcalá, E., dos Santos, C.V & Buriticá, J. (2021). Similar attention and performance in female and male CD1 mice in the peak procedure. Manuscript in preparation.

This algorithm maximize the sum of three areas shown in the next figure by an exhaustive search of any posible combination of two pairs of response times (the time in the interval at which the animal responds, not the latency of the first response). Because the product of durations <img src="https://latex.codecogs.com/svg.latex?\normalsize&space;d_i"> and the absolute difference <img src="https://latex.codecogs.com/svg.latex?\normalsize&space;|r-r_i|"> are technically areas, we must find the start and stop such that the sum of the three areas is maximized.

<div align="center">
  
 ![\Large \underset{r,d}{\mathrm{argmax}}~\sum_{i=1}^3d_i|r-r_i|~\forall{i}\in{1,2,3}](https://latex.codecogs.com/svg.latex?\normalsize&space;\underset{r,d}{\mathrm{argmax}}~\sum_{i=1}^3d_i|r-r_i|~\forall{i}\in{1,2,3}) 
  
 <img src="https://github.com/jealcalat/start_stop_peak_procedure/blob/main/lhl_diagramm-1.png" width="350">
</div>

The algorithm have two arguments: 

1.- a vector of response times (please don't confuse with latency, which is the time of the first response; response times is the times of every response, not just the first).
2.- the trial duration. For example, if peak trial is three times the reinforcement interval, T, trial duration is 3T. 

The R script *low1_s1_high_s2_low2.r* have more information about its use. The second script shows a possible implementation with data from an experiment. 

## Example

This is a vector with response times from a peak trial from Buriticá & Alcalá (2019). The peak trial have a duration of 180 s, with a T=60 (that is, the reinforcement interval from the start of the trial to the time of reinforcement was 60 s).

```{r }
r_times <- c(28.1, 40.7, 44.2, 44.4, 44.7, 45, 45.4, 47.9, 48.1, 48.3, 48.6, 48.8, 
             49.8, 50.2, 50.7, 51.2, 51.4, 51.7, 51.9, 52.7, 53, 53.5, 53.7, 53.9, 
             54.1, 54.3, 54.9, 55.3, 55.5, 55.7, 55.8, 57.2, 57.4, 57.7, 58.3, 58.5, 
             58.7, 60.4, 60.6, 60.7, 61.1, 61.6, 61.8, 62.6, 62.8, 63.1, 63.3, 63.5, 
             63.8, 64.4, 64.8, 64.9, 65.1, 66.1, 66.4, 67, 68.7, 68.9, 69.5, 69.6, 
             70.1, 70.9, 71, 71.3, 71.6, 71.8, 73.9, 74.1, 74.4, 74.6, 75.2, 76.4, 
             76.6, 77.4, 77.6, 77.8, 78.2, 79.3, 79.9, 80.5, 80.7, 81.3, 82.2, 82.4, 
             82.6, 82.9, 83, 83.1, 83.7, 84.4, 84.4, 84.8, 85, 85.6, 86.6, 87, 87.1, 
             87.3, 87.4, 87.8, 88.1, 88.2, 89.4, 99.1, 99.3, 99.6, 99.8, 100.2, 
             133.1, 133.1, 133.6, 134.9, 135.2, 135.3, 135.4, 135.7, 136.5, 173.8, 
             174.1, 174.3, 174.7, 175.9, 176.3, 176.6, 177.4, 177.5, 177.7, 178.1, 
             178.2, 178.4, 178.5, 178.8, 179.4)
```

Now, we'll apply the function 

```{r }
bps <- low1_s1_high_s2_low2(r_times = r_times, trial_duration = 180)
```

The object *bps* is a ```data.frame``` of 7 columns: start, stop, spread, r2, mid, r1 and r3.

```{r }
print(bps)
# start stop spread       r2  mid        r1        r3
# 1  44.2 89.4   45.2 2.212389 66.8 0.0678733 0.3311258
```
The first two columns are the principal output. Spread is just (stop - start), and mid (middle, or peak time) is just (start + stop) / 2; r1, r2 and r3 the response times in the low state before start, the high rate state between the start and the stop, and the low state after stop.

The next plot shows the distributions of the response times in the peak trial. The dashed line in the center is T=60, and the red lines are the start and stop times identified by ```low1_s1_high_s2_low2```.

<div align="center">
 <img src="https://github.com/jealcalat/start_stop_peak_procedure/blob/main/peak_trial_with_start_stop.svg" width="450">
</div>

The following code can reproduce the figure

```{r}
par(mgp = c(2.3, 0.2, 0),
    mar = c(4, 4.5, 1, 1))
plot(
  density(
    r_times,
    adjust = 0.8,
    from = 0, 
    to = 180
  ),
  main = "",
  ylab = expression(italic(p(t[R]))),
  xlab = "time in peak trial"
)
abline(v = 60, lty = 2)
bps <- low1_s1_high_s2_low2(r_times, 180)
abline(v = c(bps$start, bps$stop), col = 2, lty = 2, lwd = 2)
```
