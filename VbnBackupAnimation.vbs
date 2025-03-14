dim temp as image
dim c as container

sub OnInitParameters()
    RegisterParameterContainer("Container", "Backup Container")
	RegisterPushButton( "save", " Save Backup ", 0 )	
end sub

sub OnInit()
    AnimationBackup()
end sub

sub OnExecAction(buttonId as Integer)
	if buttonId == 0 then
		if c.Valid then
			println "Log: Save Backup"
	    	c.Texture = this.Texture
	    	c.Active = false
	    end if
	end if
end sub

sub OnExecPerField()
    if this.Texture.Image <> temp then
       AnimationBackup()
    end if
end sub

sub OnParameterChanged(parameterName As String)
    AnimationBackup()
end sub

sub AnimationBackup()
	c = GetParameterContainer("Container")
    temp = this.Texture.Image
	System.SendCommand("#" & this.VizId  & "*ANIMATION COPY #" & c.VizId  & "*ANIMATION")
end Sub

