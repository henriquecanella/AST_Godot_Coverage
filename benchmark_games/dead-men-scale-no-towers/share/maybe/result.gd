class_name Result
extends Node

var value
var error
var is_error

func _init(new_value, err_msg, _is_err):
	value = new_value
	error = err_msg
	is_error = _is_err

func is_ok() -> bool:
	return !is_error

func is_err() -> bool:
	return is_error

func ok() -> Maybe:
	if is_ok():
		return Maybe.Some(value)
	return Maybe.None()

func err() -> Maybe:
	if is_err():
		return Maybe.Some(error)
	return Maybe.None()

static func Ok(new_value) -> Result:
	return Result.new(new_value, OK, false)

static func Err(msg) -> Result:
	return Result.new(null, msg, true)