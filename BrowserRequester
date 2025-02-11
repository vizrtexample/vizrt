dim browser As PluginInstance = this.GetFunctionPluginInstance("Browser")
dim script As PluginInstance = this.ScriptPluginInstance

dim method As Array[String]
	method.Push("  GET  ")
 	method.Push("  POST  ")
    method.Push("  PUT  ")
	method.Push("  DELETE  ")

sub OnInitParameters()
    System.Map.RegisterChangedCallback( this.VizId & " BROWSER STATUS" )
	RegisterRadioButton("method", "Method:", 0, method)
    RegisterParameterString("url", "Url:", "", 80, 1000, "")
    RegisterParameterText("jscode", "", 480, 100)
    RegisterParameterText("data", "{\"key1\":\"value\"}", 580, 50)
    RegisterParameterText("console", "", 580, 100)
	RegisterPushButton( "send", " SEND ", 1 )	
end sub

sub OnInit()
    browser.SetParameterString("url", GetParameterString("url"))
    script.SetParameterString("jscode", "")
    browser.SetParameterString("javascript", "")
    browser.PushButton("reload")
	script.SetParameterString("jscode", JsFetchData() & JsFunctions())
	dim imgid as string = system.sendCommand("#"& this.VizId &"*TEXTURE*IMAGE*OBJECT_ID GET")
	system.sendcommand("#"& this.Vizid &"*TEXTURE*IMAGE2 SET " & imgid &" NULL")
end sub

sub OnParameterChanged(parameterName As String)
    if parameterName == "url" then
	   if GetParameterString("url") <> "" then
          browser.SetParameterString("url", GetParameterString("url"))
          browser.SetParameterString("javascript", "")
	   else
          browser.SetParameterString("url", "vizgh:///Browser/snap.png")
          browser.SetParameterString("javascript", "")
          script.SetParameterString("console", "")
          SendGuiRefresh()
	   end if
    end if
end sub

sub OnGuiStatus()
    'Debug Javascript SHOW/HIDE
    SendGuiParameterShow("jscode", HIDE)
    select case GetParameterInt("method")
       case 0
           SendGuiParameterShow("data", HIDE)
       case 1
           SendGuiParameterShow("data", SHOW)
       case 2
           SendGuiParameterShow("data", SHOW)
       case 3
           SendGuiParameterShow("data", SHOW)
    end select
end sub

sub OnExecAction(buttonId as Integer)
	dim js as string = GetParameterString("jscode")
	js.Substitute("<URL>",  GetParameterString("url"), true)
	select case GetParameterInt("method")
		case 0
            js.Substitute("<METHOD>",  "GET", true)
            js.Substitute("<DATA>",  "null", true)
		case 1
            js.Substitute("<METHOD>",  "POST", true)
            js.Substitute("<DATA>", GetParameterString("data"), true)
		case 2
            js.Substitute("<METHOD>",  "PUT", true)
            js.Substitute("<DATA>", GetParameterString("data"), true)
		case 3
            js.Substitute("<METHOD>",  "DELETE", true)
            js.Substitute("<DATA>", GetParameterString("data"), true)
	end select
	if buttonId = 1 then
	   script.SetParameterString("console", "")
	   browser.SetParameterString("javascript", js)
	   browser.PushButton("execjavascript")
	end if
end sub

sub OnSharedMemoryVariableChanged(map As SharedMemory, mapKey As String)
	if mapKey = this.VizId & " BROWSER STATUS" then
		dim response As String = map[mapKey]
       	if response.Find("VizCallback") <> -1 then
          	response.Substitute("0 javascript VizCallback", "", false)
          	response.Substitute("1 javascript VizCallback", "", false)
          	response.trim
		   if GetParameterInt("method") = 0 then
          		   script.SetParameterString("console", response)
          		   SendGuiRefresh()
       		  end if
		   if GetParameterInt("method") = 1 then
          		   script.SetParameterString("console", response)
          		   SendGuiRefresh()
       		  end if
        else
       	end if 
    end if
end sub

function JsFetchData() As String
	dim jsCode As String
	jsCode &= "fetchData('<URL>', method = '<METHOD>', data = <DATA>)" & "\n\n"
	jsCode &= "function fetchData(url, method, data = null) {" & "\n"
	jsCode &= "  document.body.innerHTML = '';" & "\n"
	jsCode &= "  let options = {" & "\n"
	jsCode &= "    method: method," & "\n"
	jsCode &= "    headers: {}," & "\n"
	jsCode &= "  };" & "\n"
	jsCode &= "  if ((method === 'POST' || method === 'PUT' || method === 'DELETE') && data) {" & "\n"
	jsCode &= "    options.headers['Content-Type'] = 'application/json';" & "\n"
	jsCode &= "    options.body = JSON.stringify(data);" & "\n"
	jsCode &= "  }" & "\n"
	jsCode &= "  fetch(url, options)" & "\n"
	jsCode &= "  .then((response) => {" & "\n"
	jsCode &= "     let contentType = response.headers.get('Content-Type') || 'text/plain';" & "\n"
	jsCode &= "     return response.text().then((text) => ({ status: response.status, statusText: response.statusText, type: contentType, text }));" & "\n"
	jsCode &= "  })" & "\n"
	jsCode &= ".then(({ status, statusText, type, text }) => {" & "\n"
	jsCode &= "    let str = '';" & "\n"
	jsCode &= "    if (type.startsWith(\"application/xml\") || type.startsWith(\"text/xml\")) {" & "\n"
	jsCode &= "      text = text.replace(/>\\s*/g, '>').replace(/\\s*</g, '<');" & "\n"
	jsCode &= "      let xml = new DOMParser().parseFromString(text, \"text/xml\");" & "\n"
	jsCode &= "      str = JSON.stringify(xmlToJson(xml));" & "\n"
	jsCode &= "    }" & "\n"
	jsCode &= "    else if (type.startsWith(\"application/json\")) {" & "\n"
	jsCode &= "      str = JSON.stringify(JSON.parse(text));" & "\n"
	jsCode &= "    }" & "\n"
	jsCode &= "    else if (type.startsWith(\"text/csv\")) {" & "\n"
	jsCode &= "      str = JSON.stringify(csvToJson(text, \"\", \";\"));" & "\n"
	jsCode &= "    }" & "\n"
	jsCode &= "    else if (type.startsWith(\"text/plain\")) {" & "\n"
	jsCode &= "      str = JSON.stringify({ text: text.trim() });" & "\n"
	jsCode &= "    }" & "\n"
	jsCode &= "    else if (type.startsWith(\"text/html\")) {" & "\n"
	jsCode &= "      let parser = new DOMParser();" & "\n"
	jsCode &= "      let doc = parser.parseFromString(text, \"text/html\");" & "\n"
	jsCode &= "      str = JSON.stringify({ html: doc.body.innerHTML, text: doc.body.textContent.trim() });" & "\n"
	jsCode &= "    }" & "\n"
	jsCode &= "    else {" & "\n"
	jsCode &= "      str = JSON.stringify({ error: `Unsupported data format: ${type}`, status });" & "\n"
	jsCode &= "    }" & "\n"
	jsCode &= "    window.vizrt.VizCallback(str);" & "\n"
	jsCode &= "    document.body.innerHTML = str;" & "\n"
	jsCode &= "  })" & "\n"
	jsCode &= "  .catch(error => {" & "\n"
	jsCode &= "    let errorMsg = JSON.stringify({ error: error.message });" & "\n"
	jsCode &= "    window.vizrt.VizCallback(errorMsg);" & "\n"
	jsCode &= "    document.body.innerHTML = errorMsg;" & "\n"
	jsCode &= "  });" & "\n"
	jsCode &= "}" & "\n\n"
    JsFetchData = jsCode
end function


function JsFunctions()As String
	dim jsCode As String
    'XmlToJson
    jsCode &= "function xmlToJson(xml) {" & "\n"
    jsCode &= "  var obj = {};" & "\n"
    jsCode &= "  if (xml.nodeType == 1) {" & "\n"
    jsCode &= "    if (xml.attributes.length > 0) {" & "\n"
    jsCode &= "      obj[\"@attributes\"] = {};" & "\n"
    jsCode &= "      for (var j = 0; j < xml.attributes.length; j++) {" & "\n"
    jsCode &= "        var attribute = xml.attributes.item(j);" & "\n"
    jsCode &= "        obj[\"@attributes\"][attribute.nodeName] = attribute.nodeValue;" & "\n"
    jsCode &= "      }" & "\n"
    jsCode &= "    }" & "\n"
    jsCode &= "  } else if (xml.nodeType == 3) {" & "\n"
    jsCode &= "    obj = xml.nodeValue;" & "\n"
    jsCode &= "  }" & "\n"
    jsCode &= "  var textNodes = [].slice.call(xml.childNodes).filter(function(node) {" & "\n"
    jsCode &= "    return node.nodeType === 3;" & "\n"
    jsCode &= "  });" & "\n"
    jsCode &= "  if (xml.hasChildNodes() && xml.childNodes.length === textNodes.length) {" & "\n"
    jsCode &= "    obj = [].slice.call(xml.childNodes).reduce(function(text, node) {" & "\n"
    jsCode &= "      return text + node.nodeValue;" & "\n"
    jsCode &= "    }, \"\");" & "\n"
    jsCode &= "  } else if (xml.hasChildNodes()) {" & "\n"
    jsCode &= "    for (var i = 0; i < xml.childNodes.length; i++) {" & "\n"
    jsCode &= "      var item = xml.childNodes.item(i);" & "\n"
    jsCode &= "      var nodeName = item.nodeName;" & "\n"
    jsCode &= "      if (typeof obj[nodeName] == \"undefined\") {" & "\n"
    jsCode &= "        obj[nodeName] = xmlToJson(item);" & "\n"
    jsCode &= "      } else {" & "\n"
    jsCode &= "        if (typeof obj[nodeName].push == \"undefined\") {" & "\n"
    jsCode &= "          var old = obj[nodeName];" & "\n"
    jsCode &= "          obj[nodeName] = [];" & "\n"
    jsCode &= "          obj[nodeName].push(old);" & "\n"
    jsCode &= "        }" & "\n"
    jsCode &= "        obj[nodeName].push(xmlToJson(item));" & "\n"
    jsCode &= "      }" & "\n"
    jsCode &= "    }" & "\n"
    jsCode &= "  }" & "\n"
    jsCode &= "  return obj;" & "\n"
    jsCode &= "}" & "\n\n"
    'CsvToJson Viz 5...
    jsCode &= "function csvToJson(text, quoteChar = \"\", delimiter = \";\", hasHeader = true) {" & "\n"
    jsCode &= "  text = text.trim();" & "\n"    
    jsCode &= "  let rows = text.split(\"\\n\");" & "\n"  
    jsCode &= "  const regex = new RegExp(`\\\\s*(${quoteChar})?(.*?)\\\\1\\\\s*(?:${delimiter}|$)`, \"gs\");" & "\n" 
    jsCode &= "  const match = (line) => {" & "\n"
    jsCode &= "    return [...line.matchAll(regex)]" & "\n"
    jsCode &= "      .map((m) => m[2].trim())" & "\n"
    jsCode &= "      .filter((val, i, arr) => i < arr.length - 1 || val);" & "\n"
    jsCode &= "  };" & "\n"
    jsCode &= "  let headers;" & "\n"
    jsCode &= "  if (hasHeader) {" & "\n"
    jsCode &= "    headers = match(rows.shift());" & "\n"
    jsCode &= "  } else {" & "\n"
    jsCode &= "    const firstRow = match(rows[0]);" & "\n"
    jsCode &= "    headers = firstRow.map((_, i) => `column_${i}`);" & "\n"
    jsCode &= "  }" & "\n"
    jsCode &= "  return rows.map((line) => {" & "\n"
    jsCode &= "    return match(line).reduce((acc, cur, i) => {" & "\n"
    jsCode &= "      const key = headers[i];" & "\n"
    jsCode &= "      const val = cur === \"\" ? null : isNaN(cur) ? cur : Number(cur);" & "\n"
    jsCode &= "      return { ...acc, [key]: val };" & "\n"
    jsCode &= "    }, {});" & "\n"
    jsCode &= "  });" & "\n"
    jsCode &= "}" & "\n\n"
    JsFunctions = jsCode
end function

