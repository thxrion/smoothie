ffi.cdef[[
      typedef struct {
            float x;
            float y;
            float z;
      } CVector;
]]

ffi.cdef[[
      typedef struct {
            CVector position;
            float heading;
      } CSimpleTransform;
]]

ffi.cdef[[
      typedef struct {
            void* __vtable;
            CSimpleTransform placement;
            void* matrix;
      } CPlaceable;
]]

ffi.cdef[[
      typedef struct {
            char _pad1[12];
            unsigned short mode;
            char _pad2[158];
            float verticalAngle;
            char _pad3[12];
            float horizontalAngle;
            char _pad4[376];
      } CCam;
]]

ffi.cdef[[
      typedef struct {
            CPlaceable base;
            char _pad1[348];
            CCam aCams[3];
            char _pad2[1372];
      } CCamera;
]]
