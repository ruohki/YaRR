'Angepasster Code von
'http://theatticlight.net/posts/Reading-a-Rotary-Encoder-from-a-Raspberry-Pi/

type encoder
	pin_a as integer
	pin_b as integer
	value as integer
	lastEncoded as integer
end type

declare sub setupencoder(byval pin_a as integer, byval pin_b as integer, callback as any ptr)
declare sub updateEncoder()

dim shared myEncoder as encoder

sub updateEncoder()

        Dim MSB as integer = digitalRead(myEncoder.pin_a)
        Dim LSB as integer = digitalRead(myEncoder.pin_b)
        
        Dim encoded as integer = (MSB shl 1) OR LSB
        Dim sum as integer = (myEncoder.lastEncoded shl 2) OR encoded
        
        if (sum = &b1101) XOR (sum = &b0100) XOR (sum = &b0010) XOR (sum = &b1011) then
            myEncoder.value += 1
        end if
        
        if (sum = &b1110) XOR (sum = &b0111) XOR (sum = &b0001) XOR (sum = &b1000) then
            myEncoder.value -= 1
        end if
        
        myEncoder.lastEncoded = encoded
  
end sub

sub setupencoder (byval pin_a as integer, byval pin_b as integer, callback as any ptr)
    dim newencoder as encoder ptr = @myEncoder
    
    newencoder->pin_a = pin_a
    newencoder->pin_b = pin_b
    newencoder->value = 0
    newencoder->lastEncoded = 0
	
    pinMode(pin_a, MODE_INPUT)
    pinMode(pin_b, MODE_INPUT)
    pullUpDnControl(pin_a, PUD_UP)
    pullUpDnControl(pin_b, PUD_UP)
	
    wiringPiISR(pin_a,INT_EDGE_BOTH, callback)
    wiringPiISR(pin_b,INT_EDGE_BOTH, callback)
end sub
