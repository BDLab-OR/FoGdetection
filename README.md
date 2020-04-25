# Freezing Proxy

## Intro
This repo contains an algorithm that  detects Freezing of Gait (FOG) episodes in people with Parkinson's disease (PD), and calculates the total amount of time spent freezing. The input for this algorithm is raw accelerometer and gyroscope data (.h5 formate) from subjects wearning 3 Opal sensors with one of the lumbar and two on feet (or shanks). The output is a strucutre file containing the total amount of time spent frezzing (with other information that used to calculate the output). If the users have a continous monitoring data, the output is provided for each 30 minute window. 

Currently, this repo contains everything directly under the main directory, except for one subfolder containing subject information. This will likely change as scripts get written in other languages and a different organization is needed.

## Getting and running the scripts 
1. Clone this repo by clicking the green "Clone or download" button at the upper right of the repo homepage
2. Open Terminal
3. Change the current working directory to the location where you would like the cloned directory to live
4. Type git clone $URL-YOU-CLONED, replace $URL-YOU-CLONED with the url from the "Clone or download" button
5. Hit "enter"
6. You should now have the repository on your machine and can get into the different directories. You can open the scripts using the IDE of your choice

## Algorithm summary
1. Detects folders containing .h5 files where raw data have been stored
2. For each subject...
  1. Segment data of lumbar, right leg, and left leg into 30 minute window
  2. For each 30 minute window...
    1. Detect if subject is walking using lumbar accelerometer data
    2. Find a total number of walking bouts
    3. For each walking bout...
      1. Detect potential FOG using right and left leg gyroscope data
      2. Detect potential FOG using right and legt leg accelerometer data
      3. If both of above steps (3.1 and 3.2) find a potentila (FOG)...
        1. Declare a confirm FOG and calculate % of time spent freezing 
  3. Calculate the percentage of time spent freezing during each 30 minute window
3. Write the results to a new file in the subject's folder. 

## Algorithm flowchart
![Algorithm flowchart](https://github.com/BDLab-OR/FoGdetection/blob/master/FOGdetection_Flowchart.png)

## Where do I start?
Start in the file `saveTURNFOGmetrics_MM_Vrutang.m`. You will first need to change the `studyDirectory` variable to your own path to the Freezing-Proxy directory. This script assumes that you have the patient information in subfolders under the Freezing-Proxy directory named something like `Subject01`. If your setup is different, you will either need to conform to the script's expectations, or locally modify the script so that it is getting information from the right place. 

This file executes the entirety of the algorithm, and calls on the functions contained in other files in order to do further data analysis. 

## Files summary
- saveTURNFOGmetrics_MM_Vrutang.m: This file executes the algorithm, calling other functions as needed. It serves as the skeleton of the entire program. In order, the file:
  - calls getHDFdata.m to get accelerometer, gyroscope, magnometer, and orientation data for each recording
  - calls getMetrics_MM to get data segemted by 30 minute window
    - calls KernelFilter to apply Epanechnikov kernel filter
    - calls getACCBouts_FOG_MM to identify bouts within for each 30 minute window
    - calls getFOGmarkers to identify FOG episodes and calculates % time spent freezing using sensors on the shank (if any)
    - calls getFOGmarkers_feet to identify OG episodes and calculates % time spent freezing using sensors on the foot

## Editing the scripts 
1. Create a new branch to do your work on. Do this using `git checkout -b $branchname`, where $branchname is a name you select for your branch
2. Edit the script(s)
3. In Terminal, type `git status` to see which files you have changed
4. Add the file or files you would like to using `git add $file`. Don't add files that you might have changed to experiment with them. Only add files that have necessary edits
5. Add a commit message by typing `git commit -m "what change you did"`
6. Push to your branch by typing `git push origin $branchname`
7. On GitHub, in the "Branch" menu, choose the branch that contains your work
8. To the right of the "Branch" menu, click "New pull request". The base branch should be master, and the comparison branch should be your new branch.
9. Type a title and description for your PR
10. Click "Create Pull Request" 
11. Ask one of your collaborators to review your PR for correctness and style. They will merge your PR if it is good to go, or ask you to make changes
