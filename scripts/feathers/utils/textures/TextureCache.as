package feathers.utils.textures {
	import flash.errors.IllegalOperationError;
	import starling.textures.Texture;
	
	public class TextureCache {
		protected var _unretainedKeys:Vector.<String> = new Vector.<String>(0);
		
		protected var _unretainedTextures:Object = {};
		
		protected var _retainedTextures:Object = {};
		
		protected var _retainCounts:Object = {};
		
		protected var _maxUnretainedTextures:int;
		
		public function TextureCache(maxUnretainedTextures:int = 2147483647) {
			super();
			this._maxUnretainedTextures = maxUnretainedTextures;
		}
		
		public function get maxUnretainedTextures() : int {
			return this._maxUnretainedTextures;
		}
		
		public function set maxUnretainedTextures(value:int) : void {
			if(this._maxUnretainedTextures === value) {
				return;
			}
			this._maxUnretainedTextures = value;
			if(this._unretainedKeys.length > value) {
				this.trimCache();
			}
		}
		
		public function dispose() : void {
			for each(var _local1 in this._unretainedTextures) {
				_local1.dispose();
			}
			for each(_local1 in this._retainedTextures) {
				_local1.dispose();
			}
			this._retainedTextures = null;
			this._unretainedTextures = null;
			this._retainCounts = null;
		}
		
		public function addTexture(key:String, texture:Texture, retainTexture:Boolean = true) : void {
			if(!this._retainedTextures) {
				throw new IllegalOperationError("Cannot add a texture after the cache has been disposed.");
			}
			if(key in this._unretainedTextures || key in this._retainedTextures) {
				throw new ArgumentError("Key \"" + key + "\" already exists in the cache.");
			}
			if(retainTexture) {
				this._retainedTextures[key] = texture;
				this._retainCounts[key] = 1 as int;
				return;
			}
			this._unretainedTextures[key] = texture;
			this._unretainedKeys[this._unretainedKeys.length] = key;
			if(this._unretainedKeys.length > this._maxUnretainedTextures) {
				this.trimCache();
			}
		}
		
		public function removeTexture(key:String, dispose:Boolean = false) : void {
			if(!this._unretainedTextures) {
				return;
			}
			var _local3:Texture = this._unretainedTextures[key] as Texture;
			if(_local3) {
				this.removeUnretainedKey(key);
			} else {
				_local3 = this._retainedTextures[key] as Texture;
				delete this._retainedTextures[key];
				delete this._retainCounts[key];
			}
			if(dispose && _local3) {
				_local3.dispose();
			}
		}
		
		public function hasTexture(key:String) : Boolean {
			if(!this._retainedTextures) {
				return false;
			}
			return key in this._retainedTextures || key in this._unretainedTextures;
		}
		
		public function getRetainCount(key:String) : int {
			if(this._retainCounts && key in this._retainCounts) {
				return this._retainCounts[key] as int;
			}
			return 0;
		}
		
		public function retainTexture(key:String) : Texture {
			var _local3:int = 0;
			if(!this._retainedTextures) {
				throw new IllegalOperationError("Cannot retain a texture after the cache has been disposed.");
			}
			if(key in this._retainedTextures) {
				_local3 = this._retainCounts[key] as int;
				_local3++;
				this._retainCounts[key] = _local3;
				return Texture(this._retainedTextures[key]);
			}
			if(!(key in this._unretainedTextures)) {
				throw new ArgumentError("Texture with key \"" + key + "\" cannot be retained because it has not been added to the cache.");
			}
			var _local2:Texture = Texture(this._unretainedTextures[key]);
			this.removeUnretainedKey(key);
			this._retainedTextures[key] = _local2;
			this._retainCounts[key] = 1 as int;
			return _local2;
		}
		
		public function releaseTexture(key:String) : void {
			var _local2:Texture = null;
			if(!this._retainedTextures || !(key in this._retainedTextures)) {
				return;
			}
			var _local3:int = this._retainCounts[key] as int;
			_local3--;
			if(_local3 === 0) {
				_local2 = Texture(this._retainedTextures[key]);
				delete this._retainCounts[key];
				delete this._retainedTextures[key];
				this._unretainedTextures[key] = _local2;
				this._unretainedKeys[this._unretainedKeys.length] = key;
				if(this._unretainedKeys.length > this._maxUnretainedTextures) {
					this.trimCache();
				}
			} else {
				this._retainCounts[key] = _local3;
			}
		}
		
		protected function removeUnretainedKey(key:String) : void {
			var _local2:int = int(this._unretainedKeys.indexOf(key));
			if(_local2 < 0) {
				return;
			}
			this._unretainedKeys.removeAt(_local2);
			delete this._unretainedTextures[key];
		}
		
		protected function trimCache() : void {
			var _local4:String = null;
			var _local1:Texture = null;
			var _local2:int = int(this._unretainedKeys.length);
			var _local3:int = this._maxUnretainedTextures;
			while(_local2 > _local3) {
				_local4 = this._unretainedKeys.shift();
				_local1 = Texture(this._unretainedTextures[_local4]);
				_local1.dispose();
				delete this._unretainedTextures[_local4];
				_local2--;
			}
		}
	}
}

