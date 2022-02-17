extends Node

func get_request(url):
	var http = HTTPRequest.new()
	add_child(http)
	http.request(url)
	var response = await http.request_completed
	var resp = response[3].get_string_from_utf8()
	http.queue_free()
	return resp

func put_request(url,data):
	var http = HTTPRequest.new()
	add_child(http)
	var headers = ["Content-Type: application/json"]
	http.request(url, headers, true, HTTPClient.METHOD_PUT, data)
	var response = await http.request_completed
	http.queue_free()
	return response

func delete_request(url):
	var http = HTTPRequest.new()
	add_child(http)
	var headers = []
	http.request(url,headers,true,HTTPClient.METHOD_DELETE)
	var response = await http.request_completed
	http.queue_free()
	return response
