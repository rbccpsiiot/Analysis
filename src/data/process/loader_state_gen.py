
# coding: utf-8

# In[1]:


import pandas as pd
import os
import sys


# In[2]:


import matplotlib.pyplot as plt


# In[3]:


# plt.rcParams["figure.figsize"]=[15,5]
if len(sys.argv) <  2:

        print("No filename passed. Place the CSV file in the same folder.")

        exit(2)

ldfile=sys.argv[1]

out_csv_path=sys.argv[2]
out_csv_path=out_csv_path if out_csv_path.endswith("/") else out_csv_path + "/"

if not os.path.isfile(ldfile):

        print("File not found!")

#         exit(1)

try:
        
         raw=pd.read_csv(ldfile, usecols=['timestamp', 'data.ax', 'data.ay', 'data.az', 'data.A1'])
#          raw = pd.read_csv('loader.csv', usecols=['timestamp', 'data.ax', 'data.ay', 'data.az', 'data.A1'])

except:

        print("Invalid file!")
        exit(2)

# In[4]:


raw["acc"]=( raw["data.ax"]**2 + raw["data.az"]**2 ) ** 0.5


# In[5]:


# mins = 50
# window = 50 * 60 * 75


# In[6]:


acc=raw[["timestamp", "acc"]]
acc.set_index('timestamp')
# acc.head()


# In[7]:


# acc.head(window).to_csv('loader_head.csv', index=False)


# In[8]:


# test=pd.read_csv('loader_head.csv')
# test.plot()
# test['timestamp']=acc.head(window)['timestamp']


# In[9]:


# acc=pd.read_csv('loader_head.csv')
test=acc
test['acc']=pd.Series.to_frame(test.acc.rolling(75, center=True).std())
# test1.to_csv('rollingstd.csv', index=False)


# In[10]:


# test=pd.read_csv('rollingstd.csv')
# test.plot()


# In[11]:


import scipy.signal
import numpy as np


# In[12]:


#refill=scipy.signal.find_peaks(test.acc, height=(0.0050, 0.020), width=100)


# In[13]:


#brd=scipy.signal.find_peaks(test.acc,height=(0.015), width=75)

board=scipy.signal.find_peaks(test.acc,height=(0.015), width=75)


# In[14]:


# board


# In[15]:


# test.plot()
# plt.margins(0)


# In[16]:


# plt.stem(refill[0], refill[1]['peak_heights'])
# plt.ylim(ymax = 0.04, ymin = 0)
# plt.title("Refill Detection")
# plt.xlim(xmax = 500000, xmin = 0)
# plt.stem(np.fft.fft(refill[1]['peak_heights']))


# In[17]:


# test.plot()
# plt.margins(0)
# plt.ylim(ymax = 0.04, ymin = 0)
# plt.xlim(xmax = 500000, xmin = 0)


# In[18]:


# plt.stem(board[0], board[1]['peak_heights'])
# plt.margins(0)


# In[19]:


#start=board[0][0]
#end=board[0][-1]
block_size=75*60*1
#board[1]['refill_status']=[0]*len(refill[0])


# In[20]:


boards=[]
differ=np.diff(board[0])
differ=differ.tolist()

# differ


# In[21]:


# binwidth=200
# plt.hist(differ, bins=np.arange(min(differ), max(differ) + binwidth, binwidth))
# print(np.percentile(differ, 30))


# In[22]:


test.insert(2,'state',0)
boards=[]
if len(board[0]) > 0:
	boards.append(board[0][0])
	for i, x in enumerate(board[0]):
    		try:
        		if differ[i]>5000:
           			#print(x)
            			boards.append(board[0][i+1])
            			test.at[x, 'state']=1
        		else:
            			test.at[x, 'state']=2
    		except:
        		continue

# In[ ]:


# plt.stem(board[0], board[1]['peak_heights'])
# plt.margins(0)


# In[ ]:


# test.plot()
# plt.margins(0)


# In[ ]:


# test.plot()
# plt.margins(0)
# plt.stem(boards, np.ones(len(boards))*0.04, 'orange', '--',)
# plt.margins(0)


# In[ ]:


# plt.stem(boards, np.ones(len(boards)))
# plt.margins(0)


# In[23]:


print(len(boards))


# In[24]:

if not os.path.exists(out_csv_path):
    os.makedirs(out_csv_path)
#directory='/mnt/UltraHD/streamingStates/LD'



test.drop('acc', axis=1, inplace=True)
test['device']='loader'
print(test)
import time

timestr = time.strftime("%Y-%m-%d_%H-%M-%S")
print("Saving States with file name - loader-"+ timestr+".csv")
test.to_csv(out_csv_path + "loader-" + timestr+ ".csv")
#test.to_csv(timestr+"LD.csv")

