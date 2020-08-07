# Freezing Proxy

## Intro
This repo contains an algorithm that detects Freezing of Gait (FOG) episodes in people with Parkinson's disease (PD), and calculates the total amount of time spent freezing. The input for this algorithm is a series of files (one per bout of gait) that each contain anterior-posterior accelerometer data and mediolateral gyroscope data. This input data must be from either both feet or both shanks, and must be in CSV format. The output is a xls file containing the number of very short, short, long, and very long episodes of freezing of gait.

Currently, this repo contains everything directly under the main directory, except for one subfolder called Subjects that contains two example input data files. This will likely change as scripts get written in other languages and a different organization is needed.

## Getting and running the scripts 
1. Clone this repo by clicking the green "Clone or download" button at the upper right of the repo homepage
2. Open Terminal
3. Change the current working directory to the location where you would like the cloned directory to live
4. Type git clone $URL-YOU-CLONED, replace $URL-YOU-CLONED with the url from the "Clone or download" button
5. Hit "enter"
6. You should now have the repository on your machine and can get into the different directories. You can open the scripts using the IDE of your choice

## Algorithm summary
1. Detects input csv files from the input directory you have specified
2. For each subject or walking bout...
    1. Detect potential FOG using right and left leg gyroscope data
    2. Detect potential FOG using right and left leg accelerometer data
    3. If both of above steps (3.1 and 3.2) agree on a potential (FOG)...
        1. Declare a FOG and calculate % of time spent freezing 
3. Write the results to the a file in the output folder, with one row per input file

## Where do I start?
Start in the file `findFOGs.m`. You will first need to change the `subjectFolder` variable to your own path to the directory that contains subjects and bouts of gait. This will look for all csv files in the directory, and any of its subdirectories and will work to calculate FOGs from all CSV files. You will also need to set the `outputDirectory` variable to a directory of your choice. Finally, you will need to set the column names to the column names in your input files that correspond to the left and right accelerometer and gyroscope data. 

If your setup is different, you will either need to conform to the script's expectations, or locally modify the script so that it is getting information from the right place. 

This file executes the entirety of the algorithm, and calls on the functions contained in other files in order to do further data analysis. 

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
