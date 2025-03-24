package core.particle {
	import core.GameObject;
	import core.scene.Game;
	import debug.Console;
	
	public class EmitterManager {
		public var emitters:Vector.<Emitter>;
		
		private var g:Game;
		
		private var inactiveEmitters:Vector.<Emitter>;
		
		public function EmitterManager(m:Game) {
			var _local2:int = 0;
			super();
			this.g = m;
			emitters = new Vector.<Emitter>();
			inactiveEmitters = new Vector.<Emitter>();
			Console.write(" -- init emitter pool");
			_local2 = 0;
			while(_local2 < 40) {
				inactiveEmitters.push(new Emitter(m));
				_local2++;
			}
			Console.write(" -- emitter pool complete ");
		}
		
		public function update() : void {
			var _local2:int = 0;
			var _local1:Emitter = null;
			var _local3:int = int(emitters.length);
			_local2 = _local3 - 1;
			while(_local2 > -1) {
				_local1 = emitters[_local2];
				if(_local1.alive) {
					_local1.update();
				} else {
					removeEmitter(_local1,_local2);
				}
				_local2--;
			}
			CollectiveMeshBatch.AllMeshesAreUpdated();
		}
		
		public function getEmitter() : Emitter {
			var _local1:Emitter = null;
			if(inactiveEmitters.length > 0) {
				_local1 = inactiveEmitters.pop();
			} else {
				_local1 = new Emitter(g);
			}
			_local1.dispose();
			emitters.push(_local1);
			_local1.alive = true;
			return _local1;
		}
		
		public function forceUpdate(go:GameObject = null) : void {
			var _local3:int = 0;
			var _local2:Emitter = null;
			_local3 = emitters.length - 1;
			while(_local3 > -1) {
				_local2 = emitters[_local3];
				if(_local2.target == go || go == null) {
					_local2.nextDistanceCalculation = 0;
				}
				_local3--;
			}
		}
		
		public function clean(o:GameObject) : void {
			var _local3:int = 0;
			var _local2:Emitter = null;
			var _local4:int = int(emitters.length);
			_local3 = _local4 - 1;
			while(_local3 > -1) {
				_local2 = emitters[_local3];
				if(_local2.target == o) {
					removeEmitter(_local2,_local3);
				}
				_local3--;
			}
		}
		
		public function removeEmitter(e:Emitter, index:int) : void {
			e.killEmitter();
			emitters.splice(index,1);
			inactiveEmitters.push(e);
			e.dispose();
		}
		
		public function dispose() : void {
			for each(var _local1 in emitters) {
				_local1.dispose();
			}
			emitters = null;
			inactiveEmitters = null;
			CollectiveMeshBatch.dispose();
		}
	}
}

