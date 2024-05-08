# 04_create_initial_community.R
# Description:
# This script reads the classified rasters for tree types (Spruce, Pine, Birch, Other) and age,
# which were previously generated, and combines them to create the initial community map.
# The initial community map represents the spatial distribution of tree types and age classes,
# which is essential for initializing LANDIS-II simulations.
# The resulting map is saved in the 'data/initial_community' directory.


# Load required packages
if (!requireNamespace("terra", quietly = TRUE)) {
  install.packages("terra")
}

library(terra)

# Check if the script is being run from within RStudio
if (interactive()) {
  # Get the path of the currently running script
  script_path <- file.path(dirname(rstudioapi::getActiveDocumentContext()$path), "04_create_initial_community.R")
  
  # Print the script path
  print(script_path)
} else {
  print("Not running in interactive mode (e.g., not in RStudio).")
}

# Specify project directory
project_directory <- dirname(dirname(script_path))

# Specify input and output directories
input_directory <- file.path(project_directory, "data", "classified_rasters")
output_directory <- file.path(project_directory, "data", "initial_community")

# Create output directory if it doesn't exist
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}


# Read the raster files for age and tree species
r1 <- rast(file.path(input_directory, "Age.tif"))
r2 <- rast(file.path(input_directory, "Spruce.tif"))
r3 <- rast(file.path(input_directory, "Pine.tif"))
r4 <- rast(file.path(input_directory, "Birch.tif"))
r5 <- rast(file.path(input_directory, "Other.tif"))

r6 <- r1
r6[r6] <- NA
#CLAS
#No forest
r6[r1==0] <-0
r6[r1==1] <-1

#
r6[r1 == 2 & r2 ==4 ] <- 2    # Young spruce
r6[r1 == 2 & r3 ==4 ] <- 3    # Young Pine
r6[r1 == 2 & r4 ==4 ] <- 4    # Young Birch
r6[r1 == 2 & r5 ==4 ] <- 5    # Young other

r6[r1 == 2 & r2 ==2 & r3==2 ] <- 110    # Young spruce/pine equel
r6[r1 == 2 & r2 ==2 & r4==2 ] <- 111
r6[r1 == 2 & r2 ==2 & r5==2 ] <- 112
r6[r1 == 2 & r3 ==2 & r4==2 ] <- 113
r6[r1 == 2 & r3 ==2 & r5==2 ] <- 114
r6[r1 == 2 & r4 ==2 & r5==2 ] <- 115

r6[r1 == 2 & r2 ==2 & r3==1 & r4==1 & r5==1] <- 134   # Young Mixed spruce/pine/birch
r6[r1 == 2 & r3 ==2 & r2==1 & r5==1 & r4==1] <- 135  # Young Mixed spruce/pine/other
r6[r1 == 2 & r4 ==2 & r5==1 & r3==1 & r2==1 ] <- 136   # Young Mixed spruce/other/birch
r6[r1 == 2 & r5 ==2 & r2==1  & r4==1 & r3==1] <- 137   # Young Mixed pine/spruce/birch

r6[r1 == 2 & r2 ==3 & r3==2 ] <- 6   # Young Mixed SPRUcE/Pine
r6[r1 == 2 & r2 ==3 & r4==2  ] <- 7   # Young Mixed spruce/birch
r6[r1 == 2 & r2 ==3 & r5==2  ] <- 8   # Young Mixed spruce/other
r6[r1 == 2 & r2 ==3 & r3==1 & r4==1] <- 9   # Young Mixed spruce/pine/birch
r6[r1 == 2 & r2 ==3 & r3==1 & r5==1] <- 10  # Young Mixed spruce/pine/other
r6[r1 == 2 & r2 ==3 & r5==1 & r4==1  ] <- 11   # Young Mixed spruce/other/birch

r6[r1 == 2 & r3 ==3 & r2==2 ] <- 12   # Young Mixed Pine/Spruce
r6[r1 == 2 & r3 ==3 & r2==1  & r4==1] <- 13   # Young Mixed pine/spruce/birch
r6[r1 == 2 & r3 ==3 & r2==1  & r5==1] <- 14  # Young Mixed pine/spruce/other
r6[r1 == 2 & r3 ==3 & r4==2  ] <- 15   # Young Mixed pine/birch
r6[r1 == 2 & r3 ==3 & r5==2  ] <- 16   # Young Mixed pine/other
r6[r1 == 2 & r3 ==3 & r5==1 & r4==1  ] <- 17   # Young Mixed spruce/other/birch

r6[r1 == 2 & r4 ==3 & r2==2  ] <- 18  # Young Mixed birch/Spruce
r6[r1 == 2 & r4 ==3 & r3==1  & r2==1] <- 19   # Young Mixed birch/spruce/pine
r6[r1 == 2 & r4 ==3 & r5==1  & r2==1] <- 20  # Young Mixed birch/spruce/other
r6[r1 == 2 & r4 ==3 & r3==2  ] <- 21   # Young Mixed Birch/pine
r6[r1 == 2 & r4 ==3 & r5==2 ] <-22   # Young Mixed birch/other


r6[r1 == 2 & r5 ==3 & r2==2  ] <- 23   # Young Mixed other/Spruce
r6[r1 == 2 & r5 ==3 & r3==1  & r2==1] <- 24   # Young Mixed other/spruce/pine
r6[r1 == 2 & r5 ==3 & r4==1  & r2==1] <- 25  # Young Mixed other/spruce/birch
r6[r1 == 2 & r5 ==3 & r3==2  ] <- 26   # Young Mixed other/pine
r6[r1 == 2 & r5 ==3 & r4==2 ] <-27   # Young Mixed other/birch

r6[r1 == 2 & r2==1 & r3==1 & r4==1 & r5==1 ] <- 28   # Young Mixed spruce/pine/dec

#middle 
r6[r1 == 3 & r2 ==4 ] <- 29    # Young spruce
r6[r1 == 3 & r3 ==4 ] <- 30    # Young Pine
r6[r1 == 3 & r4 ==4 ] <- 31    # Young Birch
r6[r1 == 3 & r5 ==4 ] <- 32    # Young other

r6[r1 == 3 & r2 ==2 & r3==2 ] <- 116    # Young spruce/pine equel
r6[r1 == 3 & r2 ==2 & r4==2 ] <- 117
r6[r1 == 3 & r2 ==2 & r5==2 ] <- 118
r6[r1 == 3 & r3 ==2 & r4==2 ] <- 119
r6[r1 == 3 & r3 ==2 & r5==2 ] <- 120
r6[r1 == 3 & r4 ==2 & r5==2 ] <- 121

r6[r1 == 3 & r2 ==2 & r3==1 & r4==1 & r5==1] <- 138   # Young Mixed spruce/pine/birch
r6[r1 == 3 & r3 ==2 & r2==1 & r5==1 & r4==1] <- 139  # Young Mixed spruce/pine/other
r6[r1 == 3 & r4 ==2 & r5==1 & r3==1 & r2==1 ] <- 140   # Young Mixed spruce/other/birch
r6[r1 == 3 & r5 ==2 & r2==1  & r4==1 & r3==1] <- 141   # Young Mixed pine/spruce/birch

r6[r1 == 3 & r2 ==3 & r3==2 ] <- 33   # Young Mixed SPRUcE/Pine
r6[r1 == 3 & r2 ==3 & r4==2  ] <- 34   # Young Mixed spruce/birch
r6[r1 == 3 & r2 ==3 & r5==2  ] <- 35   # Young Mixed spruce/other
r6[r1 == 3 & r2 ==3 & r3==1 & r4==1] <- 36   # Young Mixed spruce/pine/birch
r6[r1 == 3 & r2 ==3 & r3==1 & r5==1] <- 37  # Young Mixed spruce/pine/other
r6[r1 == 3 & r2 ==3 & r5==1 & r4==1  ] <- 38   # Young Mixed spruce/other/birch

r6[r1 == 3 & r3 ==3 & r2==2 ] <- 39   # Young Mixed Pine/Spruce
r6[r1 == 3 & r3 ==3 & r2==1  & r4==1] <- 40   # Young Mixed pine/spruce/birch
r6[r1 == 3 & r3 ==3 & r2==1  & r5==1] <- 41  # Young Mixed pine/spruce/other
r6[r1 == 3 & r3 ==3 & r4==2  ] <- 42   # Young Mixed pine/birch
r6[r1 == 3 & r3 ==3 & r5==2  ] <- 43   # Young Mixed pine/other
r6[r1 == 3 & r3 ==3 & r5==1 & r4==1  ] <- 44   # Young Mixed spruce/other/birch

r6[r1 == 3 & r4 ==3 & r2==2  ] <- 45  # Young Mixed birch/Spruce
r6[r1 == 3 & r4 ==3 & r3==1  & r2==1] <- 46   # Young Mixed birch/spruce/pine
r6[r1 == 3 & r4 ==3 & r5==1  & r2==1] <- 47  # Young Mixed birch/spruce/other
r6[r1 == 3 & r4 ==3 & r3==2  ] <- 48   # Young Mixed Birch/pine
r6[r1 == 3 & r4 ==3 & r5==2 ] <-49   # Young Mixed birch/other


r6[r1 == 3 & r5 ==3 & r2==2  ] <- 50   # Young Mixed other/Spruce
r6[r1 == 3 & r5 ==3 & r3==1  & r2==1] <- 51   # Young Mixed other/spruce/pine
r6[r1 == 3 & r5 ==3 & r4==1  & r2==1] <- 52  # Young Mixed other/spruce/birch
r6[r1 == 3 & r5 ==3 & r3==2  ] <- 53   # Young Mixed other/pine
r6[r1 == 3 & r5 ==3 & r4==2 ] <-54   # Young Mixed other/birch

r6[r1 == 3 & r2==1 & r3==1 & r4==1 & r5==1 ] <- 55   # Young Mixed spruce/pine/dec


#mature
r6[r1 == 4 & r2 ==4 ] <- 56    # Young spruce
r6[r1 == 4 & r3 ==4 ] <- 57    # Young Pine
r6[r1 == 4 & r4 ==4 ] <- 58    # Young Birch
r6[r1 == 4 & r5 ==4 ] <- 59    # Young other

r6[r1 == 4 & r2 ==2 & r3==2 ] <- 122    # Young spruce/pine equel
r6[r1 == 4 & r2 ==2 & r4==2 ] <- 123
r6[r1 == 4 & r2 ==2 & r5==2 ] <- 124
r6[r1 == 4 & r3 ==2 & r4==2 ] <- 125
r6[r1 == 4 & r3 ==2 & r5==2 ] <- 126
r6[r1 == 4 & r4 ==2 & r5==2 ] <- 127

r6[r1 == 4 & r2 ==2 & r3==1 & r4==1 & r5==1] <- 142   # Young Mixed spruce/pine/birch
r6[r1 == 4 & r3 ==2 & r2==1 & r5==1 & r4==1] <- 143  # Young Mixed spruce/pine/other
r6[r1 == 4 & r4 ==2 & r5==1 & r3==1 & r2==1 ] <- 144   # Young Mixed spruce/other/birch
r6[r1 == 4 & r5 ==2 & r2==1  & r4==1 & r3==1] <- 145   # Young Mixed pine/spruce/birch

r6[r1 == 4 & r2 ==3 & r3==2 ] <- 60   # Young Mixed SPRUcE/Pine
r6[r1 == 4 & r2 ==3 & r4==2  ] <- 61   # Young Mixed spruce/birch
r6[r1 == 4 & r2 ==3 & r5==2  ] <- 62   # Young Mixed spruce/other
r6[r1 == 4 & r2 ==3 & r3==1 & r4==1] <- 63   # Young Mixed spruce/pine/birch
r6[r1 == 4 & r2 ==3 & r3==1 & r5==1] <- 64  # Young Mixed spruce/pine/other
r6[r1 == 4 & r2 ==3 & r5==1 & r4==1  ] <- 65   # Young Mixed spruce/other/birch

r6[r1 == 4 & r3 ==3 & r2==2 ] <- 66   # Young Mixed Pine/Spruce
r6[r1 == 4 & r3 ==3 & r2==1  & r4==1] <- 67   # Young Mixed pine/spruce/birch
r6[r1 == 4 & r3 ==3 & r2==1  & r5==1] <- 68  # Young Mixed pine/spruce/other
r6[r1 == 4 & r3 ==3 & r4==2  ] <- 69   # Young Mixed pine/birch
r6[r1 == 4 & r3 ==3 & r5==2  ] <- 70   # Young Mixed pine/other
r6[r1 == 4 & r3 ==3 & r5==1 & r4==1  ] <- 71   # Young Mixed spruce/other/birch

r6[r1 == 4 & r4 ==3 & r2==2  ] <- 72  # Young Mixed birch/Spruce
r6[r1 == 4 & r4 ==3 & r3==1  & r2==1] <- 73   # Young Mixed birch/spruce/pine
r6[r1 == 4 & r4 ==3 & r5==1  & r2==1] <- 74  # Young Mixed birch/spruce/other
r6[r1 == 4 & r4 ==3 & r3==2  ] <- 75   # Young Mixed Birch/pine
r6[r1 == 4 & r4 ==3 & r5==2 ] <-76   # Young Mixed birch/other


r6[r1 == 4 & r5 ==3 & r2==2  ] <- 77   # Young Mixed other/Spruce
r6[r1 == 4 & r5 ==3 & r3==1  & r2==1] <- 78   # Young Mixed other/spruce/pine
r6[r1 == 4 & r5 ==3 & r4==1  & r2==1] <- 79  # Young Mixed other/spruce/birch
r6[r1 == 4 & r5 ==3 & r3==2  ] <- 80   # Young Mixed other/pine
r6[r1 == 4 & r5 ==3 & r4==2 ] <-81   # Young Mixed other/birch

r6[r1 == 4 & r2==1 & r3==1 & r4==1 & r5==1 ] <- 82   # Young Mixed spruce/pine/dec

#writeRaster(r6, filename= ("Initial community.tif"), format="GTiff", overwrite=TRUE)


#Old
r6[r1 == 5 & r2 ==4 ] <- 83    # Young spruce
r6[r1 == 5 & r3 ==4 ] <- 84    # Young Pine
r6[r1 == 5 & r4 ==4 ] <- 85    # Young Birch
r6[r1 == 5 & r5 ==4 ] <- 86    # Young other

r6[r1 == 5 & r2 ==2 & r3==2 ] <- 128    # Young spruce/pine equel
r6[r1 == 5 & r2 ==2 & r4==2 ] <- 129
r6[r1 == 5 & r2 ==2 & r5==2 ] <- 130
r6[r1 == 5 & r3 ==2 & r4==2 ] <- 131
r6[r1 == 5 & r3 ==2 & r5==2 ] <- 132
r6[r1 == 5 & r4 ==2 & r5==2 ] <- 133

r6[r1 == 5 & r2 ==2 & r3==1 & r4==1 & r5==1] <- 146   # Young Mixed spruce/pine/birch
r6[r1 == 5 & r3 ==2 & r2==1 & r5==1 & r4==1] <- 147  # Young Mixed spruce/pine/other
r6[r1 == 5 & r4 ==2 & r5==1 & r3==1 & r2==1 ] <- 148   # Young Mixed spruce/other/birch
r6[r1 == 5 & r5 ==2 & r2==1  & r4==1 & r3==1] <- 149   # Young Mixed pine/spruce/birch

r6[r1 == 5 & r2 ==3 & r3==2 ] <- 87   # Young Mixed SPRUcE/Pine
r6[r1 == 5 & r2 ==3 & r4==2  ] <- 88   # Young Mixed spruce/birch
r6[r1 == 5 & r2 ==3 & r5==2  ] <- 89   # Young Mixed spruce/other
r6[r1 == 5 & r2 ==3 & r3==1 & r4==1] <- 90   # Young Mixed spruce/pine/birch
r6[r1 == 5 & r2 ==3 & r3==1 & r5==1] <- 91  # Young Mixed spruce/pine/other
r6[r1 == 5 & r2 ==3 & r5==1 & r4==1  ] <- 92   # Young Mixed spruce/other/birch

r6[r1 == 5 & r3 ==3 & r2==2 ] <- 93   # Young Mixed Pine/Spruce
r6[r1 == 5 & r3 ==3 & r2==1  & r4==1] <- 94   # Young Mixed pine/spruce/birch
r6[r1 == 5 & r3 ==3 & r2==1  & r5==1] <- 95  # Young Mixed pine/spruce/other
r6[r1 == 5 & r3 ==3 & r4==2  ] <- 96   # Young Mixed pine/birch
r6[r1 == 5 & r3 ==3 & r5==2  ] <- 97   # Young Mixed pine/other
r6[r1 == 5 & r3 ==3 & r5==1 & r4==1  ] <- 98   # Young Mixed spruce/other/birch

r6[r1 == 5 & r4 ==3 & r2==2  ] <- 99  # Young Mixed birch/Spruce
r6[r1 == 5 & r4 ==3 & r3==1  & r2==1] <- 100   # Young Mixed birch/spruce/pine
r6[r1 == 5 & r4 ==3 & r5==1  & r2==1] <- 101  # Young Mixed birch/spruce/other
r6[r1 == 5 & r4 ==3 & r3==2  ] <- 102   # Young Mixed Birch/pine
r6[r1 == 5 & r4 ==3 & r5==2 ] <-103   # Young Mixed birch/other


r6[r1 == 5 & r5 ==3 & r2==2  ] <- 104   # Young Mixed other/Spruce
r6[r1 == 5 & r5 ==3 & r3==1  & r2==1] <- 105   # Young Mixed other/spruce/pine
r6[r1 == 5 & r5 ==3 & r4==1  & r2==1] <- 106  # Young Mixed other/spruce/birch
r6[r1 == 5 & r5 ==3 & r3==2  ] <- 107   # Young Mixed other/pine
r6[r1 == 5 & r5 ==3 & r4==2 ] <-108   # Young Mixed other/birch

r6[r1 == 5 & r2==1 & r3==1 & r4==1 & r5==1 ] <- 109   # Young Mixed spruce/pine/dec

writeRaster(r6, filename = file.path(output_directory, "Initial.community.tif"), overwrite = TRUE, datatype = 'INT1U')