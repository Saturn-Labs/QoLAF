package com.google.analytics.core {
	import com.google.analytics.debug.DebugConfiguration;
	import com.google.analytics.debug.VisualDebugMode;
	import com.google.analytics.utils.Environment;
	import com.google.analytics.utils.Variables;
	import com.google.analytics.v4.Configuration;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	public class GIFRequest {
		private static const MAX_REQUEST_LENGTH:Number = 2048;
		
		private var _config:Configuration;
		
		private var _debug:DebugConfiguration;
		
		private var _buffer:Buffer;
		
		private var _info:Environment;
		
		private var _utmac:String;
		
		private var _lastRequest:URLRequest;
		
		private var _count:int;
		
		private var _alertcount:int;
		
		private var _requests:Array;
		
		public function GIFRequest(config:Configuration, debug:DebugConfiguration, buffer:Buffer, info:Environment) {
			super();
			this._config = config;
			this._debug = debug;
			this._buffer = buffer;
			this._info = info;
			this._count = 0;
			this._alertcount = 0;
			this._requests = [];
		}
		
		public function get utmac() : String {
			return this._utmac;
		}
		
		public function get utmwv() : String {
			return this._config.version;
		}
		
		public function get utmn() : String {
			return String(generate32bitRandom());
		}
		
		public function get utmhn() : String {
			return this._info.documentDomainName;
		}
		
		public function get utmsp() : String {
			return this._config.sampleRate * 100 as String;
		}
		
		public function get utmcc() : String {
			var _local1:Array = [];
			if(this._buffer.hasUTMA()) {
				_local1.push(this._buffer.utma.toURLString() + ";");
			}
			if(this._buffer.hasUTMZ()) {
				_local1.push(this._buffer.utmz.toURLString() + ";");
			}
			if(this._buffer.hasUTMV()) {
				_local1.push(this._buffer.utmv.toURLString() + ";");
			}
			return _local1.join("+");
		}
		
		public function updateToken() : void {
			var _local2:Number = NaN;
			var _local1:Number = Number(new Date().getTime());
			_local2 = (_local1 - this._buffer.utmb.lastTime) * (this._config.tokenRate / 1000);
			if(this._debug.verbose) {
				this._debug.info("tokenDelta: " + _local2,VisualDebugMode.geek);
			}
			if(_local2 >= 1) {
				this._buffer.utmb.token = Math.min(Math.floor(this._buffer.utmb.token + _local2),this._config.bucketCapacity);
				this._buffer.utmb.lastTime = _local1;
				if(this._debug.verbose) {
					this._debug.info(this._buffer.utmb.toString(),VisualDebugMode.geek);
				}
			}
		}
		
		private function _debugSend(request:URLRequest) : void {
			var _local3:String = null;
			var _local2:String = "";
			switch(this._debug.mode) {
				case VisualDebugMode.geek:
					_local2 = "Gif Request #" + this._alertcount + ":\n" + request.url;
					break;
				case VisualDebugMode.advanced:
					_local3 = request.url;
					if(_local3.indexOf("?") > -1) {
						_local3 = _local3.split("?")[0];
					}
					_local3 = this._shortenURL(_local3);
					_local2 = "Send Gif Request #" + this._alertcount + ":\n" + _local3 + " ?";
					break;
				case VisualDebugMode.basic:
				default:
					_local2 = "Send " + this._config.serverMode.toString() + " Gif Request #" + this._alertcount + " ?";
			}
			this._debug.alertGifRequest(_local2,request,this);
			++this._alertcount;
		}
		
		private function _shortenURL(url:String) : String {
			var _local2:Array = null;
			if(url.length > 60) {
				_local2 = url.split("/");
				while(url.length > 60) {
					_local2.shift();
					url = "../" + _local2.join("/");
				}
			}
			return url;
		}
		
		public function onSecurityError(event:SecurityErrorEvent) : void {
			if(this._debug.GIFRequests) {
				this._debug.failure(event.text);
			}
		}
		
		public function onIOError(event:IOErrorEvent) : void {
			var _local2:String = this._lastRequest.url;
			var _local3:String = String(this._requests.length - 1);
			var _local4:String = "Gif Request #" + _local3 + " failed";
			if(this._debug.GIFRequests) {
				if(!this._debug.verbose) {
					if(_local2.indexOf("?") > -1) {
						_local2 = _local2.split("?")[0];
					}
					_local2 = this._shortenURL(_local2);
				}
				if(int(this._debug.mode) > int(VisualDebugMode.basic)) {
					_local4 += " \"" + _local2 + "\" does not exists or is unreachable";
				}
				this._debug.failure(_local4);
			} else {
				this._debug.warning(_local4);
			}
			this._removeListeners(event.target);
		}
		
		public function onComplete(event:Event) : void {
			var _local2:String = event.target.loader.name;
			this._requests[_local2].complete();
			var _local3:String = "Gif Request #" + _local2 + " sent";
			var _local4:String = this._requests[_local2].request.url;
			if(this._debug.GIFRequests) {
				if(!this._debug.verbose) {
					if(_local4.indexOf("?") > -1) {
						_local4 = _local4.split("?")[0];
					}
					_local4 = this._shortenURL(_local4);
				}
				if(int(this._debug.mode) > int(VisualDebugMode.basic)) {
					_local3 += " to \"" + _local4 + "\"";
				}
				this._debug.success(_local3);
			} else {
				this._debug.info(_local3);
			}
			this._removeListeners(event.target);
		}
		
		private function _removeListeners(target:Object) : void {
			target.removeEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
			target.removeEventListener(Event.COMPLETE,this.onComplete);
		}
		
		public function sendRequest(request:URLRequest) : void {
			var loader:Loader;
			var context:LoaderContext;
			if(request.url.length > MAX_REQUEST_LENGTH) {
				this._debug.failure("No request sent. URI length too long.");
				return;
			}
			loader = new Loader();
			loader.name = String(this._count++);
			context = new LoaderContext(false);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComplete);
			this._lastRequest = request;
			this._requests[loader.name] = new RequestObject(request);
			try {
				loader.load(request,context);
			}
			catch(e:Error) {
				_debug.failure("\"Loader.load()\" could not instanciate Gif Request");
			}
		}
		
		public function send(account:String, variables:Variables = null, force:Boolean = false, rateLimit:Boolean = false) : void {
			var _local5:String = null;
			var _local6:URLRequest = null;
			var _local7:URLRequest = null;
			this._utmac = account;
			if(!variables) {
				variables = new Variables();
			}
			variables.URIencode = true;
			variables.pre = ["utmwv","utmn","utmhn","utmt","utme","utmcs","utmsr","utmsc","utmul","utmje","utmfl","utmdt","utmhid","utmr","utmp"];
			variables.post = ["utmcc"];
			if(this._debug.verbose) {
				this._debug.info("tracking: " + this._buffer.utmb.trackCount + "/" + this._config.trackingLimitPerSession,VisualDebugMode.geek);
			}
			if(this._buffer.utmb.trackCount < this._config.trackingLimitPerSession || force) {
				if(rateLimit) {
					this.updateToken();
				}
				if(force || !rateLimit || this._buffer.utmb.token >= 1) {
					if(!force && rateLimit) {
						this._buffer.utmb.token -= 1;
					}
					this._buffer.utmb.trackCount += 1;
					if(this._debug.verbose) {
						this._debug.info(this._buffer.utmb.toString(),VisualDebugMode.geek);
					}
					variables.utmwv = this.utmwv;
					variables.utmn = this.utmn;
					if(this._info.domainName != "") {
						if(variables.utmhn != null || variables.utmhn != "") {
							variables.utmhn = this.utmhn;
						} else {
							variables.utmhn = this._info.documentDomainName;
						}
					}
					if(this._config.sampleRate < 1) {
						variables.utmsp = this._config.sampleRate * 100;
					}
					if(this._config.serverMode == ServerOperationMode.local || this._config.serverMode == ServerOperationMode.both) {
						_local5 = this._info.locationSWFPath;
						if(_local5.lastIndexOf("/") > 0) {
							_local5 = _local5.substring(0,_local5.lastIndexOf("/"));
						}
						_local6 = new URLRequest();
						if(this._config.localGIFpath.indexOf("http") == 0) {
							_local6.url = this._config.localGIFpath;
						} else {
							_local6.url = _local5 + this._config.localGIFpath;
						}
						_local6.url += "?" + variables.toString();
						if(this._debug.active && this._debug.GIFRequests) {
							this._debugSend(_local6);
						} else {
							this.sendRequest(_local6);
						}
					}
					if(this._config.serverMode == ServerOperationMode.remote || this._config.serverMode == ServerOperationMode.both) {
						_local7 = new URLRequest();
						if(this._info.protocol == "https") {
							_local7.url = this._config.secureRemoteGIFpath;
						} else if(this._info.protocol == "http") {
							_local7.url = this._config.remoteGIFpath;
						} else {
							_local7.url = this._config.remoteGIFpath;
						}
						variables.utmac = this.utmac;
						variables.utmcc = this.utmcc;
						_local7.url += "?" + variables.toString();
						if(this._debug.active && this._debug.GIFRequests) {
							this._debugSend(_local7);
						} else {
							this.sendRequest(_local7);
						}
					}
				}
			}
		}
	}
}

