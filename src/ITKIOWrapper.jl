module ITKIOWrapper
using CxxWrap
using ITKIOWrapper_jll
export load_spatial_metadata, load_voxel_data, load_image, output_image, create_image, save_image
export DataStructs

include("DataStructs.jl")

@wrapmodule(()->ITKIOWrapper_jll.libITKIOWrapper_path)

function __init__()
    @initcxx
end

function load_image(filePath::String)
    image = ITKImageWrapper(filePath, isdir(filePath))
    reorientToLPS(image)
    return image
end

function output_image(src::String, outputFilename::String, isDicomOutput::Bool=false)
    img = ITKImageWrapper(src, isdir(src))
    reorientToLPS(img)
    if isDicomOutput
        mkpath(outputFilename)
    end
    writeImage(img, outputFilename, isDicomOutput)
end
    
function load_spatial_metadata(img::ITKImageWrapper)  # Remove Allocated suffix
    imgOrigin = Tuple(Float64.(getOrigin(img)))
    imgSpacing = Tuple(Float64.(getSpacing(img)))
    imgSize = Tuple(Int64.(getSize(img)))
    imgDirection = NTuple{9,Float64}(map(Float64, getDirection(img)))
    return DataStructs.SpatialMetaData(imgOrigin, imgSpacing, imgSize, imgDirection)
end

function load_voxel_data(img::ITKImageWrapper, spatMeta::DataStructs.SpatialMetaData)  # Remove Allocated suffix
    voxelData = reshape(getPixelData(img), spatMeta.size)
    return DataStructs.VoxelData(voxelData)
end


"""
    save_image(voxel_data::DataStructs.VoxelData, metadata::DataStructs.SpatialMetaData, 
              output_path::String, is_dicom::Bool=false)
    
Save voxel data and metadata to a NIfTI file or DICOM series.
"""
function save_image(voxel_data::DataStructs.VoxelData, metadata::DataStructs.SpatialMetaData, 
                   output_path::String, is_dicom::Bool=false)
    # Debug output
    println("Saving image from voxel data and metadata")
    println("Data shape: ", size(voxel_data.dat))
    println("Metadata size: ", metadata.size)
    
    # Convert Julia arrays to C++ vectors using CxxWrap's StdVector
    flat_data = CxxWrap.StdVector{Float32}(vec(Float32.(voxel_data.dat)))
    origin_vec = CxxWrap.StdVector{Float64}(collect(metadata.origin))
    spacing_vec = CxxWrap.StdVector{Float64}(collect(metadata.spacing))
    size_vec = CxxWrap.StdVector{Int64}(collect(metadata.size))
    direction_vec = CxxWrap.StdVector{Float64}(collect(metadata.direction))
    
    # Print data for debugging
    println("Data length: ", length(flat_data))
    println("Expected size: ", prod(metadata.size))
    
    # If saving as DICOM, ensure the directory exists
    if is_dicom
        mkpath(output_path)
    end
    
    # Use the standalone function with proper CxxWrap types
    create_and_save_image(flat_data, origin_vec, spacing_vec, size_vec, direction_vec, output_path, is_dicom)
    
    return nothing
end


greet() = print("Hello from ITKIOWrapper.jl!")

end # module ITKIOWrapper

