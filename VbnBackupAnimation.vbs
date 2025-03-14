Dim temp as image
Dim c as container

Sub OnInitParameters()
    RegisterParameterContainer("Container", "Backup Container")
    RegisterPushButton("save", " Save Backup ", 0)
End Sub

Sub OnInit()
    AnimationBackup()
End Sub

Sub OnExecAction(buttonId as Integer)
    If buttonId = = 0 Then
        If c.Valid Then
            println "Log: Save Backup"
            c.Texture = this.Texture
            c.Active = False
        End If
    End If
End Sub

Sub OnExecPerField()
    If this.Texture.Image <> temp Then
        AnimationBackup()
    End If
End Sub

Sub OnParameterChanged(parameterName As String)
    AnimationBackup()
End Sub

Sub AnimationBackup()
    c = GetParameterContainer("Container")
    temp = this.Texture.Image
    System.SendCommand("#" & this.VizId & "*ANIMATION COPY #" & c.VizId & "*ANIMATION")
End Sub

