# -*- coding: utf-8 -*-
"""
Created on Mon Mar 14 12:19:37 2022

@author: Yikes
"""

import pandas as pd 
import numpy as np
df = pd.read_csv("C:\\Users\\Yikes\\Downloads\\1810000401_databaseLoadingData.csv")
df = df[['REF_DATE', 'GEO', 'Products and product groups', 'VALUE']]

df = df[df['Products and product groups']!='Gasoline']
df = df.groupby(by=['REF_DATE', 'GEO']).mean('VALUE').reset_index()\
    .sort_values(by=['GEO','REF_DATE'])\
    .reset_index().rename({'0':'Index'}).drop('index',axis=1)

df = df.pivot(index='REF_DATE',columns=['GEO'], values=['VALUE']).reset_index()

df.to_csv('CPI_data.csv')


df1 = pd.read_excel("D:/Github/QuantitativeMethods_IB/Data/stationMaster.xlsx", sheet_name="Old")
df2 = pd.read_excel("D:/Github/QuantitativeMethods_IB/Data/controlVariables.xlsx", sheet_name="RetailSales")
df2 = df2.groupby(["Date"]).sum().reset_index()
df2 = df2.melt(id_vars = 'Date',var_name = "prov", value_vars = ["British Columbia", "Ontario", "Quebec"])
df2['prov'] = df2['prov'].apply(lambda x: "BC" if x=="British Columbia" else "QC" if x=="Quebec" else "ON")

df1['Date'] = df1.apply(lambda x: str(x.year)+"-"+f'{x.month:02d}', axis=1)

df = pd.merge(df1,df2,on = ['prov', 'Date'])
df = df.set_index("Date").reset_index()
df = df.drop(['year', 'month'], axis=1)

df.to_csv("testing.csv", index=False)
