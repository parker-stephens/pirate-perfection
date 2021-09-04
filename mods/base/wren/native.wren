
class Logger {
	foreign static log(text)
}

class IO {
	foreign static listDirectory(path, dirs)
	foreign static info(path) // returns: none, file, dir
	foreign static read(path) // get file contents
	foreign static dynamic_import(path) // import a file dynamically
	foreign static idstring_hash(data) // hash a string
	foreign static load_plugin(filename) // load an external plugin
}

foreign class XML {
	construct new(text) {}
	foreign static try_parse(text) // Basically a fancy constructor

	foreign type
	foreign text
	foreign text=(val)
	foreign string
	foreign name
	foreign name=(val)
	foreign [name] // attribute
	foreign [name]=(val) // attribute
	foreign attribute_names

	foreign create_element(name)
	foreign delete()

	foreign detach()
	foreign clone()
	foreign attach(child)
	foreign attach(child, prev_child)

	// Structure accessors
	foreign next
	foreign prev
	foreign parent
	foreign first_child
	foreign last_child

	// Helpers
	is_element {
		return this.name[0..2] != "!--"
	}

	next_element {
		var elem = next
		while(elem != null) {
			if(elem.is_element) break
			elem = elem.next
		}
		return elem
	}

	ensure_element_next {
		var elem = this
		while(elem != null) {
			if(elem.is_element) break
			elem = elem.next
		}
		return elem
	}

	element_children {
		var arr = []
		var elem = first_child
		while(elem != null) {
			if(elem.is_element) arr.add(elem)
			elem = elem.next
		}
		return arr
	}
}
