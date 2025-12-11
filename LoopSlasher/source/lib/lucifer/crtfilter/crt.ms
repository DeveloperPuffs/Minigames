CRT = function(size = 100,intensity = 1, speed =1)
  if not CRT_BUFFER.type or size != CRT_BUFFER_SIZE or intensity != CRT_BUFFER_INTENSITY then
    CRT_BUFFER_SIZE = size
    size *= 2
    CRT_BUFFER_INTENSITY = intensity
    CRT_BUFFER = new Image(size,size)
    CRT_BUFFER.setLinearGradient(size,size,size,size, "rgba(0,0,0,0)", "rgba(0,0,0,"+intensity+")")
    CRT_BUFFER.fillRect(0,0,size,size)
    CRT_BUFFER.setRadialGradient(size,size,size/2*3,"rgba(0,0,0,0)","rgba(0,0,0,"+intensity+")")
    for i=0 to size by 4 //spacing between lines
      CRT_BUFFER.drawLine(0,i+.5,size,i+.5)
    end
    
    CRT_BUFFER2_SIZE = size
    CRT_BUFFER2_INTENSITY = intensity
    CRT_BUFFER2 = new Image(size, size)
    CRT_BUFFER2.setRadialGradient(size/2,size/2,size/2*1.4142,"rgba(0,0,0,0)","rgba(0,0,0,"+1+")")
    CRT_BUFFER2.fillRect(0, 0, size, size)
    
  end
    screen.setPixelated(false)
    screen.drawImage(CRT_BUFFER2,0,0,screen.width,screen.height)
    screen.setPixelated(true)
    screen.setPixelated(false)
    screen.drawImage(CRT_BUFFER,0,scrool,screen.width,screen.height*4)
    screen.setPixelated(true)
    scrool -= speed
    if scrool <= -screen.height-4 then
      scrool = 0
    end
end