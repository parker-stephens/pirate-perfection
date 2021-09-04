import "base/native" for Logger, IO, XML

var Tweakers = []
var XMLTweakers = []

class BaseTweaker {
	static tweak(name, ext, text) {
		for (tweaker in Tweakers) {
			var result = tweaker.tweak_text(name, ext, text)
			if(result != null) text = result
		}
		var interestedTweakers = []
		for (tweaker in XMLTweakers) {
			if(tweaker.tweaks(name, ext)) {
				interestedTweakers.add(tweaker)
			}
		}
		if(interestedTweakers.count > 0) {
			Logger.log("XML-Tweaking Bundle File %(name).%(ext)")
			var xml = XML.new(text)
			for (tweaker in interestedTweakers) {
				tweaker.tweak_xml(name, ext, xml)
			}
			text = xml.string
			xml.delete()
		}
		return text
	}
}

class TweakRegistry {
	static RegisterTextTweaker(tweaker) {
		Tweakers.add(tweaker)
	}
	static RegisterXMLTweaker(tweaker) {
		XMLTweakers.add(tweaker)
	}
}

import "base/private/xml_loader"
