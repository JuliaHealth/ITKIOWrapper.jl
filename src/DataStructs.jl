module DataStructs

export SpatialMetaData, VoxelData

struct SpatialMetaData
  origin::Tuple{Float64,Float64, Float64}
  spacing::Tuple{Float64,Float64, Float64}
  size::Tuple{Int64, Int64, Int64}
  direction :: NTuple{9,Float64}
end

struct VoxelData
  dat
end

end
