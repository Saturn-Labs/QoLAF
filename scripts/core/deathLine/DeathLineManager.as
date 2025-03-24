package core.deathLine {
	import core.scene.Game;
	import flash.geom.Point;
	import generics.GUID;
	import playerio.Message;
	import starling.display.MeshBatch;
	import starling.events.TouchEvent;
	
	public class DeathLineManager {
		private var g:Game;
		
		public var lines:Vector.<DeathLine> = new Vector.<DeathLine>();
		
		private var last:Point = new Point();
		
		private var isCut:Boolean = true;
		
		public var lineBatch:MeshBatch = new MeshBatch();
		
		private var selectedLineId:String = "";
		
		public function DeathLineManager(g:Game) {
			super();
			this.g = g;
			lineBatch.blendMode = "add";
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("addDeathLine",m_addDeathLine);
			g.addMessageHandler("clearDeathLines",m_clearDeathLines);
			g.addMessageHandler("undoDeathLine",m_undoDeathLine);
			g.addMessageHandler("deleteDeathLine",m_deleteDeathLine);
		}
		
		private function m_undoDeathLine(m:Message) : void {
			undo();
		}
		
		private function m_deleteDeathLine(m:Message) : void {
			deleteSelected(m.getString(0));
		}
		
		private function m_clearDeathLines(m:Message) : void {
			clear();
		}
		
		private function m_addDeathLine(m:Message) : void {
			addLine(m.getInt(0),m.getInt(1),m.getInt(2),m.getInt(3),m.getString(4));
		}
		
		public function addCoord(x:int, y:int) : void {
			if(isCut) {
				last.x = x;
				last.y = y;
				isCut = false;
				return;
			}
			addLine(last.x,last.y,x,y,"",true);
			last.x = x;
			last.y = y;
		}
		
		public function addLine(x:int, y:int, x2:int, y2:int, id:String = "", send:Boolean = false) : void {
			if(!g.stage.contains(lineBatch)) {
				if(g.me != null && g.me.isDeveloper) {
					g.touchableCanvas = true;
				}
				g.addChildToCanvas(lineBatch);
			}
			var _local7:DeathLine = new DeathLine(g,13307920,1);
			_local7.blendMode = "add";
			_local7.x = x;
			_local7.y = y;
			_local7.id = id == "" ? GUID.create() : id;
			_local7.lineTo(x2,y2);
			if(g.me != null && g.me.isDeveloper) {
				lineBatch.root.touchable = true;
				_local7.touchable = true;
				lineBatch.touchable = true;
				_local7.addEventListener("touch",onTouch);
			}
			lines.push(_local7);
			lineBatch.addMesh(_local7);
			if(send) {
				g.sendMessage(g.createMessage("addDeathLine",x,y,x2,y2,_local7.id));
			}
		}
		
		public function cut() : void {
			isCut = true;
		}
		
		private function lineById(id:String) : DeathLine {
			for each(var _local2 in lines) {
				if(_local2.id == id) {
					return _local2;
				}
			}
			return null;
		}
		
		public function forceUpdate() : void {
			for each(var _local1 in lines) {
				_local1.nextDistanceCalculation = -1;
			}
		}
		
		public function deleteSelected(id:String = "", send:Boolean = false) : void {
			selectedLineId = id == "" ? selectedLineId : id;
			var line:DeathLine = lineById(selectedLineId);
			if(!line) {
				return;
			}
			line.removeEventListeners();
			lines = lines.filter(function(param1:DeathLine, param2:int, param3:Array):Boolean {
				return param1 != line;
			});
			updateBatch();
			if(send) {
				g.send("deleteDeathLine",selectedLineId);
			}
		}
		
		public function clear(send:Boolean = false) : void {
			lineBatch.clear();
			for each(var _local2 in lines) {
				_local2.removeEventListeners();
			}
			lines.length = 0;
			isCut = true;
			if(send) {
				g.send("clearDeathLines");
			}
		}
		
		public function save() : void {
			g.send("saveDeathLines");
		}
		
		public function undo(send:Boolean = false) : void {
			var _local2:DeathLine = lines.pop();
			if(!_local2) {
				return;
			}
			_local2.removeEventListeners();
			updateBatch();
			last.x = _local2.x;
			last.y = _local2.y;
			if(send) {
				g.send("undoDeathLine");
			}
		}
		
		private function updateBatch() : void {
			lineBatch.clear();
			for each(var _local1 in lines) {
				lineBatch.addMesh(_local1);
			}
		}
		
		public function update() : void {
			for each(var _local1 in lines) {
				_local1.update();
			}
		}
		
		private function onTouch(e:TouchEvent) : void {
			var _local2:DeathLine = e.currentTarget as DeathLine;
			if(e.getTouch(_local2,"ended")) {
				selectedLineId = _local2.id;
			} else if(e.interactsWith(_local2)) {
				_local2.color = 0xffffff;
			} else {
				_local2.color = 0xff4444;
			}
		}
	}
}

