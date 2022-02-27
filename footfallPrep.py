# -*- coding: utf-8 -*-
"""
Created on Fri Feb 25 23:33:02 2022

@author: Yikes
"""

#import os
import pandas as pd
#import numpy as np
#from functools import reduce
#import json
import datetime

df = pd.read_csv("D:/Github/Data/footfall_data.csv")

columns = ['street_address', 'city', 'region', 'postal_code', 'iso_country_code',\
           'brands', 'date_range_start', 'date_range_end', 'raw_visit_counts',\
           'visits_by_day', 'normalized_visits_by_state_scaling']
    
df = df[columns]    
#df = df[(df['city'] == 'Montreal')&(df['brands'] == 'Walmart')] # Change filter here to increase scope
df = df[df['city'].isin(['Montreal', 'Vancouver', 'Toronto'])]
stores = df.postal_code.unique()

df['date_range_start'] = pd.to_datetime(df['date_range_start'], utc=True)
df['date_range_end'] = pd.to_datetime(df['date_range_end'], utc=True)
df = df[(df['date_range_start'] >= '31/12/2018') & (df['date_range_end'] <= '24/10/2021')]

date_index = pd.date_range(start='31/12/2018', end='24/10/2021')
data = {}
for i in stores:
    t1 = df[df['postal_code']==i].sort_values('date_range_start').reset_index().drop('index', axis=1)    
    t1['visits_by_day'] = t1['visits_by_day'].apply(lambda x:list(map(int, x[1:-1].split(','))))
    t1['normalize_factor'] = t1['normalized_visits_by_state_scaling'] / t1['raw_visit_counts'] 
    t1['visits_by_day'] = t1.apply(lambda x: [int(x.normalize_factor * i) for i in x.visits_by_day], axis=1)
    
    t2 = pd.DataFrame(date_index, columns=['Date'])
    t2 = pd.concat([t2, t1['visits_by_day'].explode().reset_index().drop('index', axis=1)], axis=1)
    
    c = ['street_address', 'city', 'region', 'postal_code', 'iso_country_code', 'brands']
    t2['street_address'] = t1.loc[0,c]["street_address"]
    t2['city'] = t1.loc[0,c]["city"]
    t2['region'] = t1.loc[0,c]["region"]
    t2['postal_code'] = t1.loc[0,c]["postal_code"]
    t2['iso_country_code'] = t1.loc[0,c]["iso_country_code"]
    t2['brands'] = t1.loc[0,c]["brands"]
    
    data[i] = t2
    

data_out = data[stores[0]]
for i in stores[1:]:
    data_out = pd.concat([data_out, data[i]], axis=0)
    
data_out.to_csv("D:\\Github\\QuantitativeMethods_IB\\Data\\footfall_final.csv", index=False)

