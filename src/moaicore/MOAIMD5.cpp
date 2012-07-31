// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#include "pch.h"
#include <moaicore/MOAIMD5.h>
#include <openssl/md5.h>
//================================================================//
// local
//================================================================//

//----------------------------------------------------------------//
MOAIMD5::MOAIMD5 () {
	
	RTTI_SINGLE ( MOAIMD5 )

}

//----------------------------------------------------------------//
MOAIMD5::~MOAIMD5 () {

}

//----------------------------------------------------------------//
void MOAIMD5::RegisterLuaClass ( MOAILuaState& state ) {
	
}

//----------------------------------------------------------------//
void MOAIMD5::RegisterLuaFuncs ( MOAILuaState& state ) {
	luaL_Reg regTable [] = {
		{ "hash",			_hash },
		{ NULL, NULL }
	};
	
	luaL_register ( state, 0, regTable );
}

int MOAIMD5::_hash ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIMD5, "US" )
	
	cc8* hashin		= state.GetValue < cc8* >( 2, "" );

	unsigned char md5out[32];
	char md5str[33];
	MD5((const unsigned char*)hashin, strlen(hashin), (unsigned char*)&md5out[0]);
	char hexval[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
	for(unsigned int i = 0; i < 32; i++)
	{
		unsigned char c = md5out[i/2];

		if((i%2) == 0)
			c = (c >> 4);

		c = (c&0xf);
		md5str[i] = hexval[c];
	}
	md5str[32] = 0;
	lua_pushlstring ( state, ( cc8* )md5str, 32 );

	return 1;
}
