import "base/native" for Logger, IO, XML
import "base/base" for TweakRegistry

/**
 * XML Tweak Applier
 *
 * This loads and applies XML tweak files
 */
class XMLTweakApplier {
	construct new() {
		/**
		 * A map of lists of tweak filenames
		 * Here's an example value of it (in Lua syntax):
		 * _xml_tweaks = {
		 *   ["2301c70c9bd10234.e8cc76b954399722"] = { -- light intensity db
		 *     "mods/mytest/mytweak-1.xml",
		 *     "mods/mytest/mytweak-2.xml",
		 *     "mods/myothermod/tweak.xml",
		 *   },
		 * }
		 */
		_xml_tweaks = {}
	}

	// Mark that an XML file <path> tweaks the bundled file <name>.<ext>
	add_tweak(name, ext, path) {
		// Check the tweak list exists
		var full = "%(name).%(ext)"
		if(_xml_tweaks[full] == null) _xml_tweaks[full] = []
		var tweaklist = _xml_tweaks[full]

		// Ensure we don't add the same tweak twice
		for(tweak in tweaklist) {
			if(tweak == path) return
		}

		// Add the tweak
		tweaklist.add(path)
	}

	// Returns whether or not the tweaker needs to tweak the bundled file <name>.<ext>
	tweaks(name, ext) {
		var full = "%(name).%(ext)"
		return _xml_tweaks[full] != null
	}

	// Tweak an XML file
	tweak_xml(name, ext, xml) {
		// Find the tweak list
		var full = "%(name).%(ext)"
		var tweaks = _xml_tweaks[full]

		// Apply each of the required tweaks
		for(path in tweaks) {
			apply_tweak(name, ext, xml, path)
		}
	}

	/**
	 * Apply a tweak file to a bundled file
	 *
	 * @param name The (hashed) name of the bundle file
	 * @param ext The (hashed) extension of the bundle file
	 * @param xml The XML object representation of the bundled file
	 * @param tweak_path The path of the tweak file to read and apply
	 */
	apply_tweak(name, ext, xml, tweak_path) {
		// Find all the relevant tweaks
		var tweaks = [] // List of XML elements representing `<tweak>` tags
		XMLTweakApplier.find_tweaks(tweak_path, name, ext, tweaks)

		for(tweak in tweaks) {
			// Search for the <search> and <target> elements
			var search_node = null
			var target_node = null

			for (elem in tweak.element_children) {
				var name = elem.name
				if(name == "search") {
					// TODO raise error if duplicate search elements exist
					search_node = elem
				} else if(name == "target") {
					// TODO raise error if duplicate target elements exist
					target_node = elem
				} else {
					Fiber.abort("Unknown element type in unknown tweak XML: %(name)")
				}
			}

			// Verify the presence of the search and target nodes
			if(search_node == null) Fiber.abort("Missing <search> node in unknown tweak XML")
			if(target_node == null) Fiber.abort("Missing <target> node in unknown tweak XML")

			var info = {"count": 0}
			dive_tweak_elem(xml.ensure_element_next, search_node, search_node.first_child.ensure_element_next, target_node, info)

			if(info["count"] == 0) {
				Logger.log("Warning: Failed to apply tweak in unknown XML for %(name).%(ext)")
			}
		}

		// Close all the tweaks
		for(tweak in tweaks) {
			tweak.delete()
		}
	}

	dive_tweak_elem(xml, root_search_node, search_node, target_node, info) {
		var elem = xml
		while (elem != null) {
			if(elem.name == search_node.name) {
				var match = true
				for(name in search_node.attribute_names) {
					if(search_node[name] != elem[name]) {
						match = false
						break
					}
				}
				// TODO something with elem.attribute_names == search_node.attribute_names

				if(match) {
					var next_search_node = search_node.next_element
					if(next_search_node == null) {
						var mult = target_node["multiple"] == "true"
						info["count"] = info["count"] + 1

						apply_tweak_elem(elem, target_node, mult, target_node["mode"])

						if(!mult) return false
					} else {
						var continue = dive_tweak_elem(elem.first_child, root_search_node, next_search_node, target_node, info)
						if(!continue) return false
					}
				}
			}
			elem = elem.next_element
		}

		return true
	}

	// We've found a element that maches the search tag, now tweak it
	apply_tweak_elem(xml, target_node, multiple, mode) {
		if (mode == "attributes") {
			for (elem in target_node.element_children) {
				if(elem.name != "attr") Fiber.abort("In unknown attributes target: bad elem <%(elem.name)>, should be <attr>")
				xml[elem["name"]] = elem["value"]
			}
			return
		}

		var insert_after = mode == "replace" || mode == "append"

		var previous_child = xml
		if(insert_after) xml = xml.parent

		for (elem in target_node.element_children) {
			if(multiple) {
				elem = elem.clone()
			} else {
				elem.detach()
			}
			if(insert_after) {
				xml.attach(elem, previous_child)
			} else {
				xml.attach(elem)
			}
		}

		if(mode == "replace") previous_child.detach().delete()
	}

	static find_tweaks(path, name, ext, tweaks) {
		var data = IO.read(path)
		var xml = XML.new(data)
		var root = xml.first_child // <?xml?> -> <tweak/tweaks>
		var tweaked = false
		if(root.name == "tweaks") {
			for (elem in root.element_children) {
				if(handle_tweak_element(name, ext, elem, tweaks)) tweaked = true
			}
		} else if(root.name == "tweak") {
			if(handle_tweak_element(name, ext, root, tweaks)) tweaked = true
		} else {
			Fiber.abort("Unknown tweak root type in %(path): %(root.name)")
		}
		if(!tweaked) xml.delete()
	}

	static handle_tweak_element(name, ext, elem, tweaks) {
		if(name != handle_idstring(elem["name"])) return false
		if(ext != handle_idstring(elem["extension"])) return false

		tweaks.add(elem)
		return true
	}

	static handle_idstring(input) {
		if(input[0] == "#") {
			return input[1..16]
		} else {
			return IO.idstring_hash(input)
		}
	}
}

var ExecTodo = []
var Tweaker = XMLTweakApplier.new()

class XMLLoader {
	static init() {
		for (mod in IO.listDirectory("mods", true)) {
			var path = "mods/%(mod)/supermod.xml"
			if (IO.info(path) == "file") {
				var data = IO.read(path)
				var xml = XML.new(data)
				for (elem in xml.first_child.element_children) { // <?xml?> -> <mod> -> first elem
					var name = elem.name
					if(name == ":include") {
						// TODO include logic
					} else if(name == "wren") {
						handle_wren_tag(mod, elem)
					} else if(name == "tweak") {
						handle_tweak_file(mod, elem["definition"])
					} else if(name == "native_module") {
						handle_native_module(mod, elem)
					} else {
						// Since this XML file is also used by Lua, don't do anything
						// Fiber.abort("Unknown element type in %(path): %(name)")
					}
				}
				xml.delete()
			}
		}

		for (file in ExecTodo) {
			Logger.log("Loading module %(file)")
			IO.dynamic_import(file)
		}
	}

	static handle_wren_tag(mod, tag) {
		for (elem in tag.element_children) {
			var name = elem.name
			if(name == "base-path") {
				// TODO set base path
			} else if(name == "init") {
				ExecTodo.add(elem["file"])
			} else {
				Fiber.abort("Unknown element type in %(mod):<wren>: %(name)")
			}
		}
	}

	static handle_tweak_file(mod, filename) {
		var path = "mods/%(mod)/%(filename)"
		var data = IO.read(path)
		var xml = XML.new(data)
		var root = xml.first_child // <?xml?> -> <tweak/tweaks>
		if(root.name == "tweaks") {
			for (elem in root.element_children) {
				handle_tweak_element(mod, path, elem)
			}
		} else if(root.name == "tweak") {
			handle_tweak_element(mod, path, root)
		} else {
			Fiber.abort("Unknown tweak root type in %(path): %(root.name)")
		}
		xml.delete()
	}

	static handle_tweak_element(mod, path, root) {
		var name = XMLTweakApplier.handle_idstring(root["name"])
		var extension = XMLTweakApplier.handle_idstring(root["extension"])
		Tweaker.add_tweak(name, extension, path)
	}

	static handle_native_module(mod, elem) {
		// Lua handles everything except "preload" DLLs
		if(elem["loading_vector"] != "preload") return

		var path = "mods/%(mod)/%(elem["filename"])"

		// TODO check platform/architecture

		Logger.log("Loading native plugin for mod \"%(mod)\"")

		IO.load_plugin(path)
	}
}

TweakRegistry.RegisterXMLTweaker(Tweaker)

XMLLoader.init()
