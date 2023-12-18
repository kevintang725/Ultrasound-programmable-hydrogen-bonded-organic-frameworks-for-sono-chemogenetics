# Ultrasound-programmable-hydrogen-bonded-organic-frameworks-for-sono-chemogenetics

## Code Folder: Contains MATLAB scripts for data analysis

### ForceSwimTest.m
Imports kinematic data from predicted poses using DeepLabCut and calculates force swimming test metrics including: 
1) Immobility Time
2) Mean Velocity
3) Total Distance Travelled
4) Immobility Score

#### How to use
1) Use DeepLabCut to import video experiments. Label, train and run the model for pose prediction and estimations (https://github.com/DeepLabCut/DeepLabCut).
2) Export pose estimation and kinematic data .csv or .xlsx files into a folder.
3) Download **Force Swim Test** directory under _Demos_. Use the directory format to structure and store your data acquired from DeepLabCut into **Example Data** directory. Open **ForceSwimTest.m** and under **Import Data** section of the code (Line 11), change the `"FILE_PATH"` to the file path of the directory you just imported. If you exported the pose estimation and kinematic data as .csv instead of .xlsx, change line 12 `source_files = dir(fullfile(source_dir, '*.csv));`
4) Run the script in MATLAB, it will automatically process and analyze all data within the directories and export and .xlsx file containing the force swim test metrics.

### InVitroCalciumImaging.m
Imports fluorscent intensity data over time extracted via ImageJ. Detrends, normalize and corrects baseline of fluorescent data due to photobleaching across all cells.

#### How to use
1) Use ImageJ for selecting specific cell type for time-series fluorescence data. Export the time-series data into structure following the example data _**TATB@CNO+ FUS- hM3D+ GCaMP6s+ 1.xlsx**_ under _Demo/In Vivo Sonochemogenetics/Example Data_.
2) Download **In Vivo Sonochemogenetics** directory under _Demos_. Use the directory format to structure and store your data acquired from ImageJ into **Example Data** directory. Open **InVitroCalciumImaging.m** and under **Import Data** section of the code (Line 11), change the `"FILE_PATH"` to the file path of the directory you just imported.
3) Run the script in MATLAB, it will automatically process and analyze all data within the directories and export .xlsx file.
