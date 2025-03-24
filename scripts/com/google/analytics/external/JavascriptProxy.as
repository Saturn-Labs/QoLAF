package com.google.analytics.external {
	import com.google.analytics.debug.DebugConfiguration;
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	
	public class JavascriptProxy {
		public static var hasProperty_js:XML = <script>
                <![CDATA[
                    function( path )
                    {
                        var paths;
                        if( path.indexOf(".") > 0 )
                        {
                            paths = path.split(".");
                        }
                        else
                        {
                            paths = [path];
                        }
                        var target = window ;
                        var len    = paths.length ;
                        for( var i = 0 ; i < len ; i++ )
                        {
                            target = target[ paths[i] ] ;
                        }
                        if( target )
                        {
                            return true;
                        }
                        else
                        {
                            return false;
                        }
                    }
                ]]>
            </script>;
		
		public static var setProperty_js:XML = <script>
                <![CDATA[
                    function( path , value )
                    {
                        var paths;
                        var prop;
                        if( path.indexOf(".") > 0 )
                        {
                            paths = path.split(".");
                            prop  = paths.pop() ;
                        }
                        else
                        {
                            paths = [];
                            prop  = path;
                        }
                        var target = window ;
                        var len    = paths.length ;
                        for( var i = 0 ; i < len ; i++ )
                        {
                            target = target[ paths[i] ] ;
                        }

                        target[ prop ] = value ;
                    }
                ]]>
            </script>;
		
		public static var setPropertyRef_js:XML = <script>
                <![CDATA[
                    function( path , target )
                    {
                        var paths;
                        var prop;
                        if( path.indexOf(".") > 0 )
                        {
                            paths = path.split(".");
                            prop  = paths.pop() ;
                        }
                        else
                        {
                            paths = [];
                            prop  = path;
                        }
                        alert( "paths:"+paths.length+", prop:"+prop );
                        var targets;
                        var name;
                        if( target.indexOf(".") > 0 )
                        {
                            targets = target.split(".");
                            name    = targets.pop();
                        }
                        else
                        {
                            targets = [];
                            name    = target;
                        }
                        alert( "targets:"+targets.length+", name:"+name );
                        var root = window;
                        var len  = paths.length;
                        for( var i = 0 ; i < len ; i++ )
                        {
                            root = root[ paths[i] ] ;
                        }
                        var ref   = window;
                        var depth = targets.length;
                        for( var j = 0 ; j < depth ; j++ )
                        {
                            ref = ref[ targets[j] ] ;
                        }
                        root[ prop ] = ref[name] ;
                    }
                ]]>
            </script>;
		
		private var _debug:DebugConfiguration;
		
		private var _notAvailableWarning:Boolean = true;
		
		public function JavascriptProxy(debug:DebugConfiguration) {
			super();
			this._debug = debug;
		}
		
		public function call(functionName:String, ... rest) : * {
			var output:String = null;
			var args:Array = rest;
			if(this.isAvailable()) {
				try {
					if(this._debug.javascript && this._debug.verbose) {
						output = "";
						output = "Flash->JS: " + functionName;
						output += "( ";
						if(args.length > 0) {
							output += args.join(",");
						}
						output += " )";
						this._debug.info(output);
					}
					args.unshift(functionName);
					return ExternalInterface.call.apply(ExternalInterface,args);
				}
				catch(e:SecurityError) {
					if(_debug.javascript) {
						_debug.warning("ExternalInterface is not allowed.\nEnsure that allowScriptAccess is set to \"always\" in the Flash embed HTML.");
					}
				}
				catch(e:Error) {
					if(_debug.javascript) {
						_debug.warning("ExternalInterface failed to make the call\nreason: " + e.message);
					}
				}
			}
			return null;
		}
		
		public function executeBlock(data:String) : void {
			if(this.isAvailable()) {
				try {
					ExternalInterface.call(data);
				}
				catch(e:SecurityError) {
					if(_debug.javascript) {
						_debug.warning("ExternalInterface is not allowed.\nEnsure that allowScriptAccess is set to \"always\" in the Flash embed HTML.");
					}
				}
				catch(e:Error) {
					if(_debug.javascript) {
						_debug.warning("ExternalInterface failed to make the call\nreason: " + e.message);
					}
				}
			}
		}
		
		public function getProperty(name:String) : * {
			return this.call(name + ".valueOf");
		}
		
		public function getPropertyString(name:String) : String {
			return this.call(name + ".toString");
		}
		
		public function hasProperty(path:String) : Boolean {
			return this.call(hasProperty_js,path);
		}
		
		public function isAvailable() : Boolean {
			var _local1:Boolean = ExternalInterface.available;
			if(_local1 && Capabilities.playerType == "External") {
				_local1 = false;
			}
			if(!_local1 && this._debug.javascript && this._notAvailableWarning) {
				this._debug.warning("ExternalInterface is not available.");
				this._notAvailableWarning = false;
			}
			return _local1;
		}
		
		public function setProperty(path:String, value:*) : void {
			this.call(setProperty_js,path,value);
		}
		
		public function setPropertyByReference(path:String, target:String) : void {
			this.call(setPropertyRef_js,path,target);
		}
	}
}

