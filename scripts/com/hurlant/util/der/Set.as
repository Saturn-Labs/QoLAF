package com.hurlant.util.der {
	public dynamic class Set extends Sequence implements IAsn1Type {
		public function Set(type:uint = 49, length:uint = 0) {
			super(type,length);
		}
		
		override public function toString() : String {
			var _local1:String = DER.indent;
			DER.indent += "    ";
			var _local2:String = join("\n");
			DER.indent = _local1;
			return DER.indent + "Set[" + type + "][" + len + "][\n" + _local2 + "\n" + _local1 + "]";
		}
	}
}

