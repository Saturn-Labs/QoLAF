package com.google.analytics.data {
	public interface Cookie {
		function get creation() : Date;
		
		function set creation(value:Date) : void;
		
		function get expiration() : Date;
		
		function set expiration(value:Date) : void;
		
		function isExpired() : Boolean;
		
		function toURLString() : String;
		
		function fromSharedObject(data:Object) : void;
		
		function toSharedObject() : Object;
	}
}

