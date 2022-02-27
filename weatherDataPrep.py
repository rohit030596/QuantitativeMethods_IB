# -*- coding: utf-8 -*-
"""
Created on Wed Feb 23 21:53:45 2022

@author: Yikes
"""

import pandas as pd
#import numpy as np
#import os


df = pd.read_csv("D:\\Github\\Data\\WeatherData.csv")

df_grouped = df.groupby(by = ['lat_long', 'date'], dropna=True).mean()
df_grouped = df_grouped.iloc[:,9:-1].reset_index()

postal_code = pd.Series(['H1N 2Z7', 'H3K 2C3', 'H4N 3J8', 'H4P 2T5', 'M3J 1N4', 'M4G 3E4',\
               'M4H 1B6', 'M4M 3G6', 'M5R 3R9', 'M6L 1A5', 'M6N 4Z5', 'M9W 3W6',\
                   'V5M 2G7', 'V5Z 1C5', 'V6B 1V4', 'V6G 1C8', 'V6K 1N9']).reset_index()
    
postal_code['index'] = postal_code['index'] + 1 
postal_code.rename(columns = {'index':'lat_long', 0:'postal_code'}, inplace=True)

df_grouped = df_grouped.merge(postal_code, how='left', on='lat_long')
df_grouped.to_csv("D:\\Github\\Data\\weatherDataFinal.csv")

"""

df_grouped = df.groupby(by = ["prov", "year", "month"], dropna = True).agg({'max_temp':'max',
                                                               'mean_temp':'mean',
                                                               'min_temp':'min',
                                                               'spd_max_gust':'max',
                                                               'total_precip':'sum',
                                                               'total_rain':'sum',
                                                               'total_snow':'sum'})

"""

"""
df_1 = df[(df.prov == "QC") & (df.year == 2019) & (df.month == 1)]
df_1[['prov', 'year', 'month', 'max_temp', 'mean_temp', 'min_temp', 'spd_max_gust',
   'total_precip', 'total_rain', 'total_snow']].to_csv("test.csv")
"""

#df_grouped.to_csv("weatherDataFinal.csv")
