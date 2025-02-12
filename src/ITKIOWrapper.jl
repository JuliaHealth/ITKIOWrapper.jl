module ITKIOWrapper
using CxxWrap
using ITKIOWrapper_jll
export load_spatial_metadata, load_voxel_data, load_image, output_image
include("DataStructs.jl")

@wrapmodule(()->ITKIOWrapper_jll.libITKIOWrapper_path)

function __init__()
    @initcxx
end

function load_image(filePath::String)
    image = ITKImageWrapper(filePath, isdir(filePath))
    reorientToLPS(image)  # Use dot notation
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

greet() = print("Hello from ITKIOWrapper.jl!")

end # module ITKIOWrapper

