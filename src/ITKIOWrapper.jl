module ITKIOWrapper
using CxxWrap
using ITKIOWrapper_jll

export loadSpatialMetaData, loadVoxelData

include("DataStructs.jl")


@wrapmodule(()->ITKIOWrapper_jll.libITKIOWrapper_path)

function __init__()
@initcxx
end

function loadSpatialMetaData(filePath::String)

  img = ITKImageWrapper(filePath, isdir(filePath)) #second argument is "isDicom"
  imgOrigin = Tuple(Float64.(getOrigin(img)))
  imgSpacing = Tuple(Float64.(getSpacing(img)))
  imgSize = Tuple(Int64.(getSize(img)))
  imgDirection = NTuple{9,Float64}(map(Float64, getDirection(img)))

  return DataStructs.SpatialMetaData(imgOrigin, imgSpacing, imgSize, imgDirection)
end

function loadVoxelData(filePath::String, spatMeta::DataStructs.SpatialMetaData)
  img = ITKImageWrapper(filePath, isdir(filePath))
  ITKIOWrapper.reorientToLPS(img)
  voxelData = reshape(getPixelData(img), spatMeta.size)
  return DataStructs.VoxelData(voxelData)
end


greet() = print("Hello from ITKIOWrapper.jl!")

end # module ITKIOWrapper
