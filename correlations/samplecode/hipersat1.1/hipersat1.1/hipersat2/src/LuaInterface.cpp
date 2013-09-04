#include "LuaInterface.h"

#include "NicMatrix.lci"
#include "SignalOperations.lci"

extern "C"
{
    // code to initialize the lua bindings
    static const struct luaL_Reg hipersatlib_f[] = {
        {"new", construct_NicMatrix},
        {NULL, NULL}
    };

    static const struct luaL_Reg hipersatlib_m[] = {
        {"getVector", getVector_NicMatrix},
        {"setVector", setVector_NicMatrix},
        {"get", get_NicMatrix},
        {"set", set_NicMatrix},
        {"rows", rows_NicMatrix},
        {"columns", columns_NicMatrix},
        {"size", size_NicMatrix},
        {"read", read_NicMatrix},
        {"write", write_NicMatrix},
        {"average", average_NicMatrix},
        {"center", center_NicMatrix},
        {"covariance", covariance_NicMatrix},
        {"copy", copy_NicMatrix},
        {"eigenvalues", eigenvalues_NicMatrix},
        {"__tostring", string_NicMatrix},
        {"__gc", destruct_NicMatrix},
        {NULL, NULL}
    };

    int luaopen_hipersat(lua_State* L)
    {
        luaL_newmetatable(L, "hipersat.nicmatrix");
    
        lua_pushvalue(L, -1); /* duplicates the metatables */
        lua_setfield(L, -1, "__index");
    
        luaL_register(L, NULL, hipersatlib_m);
        luaL_register(L, "nicmatrix", hipersatlib_f);
        return 1;
    }
}