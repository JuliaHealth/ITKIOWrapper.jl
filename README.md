ITKIOWrapper.jl provides wrapper functions in Julia from the InsightToolkit Image Registration functions.

Usage::

```
using ITKIOWrapper
```

## Loading Spatial meta data from an image file path:  
> [!NOTE]
> NIFTI
```
nifti_image = load_image("./example_file.nii.gz")
metadata = load_spatial_metadata(nifti_image)

metadata.origin
metadata.spacing
metadata.size
metadata.direction
```

> [!NOTE]
> DICOM
```
dicom_image = load_image("./example_dicom_series")
metadata = load_spatial_metadata(dicom_image)

metadata.origin
metadata.spacing
metadata.size
metadata.direction
```

## Writing Images - Nifti To Nifti 
```
output_image("./source_file.nii.gz", "./output_new_example_file.nii.gz",false)
```

## Writing Images - Dicom To Nifti
```
output_image("./source_dicom_series", "./output_new_example_file.nii.gz", false)
```

## Loading Voxel data from an image file path and spatial meta data

```
img = load_image("./sample.nii.gz")
metadata = load_spatial_metadata(img)
voxelData = load_voxel_data(img, metadata)
voxelData.dat
```



