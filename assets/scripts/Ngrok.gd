extends	Node

func start_ngrok(port):
	var thread = Thread.new()
	if OS.get_name() == "macOS":
		thread.start(start_mac_os,port)
	elif OS.get_name() == "Windows":
		thread.start(start_windows,port)	

func kill_ngrok():
	if OS.get_name() == "macOS":
		OS.execute("killall",["ngrok"])

func start_mac_os(port):
	OS.execute("./ngrok",["tcp",port],[],false)

func start_windows(port):
	OS.execute("./ngrok.exe",["tcp",port])

func get_public():
	var	url	= "http://127.0.0.1:4040/api/tunnels"
	var response = null
	while response == null || response == "":
		response = await HTTP.get_request(url)
	response = Firebase.json_parser(response)
	var tunnels = response["tunnels"]
	if len(tunnels) == 0:
		return await get_public()
	var public_url = tunnels[0]["public_url"]
	var splitted_url = public_url.split(":")
	var ip = splitted_url[1].replace("/","")
	var port = str2var(splitted_url[2]) as int
	return {
			"ip":ip,
			"port":port
		}

	


