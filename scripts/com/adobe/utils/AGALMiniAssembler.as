package com.adobe.utils {
	import flash.display3D.*;
	import flash.utils.*;
	
	public class AGALMiniAssembler {
		private static var initialized:Boolean = false;
		
		private static const MAX_NESTING:int = 4;
		
		private static const MAX_OPCODES:int = 2048;
		
		private static const FRAGMENT:String = "fragment";
		
		private static const VERTEX:String = "vertex";
		
		private static const SAMPLER_TYPE_SHIFT:uint = 8;
		
		private static const SAMPLER_DIM_SHIFT:uint = 12;
		
		private static const SAMPLER_SPECIAL_SHIFT:uint = 16;
		
		private static const SAMPLER_REPEAT_SHIFT:uint = 20;
		
		private static const SAMPLER_MIPMAP_SHIFT:uint = 24;
		
		private static const SAMPLER_FILTER_SHIFT:uint = 28;
		
		private static const REG_WRITE:uint = 1;
		
		private static const REG_READ:uint = 2;
		
		private static const REG_FRAG:uint = 32;
		
		private static const REG_VERT:uint = 64;
		
		private static const OP_SCALAR:uint = 1;
		
		private static const OP_SPECIAL_TEX:uint = 8;
		
		private static const OP_SPECIAL_MATRIX:uint = 16;
		
		private static const OP_FRAG_ONLY:uint = 32;
		
		private static const OP_VERT_ONLY:uint = 64;
		
		private static const OP_NO_DEST:uint = 128;
		
		private static const OP_VERSION2:uint = 256;
		
		private static const OP_INCNEST:uint = 512;
		
		private static const OP_DECNEST:uint = 1024;
		
		private static const MOV:String = "mov";
		
		private static const ADD:String = "add";
		
		private static const SUB:String = "sub";
		
		private static const MUL:String = "mul";
		
		private static const DIV:String = "div";
		
		private static const RCP:String = "rcp";
		
		private static const MIN:String = "min";
		
		private static const MAX:String = "max";
		
		private static const FRC:String = "frc";
		
		private static const SQT:String = "sqt";
		
		private static const RSQ:String = "rsq";
		
		private static const POW:String = "pow";
		
		private static const LOG:String = "log";
		
		private static const EXP:String = "exp";
		
		private static const NRM:String = "nrm";
		
		private static const SIN:String = "sin";
		
		private static const COS:String = "cos";
		
		private static const CRS:String = "crs";
		
		private static const DP3:String = "dp3";
		
		private static const DP4:String = "dp4";
		
		private static const ABS:String = "abs";
		
		private static const NEG:String = "neg";
		
		private static const SAT:String = "sat";
		
		private static const M33:String = "m33";
		
		private static const M44:String = "m44";
		
		private static const M34:String = "m34";
		
		private static const DDX:String = "ddx";
		
		private static const DDY:String = "ddy";
		
		private static const IFE:String = "ife";
		
		private static const INE:String = "ine";
		
		private static const IFG:String = "ifg";
		
		private static const IFL:String = "ifl";
		
		private static const ELS:String = "els";
		
		private static const EIF:String = "eif";
		
		private static const TED:String = "ted";
		
		private static const KIL:String = "kil";
		
		private static const TEX:String = "tex";
		
		private static const SGE:String = "sge";
		
		private static const SLT:String = "slt";
		
		private static const SGN:String = "sgn";
		
		private static const SEQ:String = "seq";
		
		private static const SNE:String = "sne";
		
		private static const VA:String = "va";
		
		private static const VC:String = "vc";
		
		private static const VT:String = "vt";
		
		private static const VO:String = "vo";
		
		private static const VI:String = "vi";
		
		private static const FC:String = "fc";
		
		private static const FT:String = "ft";
		
		private static const FS:String = "fs";
		
		private static const FO:String = "fo";
		
		private static const FD:String = "fd";
		
		private static const D2:String = "2d";
		
		private static const D3:String = "3d";
		
		private static const CUBE:String = "cube";
		
		private static const MIPNEAREST:String = "mipnearest";
		
		private static const MIPLINEAR:String = "miplinear";
		
		private static const MIPNONE:String = "mipnone";
		
		private static const NOMIP:String = "nomip";
		
		private static const NEAREST:String = "nearest";
		
		private static const LINEAR:String = "linear";
		
		private static const ANISOTROPIC2X:String = "anisotropic2x";
		
		private static const ANISOTROPIC4X:String = "anisotropic4x";
		
		private static const ANISOTROPIC8X:String = "anisotropic8x";
		
		private static const ANISOTROPIC16X:String = "anisotropic16x";
		
		private static const CENTROID:String = "centroid";
		
		private static const SINGLE:String = "single";
		
		private static const IGNORESAMPLER:String = "ignoresampler";
		
		private static const REPEAT:String = "repeat";
		
		private static const WRAP:String = "wrap";
		
		private static const CLAMP:String = "clamp";
		
		private static const REPEAT_U_CLAMP_V:String = "repeat_u_clamp_v";
		
		private static const CLAMP_U_REPEAT_V:String = "clamp_u_repeat_v";
		
		private static const RGBA:String = "rgba";
		
		private static const DXT1:String = "dxt1";
		
		private static const DXT5:String = "dxt5";
		
		private static const VIDEO:String = "video";
		
		protected static const REGEXP_OUTER_SPACES:RegExp = /^\s+|\s+$/g;
		
		private static const OPMAP:Dictionary = new Dictionary();
		
		private static const REGMAP:Dictionary = new Dictionary();
		
		private static const SAMPLEMAP:Dictionary = new Dictionary();
		
		private var _agalcode:ByteArray = null;
		
		private var _error:String = "";
		
		private var debugEnabled:Boolean = false;
		
		public var verbose:Boolean = false;
		
		public function AGALMiniAssembler(debugging:Boolean = false) {
			super();
			debugEnabled = debugging;
			if(!initialized) {
				init();
			}
		}
		
		private static function init() : void {
			initialized = true;
			OPMAP["mov"] = new OpCode("mov",2,0,0);
			OPMAP["add"] = new OpCode("add",3,1,0);
			OPMAP["sub"] = new OpCode("sub",3,2,0);
			OPMAP["mul"] = new OpCode("mul",3,3,0);
			OPMAP["div"] = new OpCode("div",3,4,0);
			OPMAP["rcp"] = new OpCode("rcp",2,5,0);
			OPMAP["min"] = new OpCode("min",3,6,0);
			OPMAP["max"] = new OpCode("max",3,7,0);
			OPMAP["frc"] = new OpCode("frc",2,8,0);
			OPMAP["sqt"] = new OpCode("sqt",2,9,0);
			OPMAP["rsq"] = new OpCode("rsq",2,10,0);
			OPMAP["pow"] = new OpCode("pow",3,11,0);
			OPMAP["log"] = new OpCode("log",2,12,0);
			OPMAP["exp"] = new OpCode("exp",2,13,0);
			OPMAP["nrm"] = new OpCode("nrm",2,14,0);
			OPMAP["sin"] = new OpCode("sin",2,15,0);
			OPMAP["cos"] = new OpCode("cos",2,16,0);
			OPMAP["crs"] = new OpCode("crs",3,17,0);
			OPMAP["dp3"] = new OpCode("dp3",3,18,0);
			OPMAP["dp4"] = new OpCode("dp4",3,19,0);
			OPMAP["abs"] = new OpCode("abs",2,20,0);
			OPMAP["neg"] = new OpCode("neg",2,21,0);
			OPMAP["sat"] = new OpCode("sat",2,22,0);
			OPMAP["m33"] = new OpCode("m33",3,23,16);
			OPMAP["m44"] = new OpCode("m44",3,24,16);
			OPMAP["m34"] = new OpCode("m34",3,25,16);
			OPMAP["ddx"] = new OpCode("ddx",2,26,0x0100 | 0x20);
			OPMAP["ddy"] = new OpCode("ddy",2,27,0x0100 | 0x20);
			OPMAP["ife"] = new OpCode("ife",2,28,0x80 | 0x0100 | 0x0200 | 1);
			OPMAP["ine"] = new OpCode("ine",2,29,0x80 | 0x0100 | 0x0200 | 1);
			OPMAP["ifg"] = new OpCode("ifg",2,30,0x80 | 0x0100 | 0x0200 | 1);
			OPMAP["ifl"] = new OpCode("ifl",2,31,0x80 | 0x0100 | 0x0200 | 1);
			OPMAP["els"] = new OpCode("els",0,32,0x80 | 0x0100 | 0x0200 | 0x0400 | 1);
			OPMAP["eif"] = new OpCode("eif",0,33,0x80 | 0x0100 | 0x0400 | 1);
			OPMAP["kil"] = new OpCode("kil",1,39,0x80 | 0x20);
			OPMAP["tex"] = new OpCode("tex",3,40,0x20 | 8);
			OPMAP["sge"] = new OpCode("sge",3,41,0);
			OPMAP["slt"] = new OpCode("slt",3,42,0);
			OPMAP["sgn"] = new OpCode("sgn",2,43,0);
			OPMAP["seq"] = new OpCode("seq",3,44,0);
			OPMAP["sne"] = new OpCode("sne",3,45,0);
			SAMPLEMAP["rgba"] = new Sampler("rgba",8,0);
			SAMPLEMAP["dxt1"] = new Sampler("dxt1",8,1);
			SAMPLEMAP["dxt5"] = new Sampler("dxt5",8,2);
			SAMPLEMAP["video"] = new Sampler("video",8,3);
			SAMPLEMAP["2d"] = new Sampler("2d",12,0);
			SAMPLEMAP["3d"] = new Sampler("3d",12,2);
			SAMPLEMAP["cube"] = new Sampler("cube",12,1);
			SAMPLEMAP["mipnearest"] = new Sampler("mipnearest",24,1);
			SAMPLEMAP["miplinear"] = new Sampler("miplinear",24,2);
			SAMPLEMAP["mipnone"] = new Sampler("mipnone",24,0);
			SAMPLEMAP["nomip"] = new Sampler("nomip",24,0);
			SAMPLEMAP["nearest"] = new Sampler("nearest",28,0);
			SAMPLEMAP["linear"] = new Sampler("linear",28,1);
			SAMPLEMAP["anisotropic2x"] = new Sampler("anisotropic2x",28,2);
			SAMPLEMAP["anisotropic4x"] = new Sampler("anisotropic4x",28,3);
			SAMPLEMAP["anisotropic8x"] = new Sampler("anisotropic8x",28,4);
			SAMPLEMAP["anisotropic16x"] = new Sampler("anisotropic16x",28,5);
			SAMPLEMAP["centroid"] = new Sampler("centroid",16,1);
			SAMPLEMAP["single"] = new Sampler("single",16,2);
			SAMPLEMAP["ignoresampler"] = new Sampler("ignoresampler",16,4);
			SAMPLEMAP["repeat"] = new Sampler("repeat",20,1);
			SAMPLEMAP["wrap"] = new Sampler("wrap",20,1);
			SAMPLEMAP["clamp"] = new Sampler("clamp",20,0);
			SAMPLEMAP["clamp_u_repeat_v"] = new Sampler("clamp_u_repeat_v",20,2);
			SAMPLEMAP["repeat_u_clamp_v"] = new Sampler("repeat_u_clamp_v",20,3);
		}
		
		public function get error() : String {
			return _error;
		}
		
		public function get agalcode() : ByteArray {
			return _agalcode;
		}
		
		public function assemble2(ctx3d:Context3D, version:uint, vertexsrc:String, fragmentsrc:String) : Program3D {
			var _local5:ByteArray = assemble("vertex",vertexsrc,version);
			var _local6:ByteArray = assemble("fragment",fragmentsrc,version);
			var _local7:Program3D = ctx3d.createProgram();
			_local7.upload(_local5,_local6);
			return _local7;
		}
		
		public function assemble(mode:String, source:String, version:uint = 1, ignorelimits:Boolean = false) : ByteArray {
			var _local41:int = 0;
			var _local29:String = null;
			var _local32:int = 0;
			var _local13:int = 0;
			var _local9:Array = null;
			var _local34:Array = null;
			var _local15:OpCode = null;
			var _local42:Array = null;
			var _local23:Boolean = false;
			var _local8:* = 0;
			var _local49:* = 0;
			var _local43:int = 0;
			var _local25:Boolean = false;
			var _local7:Array = null;
			var _local16:Array = null;
			var _local18:Register = null;
			var _local10:Array = null;
			var _local38:* = 0;
			var _local26:* = 0;
			var _local50:Array = null;
			var _local31:Boolean = false;
			var _local39:Boolean = false;
			var _local35:* = 0;
			var _local45:* = 0;
			var _local27:int = 0;
			var _local47:* = 0;
			var _local48:* = 0;
			var _local46:int = 0;
			var _local17:Array = null;
			var _local30:Register = null;
			var _local37:Array = null;
			var _local5:Array = null;
			var _local21:* = 0;
			var _local11:* = 0;
			var _local12:Number = NaN;
			var _local6:Sampler = null;
			var _local28:String = null;
			var _local33:* = 0;
			var _local22:* = 0;
			var _local20:String = null;
			var _local40:uint = uint(getTimer());
			_agalcode = new ByteArray();
			_error = "";
			var _local14:Boolean = false;
			if(mode == "fragment") {
				_local14 = true;
			} else if(mode != "vertex") {
				_error = "ERROR: mode needs to be \"fragment\" or \"vertex\" but is \"" + mode + "\".";
			}
			agalcode.endian = "littleEndian";
			agalcode.writeByte(160);
			agalcode.writeUnsignedInt(version);
			agalcode.writeByte(161);
			agalcode.writeByte(_local14 ? 1 : 0);
			initregmap(version,ignorelimits);
			var _local36:Array = source.replace(/[\f\n\r\v]+/g,"\n").split("\n");
			var _local44:int = 0;
			var _local24:int = 0;
			var _local19:int = int(_local36.length);
			_local41 = 0;
			while(_local41 < _local19 && _error == "") {
				_local29 = new String(_local36[_local41]);
				_local29 = _local29.replace(REGEXP_OUTER_SPACES,"");
				_local32 = int(_local29.search("//"));
				if(_local32 != -1) {
					_local29 = _local29.slice(0,_local32);
				}
				_local13 = int(_local29.search(/<.*>/g));
				if(_local13 != -1) {
					_local9 = _local29.slice(_local13).match(/([\w\.\-\+]+)/gi);
					_local29 = _local29.slice(0,_local13);
				}
				_local34 = _local29.match(/^\w{3}/gi);
				if(!_local34) {
					if(_local29.length >= 3) {
						trace("warning: bad line " + _local41 + ": " + _local36[_local41]);
					}
				} else {
					_local15 = OPMAP[_local34[0]];
					if(debugEnabled) {
						trace(_local15);
					}
					if(_local15 == null) {
						if(_local29.length >= 3) {
							trace("warning: bad line " + _local41 + ": " + _local36[_local41]);
						}
					} else {
						_local29 = _local29.slice(_local29.search(_local15.name) + _local15.name.length);
						if(_local15.flags & 0x0100 && version < 2) {
							_error = "error: opcode requires version 2.";
							break;
						}
						if(_local15.flags & 0x40 && _local14) {
							_error = "error: opcode is only allowed in vertex programs.";
							break;
						}
						if(_local15.flags & 0x20 && !_local14) {
							_error = "error: opcode is only allowed in fragment programs.";
							break;
						}
						if(verbose) {
							trace("emit opcode=" + _local15);
						}
						agalcode.writeUnsignedInt(_local15.emitCode);
						_local24++;
						if(_local24 > 2048) {
							_error = "error: too many opcodes. maximum is 2048.";
							break;
						}
						_local42 = _local29.match(/vc\[([vof][acostdip]?)(\d*)?(\.[xyzw](\+\d{1,3})?)?\](\.[xyzw]{1,4})?|([vof][acostdip]?)(\d*)?(\.[xyzw]{1,4})?/gi);
						if(!_local42 || _local42.length != _local15.numRegister) {
							_error = "error: wrong number of operands. found " + _local42.length + " but expected " + _local15.numRegister + ".";
							break;
						}
						_local23 = false;
						_local8 = 160;
						_local49 = _local42.length;
						_local43 = 0;
						while(_local43 < _local49) {
							_local25 = false;
							_local7 = _local42[_local43].match(/\[.*\]/gi);
							if(_local7 && _local7.length > 0) {
								_local42[_local43] = _local42[_local43].replace(_local7[0],"0");
								if(verbose) {
									trace("IS REL");
								}
								_local25 = true;
							}
							_local16 = _local42[_local43].match(/^\b[A-Za-z]{1,2}/gi);
							if(!_local16) {
								_error = "error: could not parse operand " + _local43 + " (" + _local42[_local43] + ").";
								_local23 = true;
								break;
							}
							_local18 = REGMAP[_local16[0]];
							if(debugEnabled) {
								trace(_local18);
							}
							if(_local18 == null) {
								_error = "error: could not find register name for operand " + _local43 + " (" + _local42[_local43] + ").";
								_local23 = true;
								break;
							}
							if(_local14) {
								if(!(_local18.flags & 0x20)) {
									_error = "error: register operand " + _local43 + " (" + _local42[_local43] + ") only allowed in vertex programs.";
									_local23 = true;
									break;
								}
								if(_local25) {
									_error = "error: register operand " + _local43 + " (" + _local42[_local43] + ") relative adressing not allowed in fragment programs.";
									_local23 = true;
									break;
								}
							} else if(!(_local18.flags & 0x40)) {
								_error = "error: register operand " + _local43 + " (" + _local42[_local43] + ") only allowed in fragment programs.";
								_local23 = true;
								break;
							}
							_local42[_local43] = _local42[_local43].slice(_local42[_local43].search(_local18.name) + _local18.name.length);
							_local10 = _local25 ? _local7[0].match(/\d+/) : _local42[_local43].match(/\d+/);
							_local38 = 0;
							if(_local10) {
								_local38 = uint(_local10[0]);
							}
							if(_local18.range < _local38) {
								_error = "error: register operand " + _local43 + " (" + _local42[_local43] + ") index exceeds limit of " + (_local18.range + 1) + ".";
								_local23 = true;
								break;
							}
							_local26 = 0;
							_local50 = _local42[_local43].match(/(\.[xyzw]{1,4})/);
							_local31 = _local43 == 0 && !(_local15.flags & 0x80);
							_local39 = _local43 == 2 && _local15.flags & 8;
							_local35 = 0;
							_local45 = 0;
							_local27 = 0;
							if(_local31 && _local25) {
								_error = "error: relative can not be destination";
								_local23 = true;
								break;
							}
							if(_local50) {
								_local26 = 0;
								_local48 = uint(_local50[0].length);
								_local46 = 1;
								while(_local46 < _local48) {
									_local47 = _local50[0].charCodeAt(_local46) - "x".charCodeAt(0);
									if(_local47 > 2) {
										_local47 = 3;
									}
									if(_local31) {
										_local26 |= 1 << _local47;
									} else {
										_local26 |= _local47 << (_local46 - 1 << 1);
									}
									_local46++;
								}
								if(!_local31) {
									while(_local46 <= 4) {
										_local26 |= _local47 << (_local46 - 1 << 1);
										_local46++;
									}
								}
							} else {
								_local26 = _local31 ? 15 : 228;
							}
							if(_local25) {
								_local17 = _local7[0].match(/[A-Za-z]{1,2}/gi);
								_local30 = REGMAP[_local17[0]];
								if(_local30 == null) {
									_error = "error: bad index register";
									_local23 = true;
									break;
								}
								_local35 = _local30.emitCode;
								_local37 = _local7[0].match(/(\.[xyzw]{1,1})/);
								if(_local37.length == 0) {
									_error = "error: bad index register select";
									_local23 = true;
									break;
								}
								_local45 = _local37[0].charCodeAt(1) - "x".charCodeAt(0);
								if(_local45 > 2) {
									_local45 = 3;
								}
								_local5 = _local7[0].match(/\+\d{1,3}/gi);
								if(_local5.length > 0) {
									_local27 = int(_local5[0]);
								}
								if(_local27 < 0 || _local27 > 255) {
									_error = "error: index offset " + _local27 + " out of bounds. [0..255]";
									_local23 = true;
									break;
								}
								if(verbose) {
									trace("RELATIVE: type=" + _local35 + "==" + _local17[0] + " sel=" + _local45 + "==" + _local37[0] + " idx=" + _local38 + " offset=" + _local27);
								}
							}
							if(verbose) {
								trace("  emit argcode=" + _local18 + "[" + _local38 + "][" + _local26 + "]");
							}
							if(_local31) {
								agalcode.writeShort(_local38);
								agalcode.writeByte(_local26);
								agalcode.writeByte(_local18.emitCode);
								_local8 -= 32;
							} else if(_local39) {
								if(verbose) {
									trace("  emit sampler");
								}
								_local21 = 5;
								_local11 = uint(_local9 == null ? 0 : _local9.length);
								_local12 = 0;
								_local46 = 0;
								while(_local46 < _local11) {
									if(verbose) {
										trace("    opt: " + _local9[_local46]);
									}
									_local6 = SAMPLEMAP[_local9[_local46]];
									if(_local6 == null) {
										_local12 = Number(_local9[_local46]);
										if(verbose) {
											trace("    bias: " + _local12);
										}
									} else {
										if(_local6.flag != 16) {
											_local21 &= ~(15 << _local6.flag);
										}
										_local21 |= _local6.mask << _local6.flag;
									}
									_local46++;
								}
								agalcode.writeShort(_local38);
								agalcode.writeByte(int(_local12 * 8));
								agalcode.writeByte(0);
								agalcode.writeUnsignedInt(_local21);
								if(verbose) {
									trace("    bits: " + (_local21 - 5));
								}
								_local8 -= 64;
							} else {
								if(_local43 == 0) {
									agalcode.writeUnsignedInt(0);
									_local8 -= 32;
								}
								agalcode.writeShort(_local38);
								agalcode.writeByte(_local27);
								agalcode.writeByte(_local26);
								agalcode.writeByte(_local18.emitCode);
								agalcode.writeByte(_local35);
								agalcode.writeShort(_local25 ? _local45 | 0x8000 : 0);
								_local8 -= 64;
							}
							_local43++;
						}
						_local43 = 0;
						while(_local43 < _local8) {
							agalcode.writeByte(0);
							_local43 += 8;
						}
						if(_local23) {
							break;
						}
					}
				}
				_local41++;
			}
			if(_error != "") {
				_error += "\n  at line " + _local41 + " " + _local36[_local41];
				agalcode.length = 0;
				trace(_error);
			}
			if(debugEnabled) {
				_local28 = "generated bytecode:";
				_local33 = agalcode.length;
				_local22 = 0;
				while(_local22 < _local33) {
					if(!(_local22 % 16)) {
						_local28 += "\n";
					}
					if(!(_local22 % 4)) {
						_local28 += " ";
					}
					_local20 = agalcode[_local22].toString(16);
					if(_local20.length < 2) {
						_local20 = "0" + _local20;
					}
					_local28 += _local20;
					_local22++;
				}
				trace(_local28);
			}
			if(verbose) {
				trace("AGALMiniAssembler.assemble time: " + (getTimer() - _local40) / 1000 + "s");
			}
			return agalcode;
		}
		
		private function initregmap(version:uint, ignorelimits:Boolean) : void {
			REGMAP["va"] = new Register("va","vertex attribute",0,ignorelimits ? 1024 : (version == 1 || version == 2 ? 7 : 15),0x40 | 2);
			REGMAP["vc"] = new Register("vc","vertex constant",1,ignorelimits ? 1024 : (version == 1 ? 127 : 249),0x40 | 2);
			REGMAP["vt"] = new Register("vt","vertex temporary",2,ignorelimits ? 1024 : (version == 1 ? 7 : 25),0x40 | 1 | 2);
			REGMAP["vo"] = new Register("vo","vertex output",3,ignorelimits ? 1024 : 0,0x40 | 1);
			REGMAP["vi"] = new Register("vi","varying",4,ignorelimits ? 1024 : (version == 1 ? 7 : 9),0x40 | 0x20 | 2 | 1);
			REGMAP["fc"] = new Register("fc","fragment constant",1,ignorelimits ? 1024 : (version == 1 ? 27 : (version == 2 ? 63 : 199)),0x20 | 2);
			REGMAP["ft"] = new Register("ft","fragment temporary",2,ignorelimits ? 1024 : (version == 1 ? 7 : 25),0x20 | 1 | 2);
			REGMAP["fs"] = new Register("fs","texture sampler",5,ignorelimits ? 1024 : 7,0x20 | 2);
			REGMAP["fo"] = new Register("fo","fragment output",3,ignorelimits ? 1024 : (version == 1 ? 0 : 3),0x20 | 1);
			REGMAP["fd"] = new Register("fd","fragment depth output",6,ignorelimits ? 1024 : (version == 1 ? -1 : 0),0x20 | 1);
			REGMAP["op"] = REGMAP["vo"];
			REGMAP["i"] = REGMAP["vi"];
			REGMAP["v"] = REGMAP["vi"];
			REGMAP["oc"] = REGMAP["fo"];
			REGMAP["od"] = REGMAP["fd"];
			REGMAP["fi"] = REGMAP["vi"];
		}
	}
}

class OpCode {
	private var _emitCode:uint;
	
	private var _flags:uint;
	
	private var _name:String;
	
	private var _numRegister:uint;
	
	public function OpCode(name:String, numRegister:uint, emitCode:uint, flags:uint) {
		super();
		_name = name;
		_numRegister = numRegister;
		_emitCode = emitCode;
		_flags = flags;
	}
	
	public function get emitCode() : uint {
		return _emitCode;
	}
	
	public function get flags() : uint {
		return _flags;
	}
	
	public function get name() : String {
		return _name;
	}
	
	public function get numRegister() : uint {
		return _numRegister;
	}
	
	public function toString() : String {
		return "[OpCode name=\"" + _name + "\", numRegister=" + _numRegister + ", emitCode=" + _emitCode + ", flags=" + _flags + "]";
	}
}

class Register {
	private var _emitCode:uint;
	
	private var _name:String;
	
	private var _longName:String;
	
	private var _flags:uint;
	
	private var _range:uint;
	
	public function Register(name:String, longName:String, emitCode:uint, range:uint, flags:uint) {
		super();
		_name = name;
		_longName = longName;
		_emitCode = emitCode;
		_range = range;
		_flags = flags;
	}
	
	public function get emitCode() : uint {
		return _emitCode;
	}
	
	public function get longName() : String {
		return _longName;
	}
	
	public function get name() : String {
		return _name;
	}
	
	public function get flags() : uint {
		return _flags;
	}
	
	public function get range() : uint {
		return _range;
	}
	
	public function toString() : String {
		return "[Register name=\"" + _name + "\", longName=\"" + _longName + "\", emitCode=" + _emitCode + ", range=" + _range + ", flags=" + _flags + "]";
	}
}

class Sampler {
	private var _flag:uint;
	
	private var _mask:uint;
	
	private var _name:String;
	
	public function Sampler(name:String, flag:uint, mask:uint) {
		super();
		_name = name;
		_flag = flag;
		_mask = mask;
	}
	
	public function get flag() : uint {
		return _flag;
	}
	
	public function get mask() : uint {
		return _mask;
	}
	
	public function get name() : String {
		return _name;
	}
	
	public function toString() : String {
		return "[Sampler name=\"" + _name + "\", flag=\"" + _flag + "\", mask=" + mask + "]";
	}
}
