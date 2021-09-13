import pandas as pd
import csv
import numpy as np
from matplotlib import pyplot as plt

# read in the data
headers = ['number', 'timestamp', 'value']
# df = pd.read_csv('./ETH--USD--MAINNET.csv', names=headers)
df = pd.read_csv('./ETH--USD--MATIC.csv', names=headers)
"""
Analysis of heartbeat
(Time and frequency between updates.)
"""
timestamps = df['timestamp']
timestamps = timestamps.iloc[1:].astype(int)

# Should be using pandas but it was taking the piss
a = timestamps[1:].values.tolist()
b = timestamps[:-1].values.tolist()

mylist = [a_i - b_i for a_i, b_i in zip(a, b)]  # difference between lists
mylist = [x / 60 for x in mylist]  # Converting to minutes

s = pd.DataFrame(mylist)
ax = s.boxplot()  # box plot analysis
ax.axes.set_ylabel("Minutes between price updates")
ax.axes.set_xlabel("ETH/USD Polygon Price Feed")
plt.show()
"""
Analysis of percentage changes
(Volatilty of update values.)
"""
values = df['value']
price_series = values.iloc[1:].astype(int)
pecentage_changes = price_series.pct_change()

# ax = pecentage_changes.plot.kde()

ax = pecentage_changes.plot.hist(bins=150, alpha=0.5)
ax.axes.set_ylabel("Frequency")
ax.axes.set_xlabel("Percentage change between price update")
# ax = df.boxplot()

plt.show()
