// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#ifndef	MOAI_MD5_H
#define	MOAI_MD5_H

#include <moaicore/MOAILua.h>

class MOAIMD5 :
	public MOAILuaObject {
protected:
	
	
	static int _hash ( lua_State* L );

public:
	
	DECL_LUA_FACTORY ( MOAIMD5 )
					MOAIMD5		();
					~MOAIMD5		();
	void			RegisterLuaClass		( MOAILuaState& state );
	void			RegisterLuaFuncs		( MOAILuaState& state );
};

#endif
