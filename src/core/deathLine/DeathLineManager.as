package core.deathLine
{
	import core.scene.Game;
	import flash.geom.Point;
	import generics.GUID;
	import playerio.Message;
	import starling.display.MeshBatch;
	import starling.events.TouchEvent;
	
	public class DeathLineManager
	{
		private var g:Game;
		
		public var lines:Vector.<DeathLine>;
		
		private var last:Point;
		
		private var isCut:Boolean = true;
		
		public var lineBatch:MeshBatch;
		
		private var selectedLineId:String = "";
		
		public function DeathLineManager(param1:Game)
		{
			lines = new Vector.<DeathLine>();
			last = new Point();
			lineBatch = new MeshBatch();
			super();
			this.g = param1;
			lineBatch.blendMode = "add";
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("addDeathLine", m_addDeathLine);
			g.addMessageHandler("clearDeathLines", m_clearDeathLines);
			g.addMessageHandler("undoDeathLine", m_undoDeathLine);
			g.addMessageHandler("deleteDeathLine", m_deleteDeathLine);
		}
		
		private function m_undoDeathLine(param1:Message):void
		{
			undo();
		}
		
		private function m_deleteDeathLine(param1:Message):void
		{
			deleteSelected(param1.getString(0));
		}
		
		private function m_clearDeathLines(param1:Message):void
		{
			clear();
		}
		
		private function m_addDeathLine(param1:Message):void
		{
			addLine(param1.getInt(0), param1.getInt(1), param1.getInt(2), param1.getInt(3), param1.getString(4));
		}
		
		public function addCoord(param1:int, param2:int):void
		{
			if (isCut)
			{
				last.x = param1;
				last.y = param2;
				isCut = false;
				return;
			}
			addLine(last.x, last.y, param1, param2, "", true);
			last.x = param1;
			last.y = param2;
		}
		
		public function addLine(param1:int, param2:int, param3:int, param4:int, param5:String = "", param6:Boolean = false):void
		{
			if (!g.stage.contains(lineBatch))
			{
				if (g.me != null && g.me.isDeveloper)
				{
					g.touchableCanvas = true;
				}
				g.addChildToCanvas(lineBatch);
			}
			var _loc7_:DeathLine = new DeathLine(g, 13307920, 1);
			_loc7_.blendMode = "add";
			_loc7_.x = param1;
			_loc7_.y = param2;
			_loc7_.id = param5 == "" ? GUID.create() : param5;
			_loc7_.lineTo(param3, param4);
			if (g.me != null && g.me.isDeveloper)
			{
				lineBatch.root.touchable = true;
				_loc7_.touchable = true;
				lineBatch.touchable = true;
				_loc7_.addEventListener("touch", onTouch);
			}
			lines.push(_loc7_);
			lineBatch.addMesh(_loc7_);
			if (param6)
			{
				g.sendMessage(g.createMessage("addDeathLine", param1, param2, param3, param4, _loc7_.id));
			}
		}
		
		public function cut():void
		{
			isCut = true;
		}
		
		private function lineById(param1:String):DeathLine
		{
			for each (var _loc2_:* in lines)
			{
				if (_loc2_.id == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function forceUpdate():void
		{
			for each (var _loc1_:* in lines)
			{
				_loc1_.nextDistanceCalculation = -1;
			}
		}
		
		public function deleteSelected(param1:String = "", param2:Boolean = false):void
		{
			var id:String = param1;
			var send:Boolean = param2;
			selectedLineId = id == "" ? selectedLineId : id;
			var line:DeathLine = lineById(selectedLineId);
			if (!line)
			{
				return;
			}
			line.removeEventListeners();
			lines = lines.filter(function(param1:DeathLine, param2:int, param3:Array):Boolean
			{
				return param1 != line;
			});
			updateBatch();
			if (send)
			{
				g.send("deleteDeathLine", selectedLineId);
			}
		}
		
		public function clear(param1:Boolean = false):void
		{
			lineBatch.clear();
			for each (var _loc2_:* in lines)
			{
				_loc2_.removeEventListeners();
			}
			lines.length = 0;
			isCut = true;
			if (param1)
			{
				g.send("clearDeathLines");
			}
		}
		
		public function save():void
		{
			g.send("saveDeathLines");
		}
		
		public function undo(param1:Boolean = false):void
		{
			var _loc2_:DeathLine = lines.pop();
			if (!_loc2_)
			{
				return;
			}
			_loc2_.removeEventListeners();
			updateBatch();
			last.x = _loc2_.x;
			last.y = _loc2_.y;
			if (param1)
			{
				g.send("undoDeathLine");
			}
		}
		
		private function updateBatch():void
		{
			lineBatch.clear();
			for each (var _loc1_:* in lines)
			{
				lineBatch.addMesh(_loc1_);
			}
		}
		
		public function update():void
		{
			for each (var _loc1_:* in lines)
			{
				_loc1_.update();
			}
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			var _loc2_:DeathLine = param1.currentTarget as DeathLine;
			if (param1.getTouch(_loc2_, "ended"))
			{
				selectedLineId = _loc2_.id;
			}
			else if (param1.interactsWith(_loc2_))
			{
				_loc2_.color = 16777215;
			}
			else
			{
				_loc2_.color = 16729156;
			}
		}
	}
}
