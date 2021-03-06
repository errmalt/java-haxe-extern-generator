// Copyright (c) 2013 Christopher Kaster
//
// This file is part of java-haxe-extern-generator <https://github.com/kasoki/java-haxe-extern-generator>.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
package;

import java.lang.reflect.Modifier;
import java.lang.Class;

class GeneratorType {
	public var name(default, null):String;
	public var nameWithoutPackage(get, null):String;

	private static var types:Map<String, GeneratorType>;

	public static var imports:Array<GeneratorType>;

	private var _class:Class<Dynamic>;

	private function new(classType:Class<Dynamic>) {
		this._class = classType;

		this.name = classType.getCanonicalName();
	}

	private function get_nameWithoutPackage():String {
		return GeneratorClass.getClassName(this._class, true);
	}

	public function asHaxeType():String {
		var isArray:Bool = false;

		var name = this.nameWithoutPackage;

		if(name.indexOf("[") > -1) {
			isArray = true;

			name = name.split('[]')[0];
		}

		switch(name) {
			case "String":
				name = "String";
			case "CharSequence":
				name = "String";
			case "char":
				name = "String";

			case "int":
				name = "Int";
			case "short":
				name = "Int";
			case "long":
				name = "Int";
			case "byte":
				name = "Int";

			case "float":
				name = "Float";
			case "double":
				name = "Float";

			case "boolean":
				name = "Bool";

			case "void":
				name = "Void";

			case "Object":
				name = "Dynamic";

			case "Class":
				name = "Class<Dynamic>";

			case "List":
				name = "List<Dynamic>";

			case "ArrayList":
				name = "ArrayList<Dynamic>";
		}

		var result = name;

		if(isArray) {
			result = "Array<" + result + ">";
		}

		return result;
	}

	public static function get(_class:Class<Dynamic>):GeneratorType {
		var name = _class.getCanonicalName();

		if(types.exists(name)) {
			return types.get(name);
		} else {
			var generatorType:GeneratorType = new GeneratorType(_class);

			if(name.indexOf('.') > -1) {
				var isArray:Bool = name.indexOf('[]') > -1;

				var __class = _class;

				if(isArray) {
					__class = _class.getComponentType();
				}

				var importClass = null;

				var className = GeneratorClass.getClassName(__class);

				try {
					if(!isInnerClass(__class)) {
						importClass = new GeneratorType(__class);

					} else {
						var parentClass:String = __class.getPackage().getName() + "." + className.split('.')[0];

						importClass = new GeneratorType(Generator.classLoader.loadClass(parentClass));
					}
				} catch(ex:java.lang.Exception) {
					ex.printStackTrace();
				}

				if(!importExists(importClass) && importClass != null) {
					imports.push(importClass);
				}
			}

			types.set(name, generatorType);

			return generatorType;
		}
	}

	private static function importExists(importClass:GeneratorType):Bool {
		for(generatorType in imports) {
			if(generatorType.name == importClass.name) {
				return true;
			}
		}

		return false;
	}

	private static function isInnerClass(_class:Class<Dynamic>):Bool {
		var className:String = GeneratorClass.getClassName(_class);
		return className.indexOf('.') > -1;
	}

	public static function __init__() {
		types = new Map<String, GeneratorType>();
		imports = new Array<GeneratorType>();
	}
}