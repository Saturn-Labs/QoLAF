package qolaf.utils
{
	import core.boss.Boss;
	import core.spawner.Spawner;
	import core.unit.Unit;
	import qolaf.target.ITarget;

	/**
	 * @author rydev
	 */
	public class TargetUtils
	{
		public static function getTargetTrueName(target:ITarget):String
		{
			var name:String = "";
			if (target is Spawner)
			{
				var spawner:Spawner = target as Spawner;
				if (spawner.factions.length == 0)
					name = spawner.spawnerType.charAt(0).toUpperCase() + spawner.spawnerType.substring(1) + " Spawner";
				else
					name = spawner.factions[0] + " Spawner";
			}
			else if (target.isBoss())
			{
				var boss:Boss = target.getBoss();
				name = boss.name;
			}
			else
			{
				name = removeLevelFromName(target.getName());
			}
			return name;
		}

		private static function removeLevelFromName(name:String):String
		{
			if (name == null)
				return "Unknown";
			return (name.split("lvl")[0] as String).replace(/^\s+|\s+$/g, "");
		}
	}
}