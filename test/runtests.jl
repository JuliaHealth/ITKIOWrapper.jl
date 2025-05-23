using ITKIOWrapper
using CxxWrap # Make sure to explicitly import CxxWrap

# Create synthetic test data
function create_test_volume(size_x=64, size_y=64, size_z=10)
    # Create a 3D volume with a sphere in it
    voxel_array = zeros(Float32, size_x, size_y, size_z)
    
    # Add a sphere
    for x in 1:size_x, y in 1:size_y, z in 1:size_z
        dx = x - size_x/2
        dy = y - size_y/2
        dz = z - size_z/2
        dist = sqrt(dx^2 + dy^2 + dz^2)
        if dist < min(size_x, size_y, size_z)/4
            voxel_array[x, y, z] = 1000.0f0
        end
    end
    
    # Add some intensity gradient
    for z in 1:size_z
        voxel_array[:, :, z] .+= 100.0f0 * z/size_z
    end
    
    return voxel_array
end

# Test 1: Create and save a synthetic volume as NIfTI
function test_nifti_save_load()
    println("=== Testing NIfTI Save and Load ===")
    
    # Parameters
    size_x, size_y, size_z = 64, 64, 10
    
    # Create test data
    voxel_array = create_test_volume(size_x, size_y, size_z)
    
    # Create metadata
    metadata = DataStructs.SpatialMetaData(
        (0.0, 0.0, 0.0),           # origin
        (1.0, 1.0, 2.5),           # spacing
        (size_x, size_y, size_z),  # size
        (-1.0, 0.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 1.0)  # direction (LPS)
    )
    
    # Create voxel data struct
    voxel_data = DataStructs.VoxelData(voxel_array)
    
    # Save as NIfTI
    output_path = "test_sphere.nii.gz"
    println("Saving to: $output_path")
    save_image(voxel_data, metadata, output_path)
    
    # Load the saved image
    println("Loading saved image")
    loaded_img = load_image(output_path)
    
    # Extract metadata and voxel data
    loaded_metadata = load_spatial_metadata(loaded_img)
    loaded_voxel_data = load_voxel_data(loaded_img, loaded_metadata)
    
    # Compare
    println("Comparing original and loaded data")
    println("Original origin: $(metadata.origin)")
    println("Loaded origin: $(loaded_metadata.origin)")
    
    println("Original spacing: $(metadata.spacing)")
    println("Loaded spacing: $(loaded_metadata.spacing)")
    
    println("Original size: $(metadata.size)")
    println("Loaded size: $(loaded_metadata.size)")
    
    # Check a few voxel values
    center_x, center_y, center_z = Int.(round.([size_x, size_y, size_z] ./ 2))
    println("Original center voxel value: $(voxel_array[center_x, center_y, center_z])")
    println("Loaded center voxel value: $(loaded_voxel_data.dat[center_x, center_y, center_z])")
    
    return loaded_voxel_data, loaded_metadata
end

# Run the test
test_nifti_save_load()