package core.player {
	public class TechSkill {
		public var tech:String;
		
		public var table:String;
		
		public var level:int;
		
		public var name:String;
		
		public var activeEliteTech:String;
		
		public var activeEliteTechLevel:int;
		
		public var eliteTechs:Vector.<EliteTechSkill> = new Vector.<EliteTechSkill>();
		
		public function TechSkill(name:String = "", tech:String = "", table:String = "", level:int = 0, activeEliteTech:String = "", activeEliteTechLevel:int = 0) {
			super();
			this.name = name;
			this.tech = tech;
			this.table = table;
			this.level = level;
			this.activeEliteTech = activeEliteTech;
			this.activeEliteTechLevel = activeEliteTechLevel;
		}
		
		public function setData(d:Object) : void {
			name = d.name;
			tech = d.tech;
			table = d.table;
			level = d.level;
		}
		
		public function addEliteTechData(eliteTech:String, eliteTechLevel:int) : void {
			var _local3:Boolean = false;
			for each(var _local4 in eliteTechs) {
				if(_local4.eliteTech == eliteTech) {
					_local4.eliteTechLevel = eliteTechLevel;
					_local3 = true;
				}
			}
			if(!_local3) {
				eliteTechs.push(new EliteTechSkill(eliteTech,eliteTechLevel));
			}
		}
	}
}

