package com.google.analytics.core {
	public function validateAccount(account:String) : Boolean {
		var _local2:RegExp = /^UA-[0-9]*-[0-9]*$/;
		return _local2.test(account);
	}
}

