# low-high-low or two step breakpoint algorithm, implemented from Church et al 1994

Please cite:

Buritica, J., & Alcala, E. (2019). Increased generalization in a peak procedure after delayed reinforcement. Behavioural processes, 169, 103978.

Eudave-Patiño, M., Alcalá, E., dos Santos, C.V & Buriticá, J. (2021). Similar attention and performance in female and male CD1 mice in the peak procedure. Manuscript in preparation.

This algorithm maximize the sum of three areas shown in the next figure by an exhaustive algorithm that search any posible combination of two pairs of the times of response (the time in the interval at which the animal responds). Because the product of durations <img src="https://latex.codecogs.com/svg.latex?\normalsize&space;d_i"> and the absolute difference <img src="https://latex.codecogs.com/svg.latex?\normalsize&space;|r-r_i|"> are technically areas, we must find the start and stop such that the sum of the three areas is maximized.

<div align="center">
  
 ![\Large \underset{r,d}{\mathrm{argmax}}~\sum_{i=1}^3d_i|r-r_i|~\forall{i}\in{1,2,3}](https://latex.codecogs.com/svg.latex?\normalsize&space;\underset{r,d}{\mathrm{argmax}}~\sum_{i=1}^3d_i|r-r_i|~\forall{i}\in{1,2,3}) 
  
 <img src="https://github.com/jealcalat/start_stop_peak_procedure/blob/main/lhl_diagramm-1.png" width="350">
</div>

The algorithm have two arguments: 

1.- a vector of response times (please don't confuse with latency, which is the time of the first response; response times is the times of every response, not just the first).
2.- the trial duration. For example, if peak trial is three times the reinforcement interval, T, trial duration is 3T. 

The R script *low1_s1_high_s2_low2.r* have more information about its use. The second script shows a possible implementation. 
