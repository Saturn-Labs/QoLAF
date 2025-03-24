package starling.utils {
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	import starling.core.Starling;
	import starling.events.EventDispatcher;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.AtfData;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.textures.TextureOptions;
	
	public class AssetManager extends EventDispatcher {
		private static const HTTP_RESPONSE_STATUS:String = "httpResponseStatus";
		
		private static var sNames:Vector.<String> = new Vector.<String>(0);
		
		private static const NAME_REGEX:RegExp = /([^\?\/\\]+?)(?:\.([\w\-]+))?(?:\?.*)?$/;
		
		private var _starling:Starling;
		
		private var _numLostTextures:int;
		
		private var _numRestoredTextures:int;
		
		private var _numLoadingQueues:int;
		
		private var _defaultTextureOptions:TextureOptions;
		
		private var _checkPolicyFile:Boolean;
		
		private var _keepAtlasXmls:Boolean;
		
		private var _keepFontXmls:Boolean;
		
		private var _numConnections:int;
		
		private var _verbose:Boolean;
		
		private var _queue:Array;
		
		private var _textures:Dictionary;
		
		private var _atlases:Dictionary;
		
		private var _sounds:Dictionary;
		
		private var _xmls:Dictionary;
		
		private var _objects:Dictionary;
		
		private var _byteArrays:Dictionary;
		
		public function AssetManager(scaleFactor:Number = 1, useMipmaps:Boolean = false) {
			super();
			_defaultTextureOptions = new TextureOptions(scaleFactor,useMipmaps);
			_textures = new Dictionary();
			_atlases = new Dictionary();
			_sounds = new Dictionary();
			_xmls = new Dictionary();
			_objects = new Dictionary();
			_byteArrays = new Dictionary();
			_numConnections = 3;
			_verbose = true;
			_queue = [];
		}
		
		public function dispose() : void {
			for each(var _local1 in _textures) {
				_local1.dispose();
			}
			for each(var _local2 in _atlases) {
				_local2.dispose();
			}
			for each(var _local3 in _xmls) {
				System.disposeXML(_local3);
			}
			for each(var _local4 in _byteArrays) {
				_local4.clear();
			}
		}
		
		public function getTexture(name:String) : Texture {
			var _local3:Texture = null;
			if(name in _textures) {
				return _textures[name];
			}
			for each(var _local2 in _atlases) {
				_local3 = _local2.getTexture(name);
				if(_local3) {
					return _local3;
				}
			}
			return null;
		}
		
		public function getTextures(prefix:String = "", out:Vector.<Texture> = null) : Vector.<Texture> {
			if(out == null) {
				out = new Vector.<Texture>(0);
			}
			for each(var _local3 in getTextureNames(prefix,sNames)) {
				out[out.length] = getTexture(_local3);
			}
			sNames.length = 0;
			return out;
		}
		
		public function getTextureNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String> {
			out = getDictionaryKeys(_textures,prefix,out);
			for each(var _local3 in _atlases) {
				_local3.getNames(prefix,out);
			}
			out.sort(1);
			return out;
		}
		
		public function getTextureAtlas(name:String) : TextureAtlas {
			return _atlases[name] as TextureAtlas;
		}
		
		public function getTextureAtlasNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String> {
			return getDictionaryKeys(_atlases,prefix,out);
		}
		
		public function getSound(name:String) : Sound {
			return _sounds[name];
		}
		
		public function getSoundNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String> {
			return getDictionaryKeys(_sounds,prefix,out);
		}
		
		public function playSound(name:String, startTime:Number = 0, loops:int = 0, transform:SoundTransform = null) : SoundChannel {
			if(name in _sounds) {
				return getSound(name).play(startTime,loops,transform);
			}
			return null;
		}
		
		public function getXml(name:String) : XML {
			return _xmls[name];
		}
		
		public function getXmlNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String> {
			return getDictionaryKeys(_xmls,prefix,out);
		}
		
		public function getObject(name:String) : Object {
			return _objects[name];
		}
		
		public function getObjectNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String> {
			return getDictionaryKeys(_objects,prefix,out);
		}
		
		public function getByteArray(name:String) : ByteArray {
			return _byteArrays[name];
		}
		
		public function getByteArrayNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String> {
			return getDictionaryKeys(_byteArrays,prefix,out);
		}
		
		public function addTexture(name:String, texture:Texture) : void {
			log("Adding texture \'" + name + "\'");
			if(name in _textures) {
				log("Warning: name was already in use; the previous texture will be replaced.");
				_textures[name].dispose();
			}
			_textures[name] = texture;
		}
		
		public function addTextureAtlas(name:String, atlas:TextureAtlas) : void {
			log("Adding texture atlas \'" + name + "\'");
			if(name in _atlases) {
				log("Warning: name was already in use; the previous atlas will be replaced.");
				_atlases[name].dispose();
			}
			_atlases[name] = atlas;
		}
		
		public function addSound(name:String, sound:Sound) : void {
			log("Adding sound \'" + name + "\'");
			if(name in _sounds) {
				log("Warning: name was already in use; the previous sound will be replaced.");
			}
			_sounds[name] = sound;
		}
		
		public function addXml(name:String, xml:XML) : void {
			log("Adding XML \'" + name + "\'");
			if(name in _xmls) {
				log("Warning: name was already in use; the previous XML will be replaced.");
				System.disposeXML(_xmls[name]);
			}
			_xmls[name] = xml;
		}
		
		public function addObject(name:String, object:Object) : void {
			log("Adding object \'" + name + "\'");
			if(name in _objects) {
				log("Warning: name was already in use; the previous object will be replaced.");
			}
			_objects[name] = object;
		}
		
		public function addByteArray(name:String, byteArray:ByteArray) : void {
			log("Adding byte array \'" + name + "\'");
			if(name in _byteArrays) {
				log("Warning: name was already in use; the previous byte array will be replaced.");
				_byteArrays[name].clear();
			}
			_byteArrays[name] = byteArray;
		}
		
		public function removeTexture(name:String, dispose:Boolean = true) : void {
			log("Removing texture \'" + name + "\'");
			if(dispose && name in _textures) {
				_textures[name].dispose();
			}
			delete _textures[name];
		}
		
		public function removeTextureAtlas(name:String, dispose:Boolean = true) : void {
			log("Removing texture atlas \'" + name + "\'");
			if(dispose && name in _atlases) {
				_atlases[name].dispose();
			}
			delete _atlases[name];
		}
		
		public function removeSound(name:String) : void {
			log("Removing sound \'" + name + "\'");
			delete _sounds[name];
		}
		
		public function removeXml(name:String, dispose:Boolean = true) : void {
			log("Removing xml \'" + name + "\'");
			if(dispose && name in _xmls) {
				System.disposeXML(_xmls[name]);
			}
			delete _xmls[name];
		}
		
		public function removeObject(name:String) : void {
			log("Removing object \'" + name + "\'");
			delete _objects[name];
		}
		
		public function removeByteArray(name:String, dispose:Boolean = true) : void {
			log("Removing byte array \'" + name + "\'");
			if(dispose && name in _byteArrays) {
				_byteArrays[name].clear();
			}
			delete _byteArrays[name];
		}
		
		public function purgeQueue() : void {
			_queue.length = 0;
			dispatchEventWith("cancel");
		}
		
		public function purge() : void {
			log("Purging all assets, emptying queue");
			purgeQueue();
			dispose();
			_textures = new Dictionary();
			_atlases = new Dictionary();
			_sounds = new Dictionary();
			_xmls = new Dictionary();
			_objects = new Dictionary();
			_byteArrays = new Dictionary();
		}
		
		public function enqueue(... rest) : void {
			var _local3:XML = null;
			var _local4:* = null;
			for each(var _local2 in rest) {
				if(_local2 is Array) {
					enqueue.apply(this,_local2);
				} else if(_local2 is Class) {
					_local3 = describeType(_local2);
					if(_verbose) {
						log("Looking for static embedded assets in \'" + _local3.@name.split("::").pop() + "\'");
					}
					for each(_local4 in _local3.constant.(@type == "Class")) {
						enqueueWithName(_local2[_local4.@name],_local4.@name);
					}
					for each(_local4 in _local3.variable.(@type == "Class")) {
						enqueueWithName(_local2[_local4.@name],_local4.@name);
					}
				} else if(getQualifiedClassName(_local2) == "flash.filesystem::File") {
					if(!_local2["exists"]) {
						log("File or directory not found: \'" + _local2["url"] + "\'");
					} else if(!_local2["isHidden"]) {
						if(_local2["isDirectory"]) {
							enqueue.apply(this,_local2["getDirectoryListing"]());
						} else {
							enqueueWithName(_local2);
						}
					}
				} else if(_local2 is String || _local2 is URLRequest) {
					enqueueWithName(_local2);
				} else {
					log("Ignoring unsupported asset type: " + getQualifiedClassName(_local2));
				}
			}
		}
		
		public function enqueueWithName(asset:Object, name:String = null, options:TextureOptions = null) : String {
			var _local4:String = null;
			if(getQualifiedClassName(asset) == "flash.filesystem::File") {
				_local4 = asset["name"];
				asset = decodeURI(asset["url"]);
			}
			if(name == null) {
				name = getName(asset);
			}
			if(options == null) {
				options = _defaultTextureOptions.clone();
			} else {
				options = options.clone();
			}
			log("Enqueuing \'" + (_local4 || name) + "\'");
			_queue.push({
				"name":name,
				"asset":asset,
				"options":options
			});
			return name;
		}
		
		public function loadQueue(onProgress:Function) : void {
			var PROGRESS_PART_ASSETS:Number;
			var PROGRESS_PART_XMLS:Number;
			var i:int;
			var canceled:Boolean;
			var xmls:Vector.<XML>;
			var assetInfos:Array;
			var assetCount:int;
			var assetProgress:Array;
			var assetIndex:int;
			var loadNextQueueElement:* = function():void {
				var _local1:int = 0;
				if(assetIndex < assetInfos.length) {
					_local1 = assetIndex++;
					loadQueueElement(_local1,assetInfos[_local1]);
				}
			};
			var loadQueueElement:* = function(param1:int, param2:Object):void {
				var onElementProgress:Function;
				var onElementLoaded:Function;
				var index:int = param1;
				var assetInfo:Object = param2;
				if(canceled) {
					return;
				}
				onElementProgress = function(param1:Number):void {
					updateAssetProgress(index,param1 * 0.8);
				};
				onElementLoaded = function():void {
					updateAssetProgress(index,1);
					assetCount--;
					if(assetCount > 0) {
						loadNextQueueElement();
					} else {
						processXmls();
					}
				};
				processRawAsset(assetInfo.name,assetInfo.asset,assetInfo.options,xmls,onElementProgress,onElementLoaded);
			};
			var updateAssetProgress:* = function(param1:int, param2:Number):void {
				assetProgress[param1] = param2;
				var _local4:Number = 0;
				var _local3:int = int(assetProgress.length);
				i = 0;
				while(i < _local3) {
					_local4 += assetProgress[i];
					++i;
				}
				onProgress(_local4 / _local3 * 0.9);
			};
			var processXmls:* = function():void {
				xmls.sort(function(param1:XML, param2:XML):int {
					return param1.localName() == "TextureAtlas" ? -1 : 1;
				});
				setTimeout(processXml,1,0);
			};
			var processXml:* = function(param1:int):void {
				var _local5:String = null;
				var _local3:Texture = null;
				if(canceled) {
					return;
				}
				if(param1 == xmls.length) {
					finish();
					return;
				}
				var _local4:XML = xmls[param1];
				var _local6:String = _local4.localName();
				var _local2:Number = (param1 + 1) / (xmls.length + 1);
				if(_local6 == "TextureAtlas") {
					_local5 = getName(_local4.@imagePath.toString());
					_local3 = getTexture(_local5);
					if(_local3) {
						addTextureAtlas(_local5,new TextureAtlas(_local3,_local4));
						removeTexture(_local5,false);
						if(_keepAtlasXmls) {
							addXml(_local5,_local4);
						} else {
							System.disposeXML(_local4);
						}
					} else {
						log("Cannot create atlas: texture \'" + _local5 + "\' is missing.");
					}
				} else {
					if(_local6 != "font") {
						throw new Error("XML contents not recognized: " + _local6);
					}
					_local5 = getName(_local4.pages.page.@file.toString());
					_local3 = getTexture(_local5);
					if(_local3) {
						log("Adding bitmap font \'" + _local5 + "\'");
						TextField.registerCompositor(new BitmapFont(_local3,_local4),_local5);
						removeTexture(_local5,false);
						if(_keepFontXmls) {
							addXml(_local5,_local4);
						} else {
							System.disposeXML(_local4);
						}
					} else {
						log("Cannot create bitmap font: texture \'" + _local5 + "\' is missing.");
					}
				}
				onProgress(0.9 + 0.09999999999999998 * _local2);
				setTimeout(processXml,1,param1 + 1);
			};
			var cancel:* = function():void {
				removeEventListener("cancel",cancel);
				_numLoadingQueues--;
				canceled = true;
			};
			var finish:* = function():void {
				setTimeout(function():void {
					if(!canceled) {
						cancel();
						onProgress(1);
					}
				},1);
			};
			if(onProgress == null) {
				throw new ArgumentError("Argument \'onProgress\' must not be null");
			}
			if(_queue.length == 0) {
				onProgress(1);
				return;
			}
			_starling = Starling.current;
			if(_starling == null || _starling.context == null) {
				throw new Error("The Starling instance needs to be ready before assets can be loaded.");
			}
			canceled = false;
			xmls = new Vector.<XML>(0);
			assetInfos = _queue.concat();
			assetCount = int(_queue.length);
			assetProgress = [];
			assetIndex = 0;
			i = 0;
			while(i < assetCount) {
				assetProgress[i] = 0;
				++i;
			}
			i = 0;
			while(i < _numConnections) {
				loadNextQueueElement();
				++i;
			}
			_queue.length = 0;
			_numLoadingQueues++;
			addEventListener("cancel",cancel);
		}
		
		private function processRawAsset(name:String, rawAsset:Object, options:TextureOptions, xmls:Vector.<XML>, onProgress:Function, onComplete:Function) : void {
			var process:* = function(param1:Object):void {
				var texture:Texture;
				var bytes:ByteArray;
				var asset:Object = param1;
				var object:Object = null;
				var xml:XML = null;
				_starling.makeCurrent();
				if(!canceled) {
					if(asset == null) {
						onComplete();
					} else if(asset is Sound) {
						addSound(name,asset as Sound);
						onComplete();
					} else if(asset is XML) {
						xml = asset as XML;
						if(xml.localName() == "TextureAtlas" || xml.localName() == "font") {
							xmls.push(xml);
						} else {
							addXml(name,xml);
						}
						onComplete();
					} else {
						if(_starling.context.driverInfo == "Disposed") {
							log("Context lost while processing assets, retrying ...");
							setTimeout(process,1,asset);
							return;
						}
						if(asset is Bitmap) {
							texture = Texture.fromData(asset,options);
							texture.root.onRestore = function():void {
								_numLostTextures++;
								loadRawAsset(rawAsset,null,function(param1:Object):void {
									try {
										if(param1 == null) {
											throw new Error("Reload failed");
										}
										texture.root.uploadBitmap(param1 as Bitmap);
										param1.bitmapData.dispose();
									}
									catch(e:Error) {
										log("Texture restoration failed for \'" + name + "\': " + e.message);
									}
									_numRestoredTextures++;
									Starling.current.stage.setRequiresRedraw();
									if(_numLostTextures == _numRestoredTextures) {
										dispatchEventWith("texturesRestored");
									}
								});
							};
							asset.bitmapData.dispose();
							addTexture(name,texture);
							onComplete();
						} else if(asset is ByteArray) {
							bytes = asset as ByteArray;
							if(AtfData.isAtfData(bytes)) {
								options.onReady = prependCallback(options.onReady,function():void {
									addTexture(name,texture);
									onComplete();
								});
								texture = Texture.fromData(bytes,options);
								texture.root.onRestore = function():void {
									_numLostTextures++;
									loadRawAsset(rawAsset,null,function(param1:Object):void {
										try {
											if(param1 == null) {
												throw new Error("Reload failed");
											}
											texture.root.uploadAtfData(param1 as ByteArray,0,false);
											param1.clear();
										}
										catch(e:Error) {
											log("Texture restoration failed for \'" + name + "\': " + e.message);
										}
										_numRestoredTextures++;
										Starling.current.stage.setRequiresRedraw();
										if(_numLostTextures == _numRestoredTextures) {
											dispatchEventWith("texturesRestored");
										}
									});
								};
								bytes.clear();
							} else if(byteArrayStartsWith(bytes,"{") || byteArrayStartsWith(bytes,"[")) {
								try {
									object = JSON.parse(bytes.readUTFBytes(bytes.length));
								}
								catch(e:Error) {
									log("Could not parse JSON: " + e.message);
									dispatchEventWith("parseError",false,name);
								}
								if(object) {
									addObject(name,object);
								}
								bytes.clear();
								onComplete();
							} else if(byteArrayStartsWith(bytes,"<")) {
								try {
									xml = new XML(bytes);
								}
								catch(e:Error) {
									log("Could not parse XML: " + e.message);
									dispatchEventWith("parseError",false,name);
								}
								process(xml);
								bytes.clear();
							} else {
								addByteArray(name,bytes);
								onComplete();
							}
						} else {
							addObject(name,asset);
							onComplete();
						}
					}
				}
				asset = null;
				bytes = null;
				removeEventListener("cancel",cancel);
			};
			var progress:* = function(param1:Number):void {
				if(!canceled) {
					onProgress(param1);
				}
			};
			var cancel:* = function():void {
				canceled = true;
			};
			var canceled:Boolean = false;
			addEventListener("cancel",cancel);
			loadRawAsset(rawAsset,progress,process);
		}
		
		protected function loadRawAsset(rawAsset:Object, onProgress:Function, onComplete:Function) : void {
			var onIoError:* = function(param1:IOErrorEvent):void {
				log("IO error: " + param1.text);
				dispatchEventWith("ioError",false,url);
				complete(null);
			};
			var onSecurityError:* = function(param1:SecurityErrorEvent):void {
				log("security error: " + param1.text);
				dispatchEventWith("securityError",false,url);
				complete(null);
			};
			var onHttpResponseStatus:* = function(param1:HTTPStatusEvent):void {
				var _local2:Array = null;
				var _local3:String = null;
				if(extension == null) {
					_local2 = param1["responseHeaders"];
					_local3 = getHttpHeader(_local2,"Content-Type");
					if(_local3 && /(audio|image)\//.exec(_local3)) {
						extension = _local3.split("/").pop();
					}
				}
			};
			var onLoadProgress:* = function(param1:ProgressEvent):void {
				if(onProgress != null && param1.bytesTotal > 0) {
					onProgress(param1.bytesLoaded / param1.bytesTotal);
				}
			};
			var onUrlLoaderComplete:* = function(param1:Object):void {
				var _local5:Sound = null;
				var _local3:LoaderContext = null;
				var _local4:Loader = null;
				var _local2:ByteArray = transformData(urlLoader.data as ByteArray,url);
				if(_local2 == null) {
					complete(null);
					return;
				}
				if(extension) {
					extension = extension.toLowerCase();
				}
				switch(extension) {
					case "mpeg":
					case "mp3":
						_local5 = new Sound();
						_local5.loadCompressedDataFromByteArray(_local2,_local2.length);
						_local2.clear();
						complete(_local5);
						break;
					case "jpg":
					case "jpeg":
					case "png":
					case "gif":
						_local3 = new LoaderContext(_checkPolicyFile);
						_local4 = new Loader();
						_local3.imageDecodingPolicy = "onLoad";
						loaderInfo = _local4.contentLoaderInfo;
						loaderInfo.addEventListener("ioError",onIoError);
						loaderInfo.addEventListener("complete",onLoaderComplete);
						_local4.loadBytes(_local2,_local3);
						break;
					default:
						complete(_local2);
				}
			};
			var onLoaderComplete:* = function(param1:Object):void {
				urlLoader.data.clear();
				complete(param1.target.content);
			};
			var complete:* = function(param1:Object):void {
				if(urlLoader) {
					urlLoader.removeEventListener("ioError",onIoError);
					urlLoader.removeEventListener("securityError",onSecurityError);
					urlLoader.removeEventListener("httpResponseStatus",onHttpResponseStatus);
					urlLoader.removeEventListener("progress",onLoadProgress);
					urlLoader.removeEventListener("complete",onUrlLoaderComplete);
				}
				if(loaderInfo) {
					loaderInfo.removeEventListener("ioError",onIoError);
					loaderInfo.removeEventListener("complete",onLoaderComplete);
				}
				if(SystemUtil.isDesktop) {
					onComplete(param1);
				} else {
					SystemUtil.executeWhenApplicationIsActive(onComplete,param1);
				}
			};
			var extension:String = null;
			var loaderInfo:LoaderInfo = null;
			var urlLoader:URLLoader = null;
			var urlRequest:URLRequest = null;
			var url:String = null;
			if(rawAsset is Class) {
				setTimeout(complete,1,new rawAsset());
			} else if(rawAsset is String || rawAsset is URLRequest) {
				urlRequest = rawAsset as URLRequest || new URLRequest(rawAsset as String);
				url = urlRequest.url;
				extension = getExtensionFromUrl(url);
				urlLoader = new URLLoader();
				urlLoader.dataFormat = "binary";
				urlLoader.addEventListener("ioError",onIoError);
				urlLoader.addEventListener("securityError",onSecurityError);
				urlLoader.addEventListener("httpResponseStatus",onHttpResponseStatus);
				urlLoader.addEventListener("progress",onLoadProgress);
				urlLoader.addEventListener("complete",onUrlLoaderComplete);
				urlLoader.load(urlRequest);
			}
		}
		
		protected function getName(rawAsset:Object) : String {
			var _local2:String = null;
			if(rawAsset is String) {
				_local2 = rawAsset as String;
			} else if(rawAsset is URLRequest) {
				_local2 = (rawAsset as URLRequest).url;
			} else if(rawAsset is FileReference) {
				_local2 = (rawAsset as FileReference).name;
			}
			if(_local2) {
				_local2 = _local2.replace(/%20/g," ");
				_local2 = getBasenameFromUrl(_local2);
				if(_local2) {
					return _local2;
				}
				throw new ArgumentError("Could not extract name from String \'" + rawAsset + "\'");
			}
			_local2 = getQualifiedClassName(rawAsset);
			throw new ArgumentError("Cannot extract names for objects of type \'" + _local2 + "\'");
		}
		
		protected function transformData(data:ByteArray, url:String) : ByteArray {
			return data;
		}
		
		protected function log(message:String) : void {
			if(_verbose) {
				trace("[AssetManager]",message);
			}
		}
		
		private function byteArrayStartsWith(bytes:ByteArray, char:String) : Boolean {
			var _local7:* = 0;
			var _local4:int = 0;
			var _local5:int = 0;
			var _local6:int = int(bytes.length);
			var _local3:int = int(char.charCodeAt(0));
			if(_local6 >= 4 && (bytes[0] == 0 && bytes[1] == 0 && bytes[2] == 254 && bytes[3] == 255) || bytes[0] == 255 && bytes[1] == 254 && bytes[2] == 0 && bytes[3] == 0) {
				_local5 = 4;
			} else if(_local6 >= 3 && bytes[0] == 239 && bytes[1] == 187 && bytes[2] == 191) {
				_local5 = 3;
			} else if(_local6 >= 2 && (bytes[0] == 254 && bytes[1] == 255) || bytes[0] == 255 && bytes[1] == 254) {
				_local5 = 2;
			}
			_local7 = _local5;
			while(_local7 < _local6) {
				_local4 = int(bytes[_local7]);
				if(!(_local4 == 0 || _local4 == 10 || _local4 == 13 || _local4 == 32)) {
					return _local4 == _local3;
				}
				_local7++;
			}
			return false;
		}
		
		private function getDictionaryKeys(dictionary:Dictionary, prefix:String = "", out:Vector.<String> = null) : Vector.<String> {
			if(out == null) {
				out = new Vector.<String>(0);
			}
			for(var _local4 in dictionary) {
				if(_local4.indexOf(prefix) == 0) {
					out[out.length] = _local4;
				}
			}
			out.sort(1);
			return out;
		}
		
		private function getHttpHeader(headers:Array, headerName:String) : String {
			if(headers) {
				for each(var _local3 in headers) {
					if(_local3.name == headerName) {
						return _local3.value;
					}
				}
			}
			return null;
		}
		
		protected function getBasenameFromUrl(url:String) : String {
			var _local2:Array = NAME_REGEX.exec(url);
			if(_local2 && _local2.length > 0) {
				return _local2[1];
			}
			return null;
		}
		
		protected function getExtensionFromUrl(url:String) : String {
			var _local2:Array = NAME_REGEX.exec(url);
			if(_local2 && _local2.length > 1) {
				return _local2[2];
			}
			return null;
		}
		
		private function prependCallback(oldCallback:Function, newCallback:Function) : Function {
			if(oldCallback == null) {
				return newCallback;
			}
			if(newCallback == null) {
				return oldCallback;
			}
			return function():void {
				newCallback();
				oldCallback();
			};
		}
		
		protected function get queue() : Array {
			return _queue;
		}
		
		public function get numQueuedAssets() : int {
			return _queue.length;
		}
		
		public function get verbose() : Boolean {
			return _verbose;
		}
		
		public function set verbose(value:Boolean) : void {
			_verbose = value;
		}
		
		public function get isLoading() : Boolean {
			return _numLoadingQueues > 0;
		}
		
		public function get useMipMaps() : Boolean {
			return _defaultTextureOptions.mipMapping;
		}
		
		public function set useMipMaps(value:Boolean) : void {
			_defaultTextureOptions.mipMapping = value;
		}
		
		public function get scaleFactor() : Number {
			return _defaultTextureOptions.scale;
		}
		
		public function set scaleFactor(value:Number) : void {
			_defaultTextureOptions.scale = value;
		}
		
		public function get textureFormat() : String {
			return _defaultTextureOptions.format;
		}
		
		public function set textureFormat(value:String) : void {
			_defaultTextureOptions.format = value;
		}
		
		public function get forcePotTextures() : Boolean {
			return _defaultTextureOptions.forcePotTexture;
		}
		
		public function set forcePotTextures(value:Boolean) : void {
			_defaultTextureOptions.forcePotTexture = value;
		}
		
		public function get checkPolicyFile() : Boolean {
			return _checkPolicyFile;
		}
		
		public function set checkPolicyFile(value:Boolean) : void {
			_checkPolicyFile = value;
		}
		
		public function get keepAtlasXmls() : Boolean {
			return _keepAtlasXmls;
		}
		
		public function set keepAtlasXmls(value:Boolean) : void {
			_keepAtlasXmls = value;
		}
		
		public function get keepFontXmls() : Boolean {
			return _keepFontXmls;
		}
		
		public function set keepFontXmls(value:Boolean) : void {
			_keepFontXmls = value;
		}
		
		public function get numConnections() : int {
			return _numConnections;
		}
		
		public function set numConnections(value:int) : void {
			_numConnections = value;
		}
	}
}

