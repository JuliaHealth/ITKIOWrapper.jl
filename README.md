# ITKIOWrapper.jl

A Julia wrapper for the Insight Toolkit (ITK) medical image I/O functionality. This package provides simple interfaces to load, manipulate, and save medical imaging files in formats like NIFTI and DICOM.

## Installation

```julia
import Pkg
Pkg.add("ITKIOWrapper")
```

## Basic Usage

```julia
using ITKIOWrapper
```

## Image Loading and Metadata Extraction

### Loading NIFTI Files

```julia
# Load a NIFTI image
nifti_image = load_image("./example_file.nii.gz")

# Extract spatial metadata
metadata = load_spatial_metadata(nifti_image)

# Access metadata components
metadata.origin     # Physical coordinates of the first voxel (x, y, z)
metadata.spacing    # Size of each voxel in physical units (mm)
metadata.size       # Dimensions of the image in voxels (x, y, z)
metadata.direction  # 3x3 Direction cosine matrix (stored as 9-tuple)
```

### Loading DICOM Series

```julia
# Load a DICOM series from directory
dicom_image = load_image("./example_dicom_series")  # Pass directory path

# Extract spatial metadata
metadata = load_spatial_metadata(dicom_image)

# Access metadata components (same as NIFTI)
metadata.origin
metadata.spacing
metadata.size
metadata.direction
```

## Accessing Voxel Data

```julia
# Load image
img = load_image("./sample.nii.gz")

# Get metadata
metadata = load_spatial_metadata(img)

# Extract actual voxel data
voxelData = load_voxel_data(img, metadata)

# Access the underlying array
voxelData.dat  # Julia array with dimensions matching metadata.size
```

## Image Conversion and Output

### NIFTI to NIFTI Conversion

```julia
# Convert NIFTI to NIFTI
dicom_nifti_conversion("./source_file.nii.gz", "./output_file.nii.gz", false)
```

### DICOM to NIFTI Conversion

```julia
# Convert DICOM series to NIFTI
dicom_nifti_conversion("./source_dicom_series", "./output_file.nii.gz", false)
```

### NIFTI to DICOM Conversion

```julia
# Convert NIFTI to DICOM series (creates a directory with DICOM files)
dicom_nifti_conversion("./source_file.nii.gz", "./output_dicom_series", true)
```

## Creating and Saving New Images

```julia
# Create voxel data (e.g., 3D array of Float32)
voxel_array = zeros(Float32, 64, 64, 10)

# Add a sphere in the center
center_x, center_y, center_z = 32, 32, 5
radius = 10
for x in 1:64, y in 1:64, z in 1:10
    dx = x - center_x
    dy = y - center_y
    dz = z - center_z
    if sqrt(dx^2 + dy^2 + dz^2) < radius
        voxel_array[x, y, z] = 1000.0f0
    end
end

# Create metadata
metadata = DataStructs.SpatialMetaData(
    (0.0, 0.0, 0.0),       # origin
    (1.0, 1.0, 2.5),       # spacing (mm)
    (64, 64, 10),          # size (voxels)
    (-1.0, 0.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 1.0)  # direction (LPS orientation)
)

# Create voxel data struct
voxel_data = DataStructs.VoxelData(voxel_array)

# Save as NIFTI
save_image(voxel_data, metadata, "new_volume.nii.gz", false)

# Save as DICOM series
save_image(voxel_data, metadata, "new_dicom_series", true)
```

## Function Reference

### `load_image(filePath::String)`
Loads a medical image from a file path. Returns an ITKImageWrapper object.
- For NIFTI: pass the file path
- For DICOM: pass the directory path containing the series

### `load_spatial_metadata(img::ITKImageWrapper)`
Extracts spatial metadata from an ITKImageWrapper. Returns a `SpatialMetaData` struct.

### `load_voxel_data(img::ITKImageWrapper, spatMeta::SpatialMetaData)`
Extracts voxel data from an ITKImageWrapper using the provided metadata. Returns a `VoxelData` struct.

### `dicom_nifti_conversion(src::String, outputFilename::String, isDicomOutput::Bool=false)`
Loads an image from `src` and writes it to `outputFilename` in either NIFTI or DICOM format.
- Set `isDicomOutput=true` to output as DICOM series

### `save_image(voxel_data::VoxelData, metadata::SpatialMetaData, output_path::String, is_dicom::Bool=false)`
Creates and saves a new image from voxel data and metadata.
- For DICOM output: set `is_dicom=true` and `output_path` to a directory

## Data Structures

### `SpatialMetaData`
Contains geometric information about the image:
- `origin`: Tuple{Float64, Float64, Float64} - Physical coordinates of the first voxel
- `spacing`: Tuple{Float64, Float64, Float64} - Size of each voxel in mm
- `size`: Tuple{Int64, Int64, Int64} - Dimensions of the image in voxels
- `direction`: NTuple{9, Float64} - 3x3 direction cosine matrix stored as 9-tuple

### `VoxelData`
Contains the actual image data:
- `dat`: Multidimensional array containing the voxel values

## Advanced Examples

### Resampling an Image (with ITK)

```julia
# Load source image
source_img = load_image("source.nii.gz")
source_metadata = load_spatial_metadata(source_img)
source_data = load_voxel_data(source_img, source_metadata)

# Define new image specifications (2x resolution in all dimensions)
new_spacing = (
    source_metadata.spacing[1] / 2,
    source_metadata.spacing[2] / 2, 
    source_metadata.spacing[3] / 2
)
new_size = (
    source_metadata.size[1] * 2,
    source_metadata.size[2] * 2,
    source_metadata.size[3] * 2
)

# Create new metadata
new_metadata = DataStructs.SpatialMetaData(
    source_metadata.origin,
    new_spacing,
    new_size,
    source_metadata.direction
)

# Create and save (through custom code using ITK's resampling functions)
# ... your resampling code here ...

# Save the resampled image
save_image(resampled_data, new_metadata, "resampled.nii.gz")
```

## Notes

- All images are automatically reoriented to LPS (Left-Posterior-Superior) coordinate system when loaded
- The library handles both NIFTI (.nii, .nii.gz) and DICOM series inputs and outputs
- This package requires ITK to be installed via the ITKIOWrapper_jll dependency