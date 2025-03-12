package core.player
{
	
	public class TechSkill
	{
		public var tech:String;
		
		public var table:String;
		
		public var level:int;
		
		public var name:String;
		
		public var activeEliteTech:String;
		
		public var activeEliteTechLevel:int;
		
		public var eliteTechs:Vector.<EliteTechSkill>;
		
		public function TechSkill(param1:String = "", param2:String = "", param3:String = "", param4:int = 0, param5:String = "", param6:int = 0)
		{
			eliteTechs = new Vector.<EliteTechSkill>();
			super();
			this.name = param1;
			this.tech = param2;
			this.table = param3;
			this.level = param4;
			this.activeEliteTech = param5;
			this.activeEliteTechLevel = param6;
		}
		
		public function setData(param1:Object):void
		{
			name = param1.name;
			tech = param1.tech;
			table = param1.table;
			level = param1.level;
		}
		
		public function addEliteTechData(param1:String, param2:int):void
		{
			var _loc4_:Boolean = false;
			for each (var _loc3_:* in eliteTechs)
			{
				if (_loc3_.eliteTech == param1)
				{
					_loc3_.eliteTechLevel = param2;
					_loc4_ = true;
				}
			}
			if (!_loc4_)
			{
				eliteTechs.push(new EliteTechSkill(param1, param2));
			}
		}
	}
}
