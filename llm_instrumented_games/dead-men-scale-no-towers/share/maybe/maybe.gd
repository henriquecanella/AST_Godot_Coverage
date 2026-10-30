# 🤔 what even is null?
class_name Maybe
extends RefCounted

var value
var has_value: bool = false

func _init(new_value = null):
	self.value = new_value
	self.has_value = new_value != null

func unwrap():
	assert(self.has_value, "Tried to unwrap a null value!")
	return self.value

func expect(message: String):
	assert(self.has_value, message)
	return self.value

func is_some():
	return self.has_value

func is_none():
	return !self.has_value

func unwrap_or(default_value):
	if self.has_value:
		return self.value
	else:
		return default_value

func unwrap_or_else(fn):
	if self.has_value:
		return self.value
	else:
		return fn.call()

func expr():
	if self.has_value:
		return { "Some": self.value }
	else:
		return "None"

func or_else(other: Maybe) -> Maybe:
	if self.has_value:
		return self
	elif other.has_value:
		return other
	else:
		return self
	
static func Some(new_value):
	return Maybe.new(new_value)

static func None():
	return Maybe.new()
