package com.google.analytics.core {
	public function generate32bitRandom() : int {
		return Math.round(Math.random() * 0x7fffffff);
	}
}

