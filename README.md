# sls - A Matlab Package for Sea Level Science

[![View Sea Level Science (sls) on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/180404-sls)

This package was written during my PhD - functions were subject to testing only for my needs and therefore treat with caution. Most have also not been used in a decent amount of time. 

See [sls_example_usage](https://github.com/LJ-Jenkins/sls/blob/main/example_usage.pdf) for a brief introduction to some of the functions

Syntax is sls.function() for base functions or sls.group.function() for functions that are grouped (see below)
e.g., sls.calc_tide(), sls.bodc.load()

Current functions:

```matlab:Code
base

remove_msl - removes mean sea level trends from sea level data (optimised for UK)

calc_tide - year by year or whole timeseries tidal harmonic analysis and tidal 
            reconstruction from inputted sea level data onto a 15 minute 
            temporal timeseries
                 
high_low_water - calculates the high and low waters from given water level
                 or tide data
                 
tidal_phase -  calculates tidal phase, aka time to either nearest high or 
               low water for every timestep
               
rPOT - gains peaks over threshold (POT) values, using 'R largest' method
       with a storm window
       
POT_counts - counts peaks over threshold (POT) values, per specified 
             time period
             
skew_surge - calculates skew surge by using the high waters of a sinusoidal 
             tidal curve and calculating the difference in tidal (predicted) 
             high water and the actual high water around each sinusoidal peak

tidal_phase - calculates tidal phase, aka time to either nearest high or low water for every timestep

return_levels - calculates return levels for specified return periods by fitting a gev, gumbel (for block maxima),
                or gp (for peaks over threshold) distribution to given data
             
thresh_cross_del - for every group of consecutive values over a threshold, 
                   all but the max in the group are deleted (made nan)
                   
time_above_thresh -  calculates time above threshold in hours with multiple 
                     options/methods
                     
time_between_exceedance_groups - for every group of consecutive values over 
                                 a threshold, get the time between each group
                                 
timeperiod_minmax - table of minimum and/or maximum values and their associated times 
                    in relation to a specified grouping time period

perc_thresh_n_py - get percentile threshold that gives closest to ~n exceedances per year (or timeperiod)
                                 
bands_chisq - chi squared goodness of fit test for data and a sample partitioned into n-bands

groupbin - bin data into groups specified by values or percentiles

closest_vals - get the closest values (or their indices) in one input to another 

fnames - get the file and folder names within a directory

searchsorted - finds indices in sorted vector x where values would be inserted to maintain sorted order (in style of numpy searchsorted)


+bodc

bodc.load - load UK National Tide Gauge Network data from files downloaded 
            from the British Oceanographic Data Centre (BODC)
            
bodc.flag_removal - remove flagged data from BODC

bodc.tide_gauge_info - get information about a specific tide gauge 
                       (name, ordnance datum, latitude, longitude)

bodc.tidy_downloads - tidies a list of BODC UKNTGN files into folders of sites, each containing relevant files.
                      Works for data from primary channel, values + residuals, surges and extremes.


+nnrcmp

nnrcmp.site_info - get information on the NNRCMP Coastal Monitoring Organisation realtime data sites. Correct as of May 2024.

nnrcmp.get_site_info - scrapes information from the NNRCMP Coastal Monitoring Organisation realtime data sites

nnrcmp.load_wav - load Channel Coast Observatory (CCO) qc wave data

nnrcmp.wav_flag_removal - removes flagged CCO qc wave data

nnrcmp.load_wl - load CCO qc water level data

nnrcmp.wl_flag_removal - removes flagged CCO qc water level data (replaces with nan)


+plt

plt.timeseries - plots variables and their associated times

plt.add_line - plots line variable to an open plot

plt.add_timeseries - plots variables and their associated times on a new plot 
                     or to an open plot on the next tile
                     
plt.binlabels - creates binned labels from n - n+1 variable, with option to add to
                open plot as xticklabels
                      
plt.coverage_greyed - gives grey shading colours/alphas representative of the 
                      percentage of non-nan data over user-defined time periods 
                      within a timeseries
                      
plt.font - changes font options (weight, size, and name) for a currently opened plot

plt.nxtile - calls nexttile() using a row,col positional input as opposed to a scalar and expands grid automatically

plt.rPOT - overlays all exceedance events from rPOT

plt.time_between_exceedances - plots the time between each group of consecutive values 
                               over a threshold, with options to highlight the magnitude 
                               of each exceedance
                               
plt.twogroup_stacked_hist - plots a histogram of a binned variable that is also stacked 
                            by a different grouping

plt.labeltiles - labels tiles 'a' to 'z' in either row major or column major order

plt.change_nth_xylabel - removes the nth x or y label and replaces it with a specified label


+gesla3

Functions for the loading of GESLA3.0 datasets, see: https://github.com/LJ-Jenkins/GESLA-3

gesla3.load_file
gesla3.pload_file
gesla3.load_country
gesla3.load_bbox
gesla3.nearest
gesla3.site2file
gesla3.change_fieldnames
```
