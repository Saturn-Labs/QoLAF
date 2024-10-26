package qolaf.debuffs 
{
	import core.scene.Game;
	import core.weapon.Debuff;
	
	/**
	 * @author rydev
	 */
	public class DebuffEffect 
	{
		private var debuffId:Number = -1;
		private var startTime:Number = 0;
		private var duration:Number = 0;
		private var stacks:Number = 0;
		
		public function DebuffEffect(id:Number, duration:Number): void 
		{
			this.debuffId = id;
			this.duration = duration;
			this.startTime = Game.instance.time;
			this.stacks = 1;
		}
		
		public function getDuration(): Number {
			return duration;
		}
		
		public function addStack(): void {
			if (debuffId == Debuff.DOT_STACKING || debuffId == Debuff.REDUCE_ARMOR)
				stacks++;
			this.startTime = Game.instance.time;
		}
		
		public function getEndTime(): Number {
			return this.startTime + getDuration();
		}
		
		public function getStacks(): Number {
			return stacks;
		}
		
		public function getDebuffId(): Number {
			return debuffId;
		}
	}
}