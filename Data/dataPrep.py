# -*- coding: utf-8 -*-
"""
Created on Wed Feb 23 21:53:45 2022

@author: Yikes
"""

import pandas as pd
import numpy as np
import os

os.getcwd()
os.chdir("D:/Github/QuantitativeMethods_IB/Data")

df = pd.read_csv("weatherData.csv")


df_grouped = df.groupby(by = ["prov", "year", "month"], dropna = True).agg({'max_temp':'max',
                                                               'mean_temp':'mean',
                                                               'min_temp':'min',
                                                               'spd_max_gust':'max',
                                                               'total_precip':'sum',
                                                               'total_rain':'sum',
                                                               'total_snow':'sum'})


"""
df_1 = df[(df.prov == "QC") & (df.year == 2019) & (df.month == 1)]
df_1[['prov', 'year', 'month', 'max_temp', 'mean_temp', 'min_temp', 'spd_max_gust',
   'total_precip', 'total_rain', 'total_snow']].to_csv("test.csv")
"""

df_grouped.to_csv("weatherDataFinal.csv")
