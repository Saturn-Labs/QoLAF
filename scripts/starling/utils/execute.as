package starling.utils {
	public function execute(func:Function, ... rest) : void {
		var _local4:int = 0;
		var _local3:int = 0;
		if(func != null) {
			_local3 = func.length;
			_local4 = int(rest.length);
			while(_local4 < _local3) {
				rest[_local4] = null;
				_local4++;
			}
			switch(_local3) {
				case 0:
					func();
					break;
				case 1:
					func(rest[0]);
					break;
				case 2:
					func(rest[0],rest[1]);
					break;
				case 3:
					func(rest[0],rest[1],rest[2]);
					break;
				case 4:
					func(rest[0],rest[1],rest[2],rest[3]);
					break;
				case 5:
					func(rest[0],rest[1],rest[2],rest[3],rest[4]);
					break;
				case 6:
					func(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
					break;
				case 7:
					func(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
					break;
				default:
					func.apply(null,rest.slice(0,_local3));
			}
		}
	}
}

