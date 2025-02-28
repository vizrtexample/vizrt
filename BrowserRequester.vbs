Dim browser As PluginInstance = this.GetFunctionPluginInstance("Browser")
Dim script As PluginInstance = this.ScriptPluginInstance

Dim method As Array [String]
method.Push("  GET  ")
method.Push("  POST  ")
method.Push("  PUT  ")
method.Push("  DELETE  ")

Sub OnInitParameters()
    System.Map.RegisterChangedCallback(this.VizId & " BROWSER STATUS")
    RegisterRadioButton("method", "Method:", 0, method)
    RegisterParameterString("url", "Url:", "", 80, 1000, "")
    RegisterParameterText("jscode", "", 480, 100)
    RegisterParameterText("data", "{\" key1 \ ":\" value \ "}", 580, 50)
    RegisterParameterText("console", "", 580, 100)
    RegisterPushButton("send", " SEND ", 1)
End Sub

Sub OnInit()
    browser.SetParameterString("url", GetParameterString("url"))
    script.SetParameterString("jscode", "")
    browser.SetParameterString("javascript", "")
    browser.PushButton("reload")
    script.SetParameterString("jscode", JsFetchData() & JsFunctions())
    Dim imgid as String = system.sendCommand("#" & this.VizId & "*TEXTURE*IMAGE*OBJECT_ID GET")
    system.sendcommand("#" & this.Vizid & "*TEXTURE*IMAGE2 SET " & imgid & " NULL")
End Sub

Sub OnParameterChanged(parameterName As String)
    If parameterName = = "url" Then
        If GetParameterString("url") <> "" Then
            browser.SetParameterString("url", GetParameterString("url"))
            browser.SetParameterString("javascript", "")
        Else
            browser.SetParameterString("url", "vizgh:///Browser/snap.png")
            browser.SetParameterString("javascript", "")
            script.SetParameterString("console", "")
            SendGuiRefresh()
        End If
    End If
End Sub

Sub OnGuiStatus()
    'Debug Javascript SHOW/HIDE
    SendGuiParameterShow("jscode", HIDE)
    Select Case GetParameterInt("method")
        Case 0
            SendGuiParameterShow("data", HIDE)
        Case 1
            SendGuiParameterShow("data", SHOW)
        Case 2
            SendGuiParameterShow("data", SHOW)
        Case 3
            SendGuiParameterShow("data", SHOW)
    End Select
End Sub

Sub OnExecAction(buttonId as Integer)
    Dim js as String = GetParameterString("jscode")
    js.Substitute("<URL>", GetParameterString("url"), True)
    Select Case GetParameterInt("method")
        Case 0
            js.Substitute("<METHOD>", "GET", True)
            js.Substitute("<DATA>", "null", True)
        Case 1
            js.Substitute("<METHOD>", "POST", True)
            js.Substitute("<DATA>", GetParameterString("data"), True)
        Case 2
            js.Substitute("<METHOD>", "PUT", True)
            js.Substitute("<DATA>", GetParameterString("data"), True)
        Case 3
            js.Substitute("<METHOD>", "DELETE", True)
            js.Substitute("<DATA>", GetParameterString("data"), True)
    End Select
    If buttonId = 1 Then
        script.SetParameterString("console", "")
        browser.SetParameterString("javascript", js)
        browser.PushButton("execjavascript")
    End If
End Sub

Sub OnSharedMemoryVariableChanged(map As SharedMemory, mapKey As String)
    If mapKey = this.VizId & " BROWSER STATUS" Then
        Dim response As String = map [mapKey]
        If response.Find("VizCallback") <> - 1 Then
            response.Substitute("0 javascript VizCallback", "", False)
            response.Substitute("1 javascript VizCallback", "", False)
            response.Trim
            If GetParameterInt("method") = 0 Then
                script.SetParameterString("console", response)
                SendGuiRefresh()
            End If
            If GetParameterInt("method") = 1 Then
                script.SetParameterString("console", response)
                SendGuiRefresh()
            End If
        Else
        End If
    End If
End Sub

Function JsFetchData() As String
    Dim jsCode As String
    jsCode & = "fetchData('<URL>', method = '<METHOD>', data = <DATA>)" & "\n\n"
    jsCode & = "function fetchData(url, method, data = null) {" & "\n"
    jsCode & = "  document.body.innerHTML = '';" & "\n"
    jsCode & = "  let options = {" & "\n"
    jsCode & = "    method: method," & "\n"
    jsCode & = "    headers: {}," & "\n"
    jsCode & = "  };" & "\n"
    jsCode & = "  if ((method === 'POST' || method === 'PUT' || method === 'DELETE') && data) {" & "\n"
    jsCode & = "    options.headers['Content-Type'] = 'application/json';" & "\n"
    jsCode & = "    options.body = JSON.stringify(data);" & "\n"
    jsCode & = "  }" & "\n"
    jsCode & = "  fetch(url, options)" & "\n"
    jsCode & = "  .then((response) => {" & "\n"
    jsCode & = "     let contentType = response.headers.get('Content-Type') || 'text/plain';" & "\n"
    jsCode & = "     return response.text().then((text) => ({ status: response.status, statusText: response.statusText, type: contentType, text }));" & "\n"
    jsCode & = "  })" & "\n"
    jsCode & = ".then(({ status, statusText, type, text }) => {" & "\n"
    jsCode & = "    let str = '';" & "\n"
    jsCode & = "    if (type.startsWith(\" application / xml \ ") || type.startsWith(\" text / xml \ ")) {" & "\n"
    jsCode & = "      text = text.replace(/>\\s*/g, '>').replace(/\\s*</g, '<');" & "\n"
    jsCode & = "      let xml = new DOMParser().parseFromString(text, \" text / xml \ ");" & "\n"
    jsCode & = "      str = JSON.stringify(xmlToJson(xml));" & "\n"
    jsCode & = "    }" & "\n"
    jsCode & = "    else if (type.startsWith(\" application / json \ ")) {" & "\n"
    jsCode & = "      str = JSON.stringify(JSON.parse(text));" & "\n"
    jsCode & = "    }" & "\n"
    jsCode & = "    else if (type.startsWith(\" text / csv \ ")) {" & "\n"
    jsCode & = "      str = JSON.stringify(csvToJson(text, \" \ ", \" ; \ "));" & "\n"
    jsCode & = "    }" & "\n"
    jsCode & = "    else if (type.startsWith(\" text / plain \ ")) {" & "\n"
    jsCode & = "      str = JSON.stringify({ text: text.trim() });" & "\n"
    jsCode & = "    }" & "\n"
    jsCode & = "    else if (type.startsWith(\" text / html \ ")) {" & "\n"
    jsCode & = "      let parser = new DOMParser();" & "\n"
    jsCode & = "      let doc = parser.parseFromString(text, \" text / html \ ");" & "\n"
    jsCode & = "      str = JSON.stringify({ html: doc.body.innerHTML, text: doc.body.textContent.trim() });" & "\n"
    jsCode & = "    }" & "\n"
    jsCode & = "    else {" & "\n"
    jsCode & = "      str = JSON.stringify({ error: `Unsupported data format: ${type}`, status });" & "\n"
    jsCode & = "    }" & "\n"
    jsCode & = "    window.vizrt.VizCallback(str);" & "\n"
    jsCode & = "    document.body.innerHTML = str;" & "\n"
    jsCode & = "  })" & "\n"
    jsCode & = "  .catch(error => {" & "\n"
    jsCode & = "    let errorMsg = JSON.stringify({ error: error.message });" & "\n"
    jsCode & = "    window.vizrt.VizCallback(errorMsg);" & "\n"
    jsCode & = "    document.body.innerHTML = errorMsg;" & "\n"
    jsCode & = "  });" & "\n"
    jsCode & = "}" & "\n\n"
    JsFetchData = jsCode
End Function


Function JsFunctions() As String
    Dim jsCode As String
    'XmlToJson
    jsCode & = "function xmlToJson(xml) {" & "\n"
    jsCode & = "  var obj = {};" & "\n"
    jsCode & = "  if (xml.nodeType == 1) {" & "\n"
    jsCode & = "    if (xml.attributes.length > 0) {" & "\n"
    jsCode & = "      obj[\" @ attributes \ "] = {};" & "\n"
    jsCode & = "      for (var j = 0; j < xml.attributes.length; j++) {" & "\n"
    jsCode & = "        var attribute = xml.attributes.item(j);" & "\n"
    jsCode & = "        obj[\" @ attributes \ "][attribute.nodeName] = attribute.nodeValue;" & "\n"
    jsCode & = "      }" & "\n"
    jsCode & = "    }" & "\n"
    jsCode & = "  } else if (xml.nodeType == 3) {" & "\n"
    jsCode & = "    obj = xml.nodeValue;" & "\n"
    jsCode & = "  }" & "\n"
    jsCode & = "  var textNodes = [].slice.call(xml.childNodes).filter(function(node) {" & "\n"
    jsCode & = "    return node.nodeType === 3;" & "\n"
    jsCode & = "  });" & "\n"
    jsCode & = "  if (xml.hasChildNodes() && xml.childNodes.length === textNodes.length) {" & "\n"
    jsCode & = "    obj = [].slice.call(xml.childNodes).reduce(function(text, node) {" & "\n"
    jsCode & = "      return text + node.nodeValue;" & "\n"
    jsCode & = "    }, \" \ ");" & "\n"
    jsCode & = "  } else if (xml.hasChildNodes()) {" & "\n"
    jsCode & = "    for (var i = 0; i < xml.childNodes.length; i++) {" & "\n"
    jsCode & = "      var item = xml.childNodes.item(i);" & "\n"
    jsCode & = "      var nodeName = item.nodeName;" & "\n"
    jsCode & = "      if (typeof obj[nodeName] == \" undefined \ ") {" & "\n"
    jsCode & = "        obj[nodeName] = xmlToJson(item);" & "\n"
    jsCode & = "      } else {" & "\n"
    jsCode & = "        if (typeof obj[nodeName].push == \" undefined \ ") {" & "\n"
    jsCode & = "          var old = obj[nodeName];" & "\n"
    jsCode & = "          obj[nodeName] = [];" & "\n"
    jsCode & = "          obj[nodeName].push(old);" & "\n"
    jsCode & = "        }" & "\n"
    jsCode & = "        obj[nodeName].push(xmlToJson(item));" & "\n"
    jsCode & = "      }" & "\n"
    jsCode & = "    }" & "\n"
    jsCode & = "  }" & "\n"
    jsCode & = "  return obj;" & "\n"
    jsCode & = "}" & "\n\n"
    'CsvToJson Viz 5...
    jsCode & = "function csvToJson(text, quoteChar = \" \ ", delimiter = \" ; \ ", hasHeader = true) {" & "\n"
    jsCode & = "  text = text.trim();" & "\n"
    jsCode & = "  let rows = text.split(\" \ \ n \ ");" & "\n"
    jsCode & = "  const regex = new RegExp(`\\\\s*(${quoteChar})?(.*?)\\\\1\\\\s*(?:${delimiter}|$)`, \" gs \ ");" & "\n"
    jsCode & = "  const match = (line) => {" & "\n"
    jsCode & = "    return [...line.matchAll(regex)]" & "\n"
    jsCode & = "      .map((m) => m[2].trim())" & "\n"
    jsCode & = "      .filter((val, i, arr) => i < arr.length - 1 || val);" & "\n"
    jsCode & = "  };" & "\n"
    jsCode & = "  let headers;" & "\n"
    jsCode & = "  if (hasHeader) {" & "\n"
    jsCode & = "    headers = match(rows.shift());" & "\n"
    jsCode & = "  } else {" & "\n"
    jsCode & = "    const firstRow = match(rows[0]);" & "\n"
    jsCode & = "    headers = firstRow.map((_, i) => `column_${i}`);" & "\n"
    jsCode & = "  }" & "\n"
    jsCode & = "  return rows.map((line) => {" & "\n"
    jsCode & = "    return match(line).reduce((acc, cur, i) => {" & "\n"
    jsCode & = "      const key = headers[i];" & "\n"
    jsCode & = "      const val = cur === \" \ " ? null : isNaN(cur) ? cur : Number(cur);" & "\n"
    jsCode & = "      return { ...acc, [key]: val };" & "\n"
    jsCode & = "    }, {});" & "\n"
    jsCode & = "  });" & "\n"
    jsCode & = "}" & "\n\n"
    JsFunctions = jsCode
End Function

