' basado en tutorial de:
' https://docs.google.com/document/pub?id=1vUneCCC18oXLglzoRcJdrMDUSh7vaO_tGDjzjOc8IhU

' puntos por dot = 10
' puntos por pill = 50
' puntos por fantasma = 100
' puntos por banana = 200
' puntos por manzana = 300
' puntos por cerezas = 400

' IA fantasmas:
'  cyan mueve en sentido horario arriba, derecha, abajo, izquierda
'  pink mueve en sentido antihorario arriba, izquerda, abajo, derecha
'  red  mueve hacia pacman 

#include <memcopy.bas>
#include <keys.bas>


' colores
#define NEGRO 0
#define AZUL 1
#define ROJO 2
#define MORADO 3
#define VERDE 4
#define CIELO 5
#define AMARILLO 6
#define BLANCO 7

'direcciones
#define DERECHA 1
#define IZQUIERDA 2
#define ARRIBA 3
#define ABAJO 4

' la pantalla del spectrum es de 32 columnas y 23 filas
' la pantalla del juego sera de 21 columnas y 23 filas (dejamos 11 columnas para menu)
'const panMaxF as ubyte = 22
'const panMaxC as ubyte = 20
#define panMaxF  22
#define panMaxC  20
#define FMSG1 7
#define FMSG2 13
#define CMSG  7
#define CVIDAS panMaxC+5
#define FVIDAS FMSG2+2
#define CPUNT  panMaxC+4
#define FPUNT FMSG1-2
#define FHIGH FMSG1+3
#define FSALIDA FMSG1+3
#define CSALIDAD panMaxC
#define CSALIDAI 0
#define FPACMAN FMSG2+4
#define CPACMAN CMSG+3
#define NVIDAS 3
#define NPILDORAS 165
#define PUNTOSDOT 10
#define PUNTOSPIL 50
#define PUNTOSFAN 100
#define PUNTOSBAN 200
#define PUNTOSMAN 300
#define PUNTOSCER 400
#define FANTASMAS 3
#define X 0
#define Y 1
#define COLORT 2
#define BRILLO 3
#define RED 	0 ' Blinky
#define PINK 	1 ' Pinky
#define CYAN 	2 ' Inky
#define ORANGE 	3 ' Clyde

' las teclas están fijas: Q, A, O, P
' TODO: que se puedan redefinir y usar joystick

' variable del sistema que apunta a los UDG
DIM UDG as uInteger AT 23675
dim vidas AS UBYTE = NVIDAS
dim pildoras as ubyte = NPILDORAS
dim puntos as uinteger = 0
dim highsc as uinteger = 0
dim anim(1) as ubyte => { 144,149 }
dim fanim as ubyte = 0
dim t as ubyte = 0
dim x, y, xv, yv as ubyte
dim i as ubyte = 1 	' indice para scroll txt
dim c as ubyte
dim k as string
dim muerto as ubyte=0
'~ dim muerteseq as ubyte = 6

' Movimientos de fantasmas
dim rutas(FANTASMAS-1,3,1) as ubyte => { _
  { {0,0}, {0,0}, {0,0}, {0,0} } , _
  { {0,-1}, {1,0}, {0,1}, {-1,0} } , _
  { {0,-1}, {-1,0}, {0,1}, {1,0} }  _
}

dim cyanmi as ubyte = 0
dim pinkmi as ubyte = 0


' Posiciones iniciales de fantasmas
' cada fantasma es un array con 4 valores: {X,Y,COLOR,BRILLO}
dim fantasmas(FANTASMAS-1,3) AS ubyte => { _
  { CMSG,   FMSG1+1, ROJO,   0 } , _
  { CMSG+6, FMSG2-1, MORADO, 1 } , _
  { CMSG+3, FMSG1,   CIELO,  0 }   _
}  

dim pantalla(panMaxF,panMaxC) as ubyte => { _
{  6,  2,  2,  2,  2,2,  2,  2,  2,  2, 15,  2,  2,  2,  2,  2,  2,  2,  2,  2,  7}, _
{  3,  0,  0,  0,  0,0,  0,  0,  0,  0,  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3}, _
{  3,  1,  8,  2,  9,0,  8,  2,  9,  0, 11,  0,  8,  2,  9,  0,  8,  2,  9,  1,  3}, _
{  3,  0,  0,  0,  0,0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3}, _
{  3,  0,  8,  2,  9,0, 10,  0,  8,  2, 15,  2,  9,  0, 10,  0,  8,  2,  9,  0,  3}, _
{  3,  0,  0,  0,  0,0,  3,  0,  0,  0,  3,  0,  0,  0,  3,  0,  0,  0,  0,  0,  3}, _
{  4,  2,  2,  2,  7,0, 13,  2,  9,255, 11,255,  8,  2, 12,  0,  6,  2,  2,  2,  5}, _
{255,255,255,255,  3,0,  3,255,255,255,255,255,255,255,  3,  0,  3,255,255,255,255}, _
{255,255,255,255,  3,0,  3,255,  6,  9, 16,  8,  7,255,  3,  0,  3,255,255,255,255}, _
{  2,  2,  2,  2,  5,0, 11,255,  3,255,255,255,  3,255, 11,  0,  4,  2,  2,  2,  2}, _
{255,255,255,255,255,0,255,255,  3,255,255,255,  3,255,255,  0,255,255,255,255,255}, _
{  2,  2,  2,  2,  7,0, 10,255,  3,255,255,255,  3,255, 10,  0,  6,  2,  2,  2,  2}, _
{255,255,255,255,  3,0,  3,255,  4,  2,  2,  2,  5,255,  3,  0,  3,255,255,255,255}, _
{255,255,255,255,  3,0,  3,255,255,255,255,255,255,255,  3,  0,  3,255,255,255,255}, _
{  6,  2,  2,  2,  5,0, 11,255,  8,  2, 15,  2,  9,255, 11,  0,  4,  2,  2,  2,  7}, _
{  3,  0,  0,  0,  0,0,  0,  0,  0,  0,  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3}, _
{  3,  0,  8,  2,  7,0,  8,  2,  9,  0, 11,  0,  8,  2,  9,  0,  6,  2,  9,  0,  3}, _
{  3,  1,  0,  0,  3,0,  0,  0,  0,  0,255,  0,  0,  0,  0,  0,  3,  0,  0,  1,  3}, _
{ 13,  2,  9,  0, 11,0, 10,  0,  8,  2, 15,  2,  9,  0, 10,  0, 11,  0,  8,  2, 12}, _
{  3,  0,  0,  0,  0,0,  3,  0,  0,  0,  3,  0,  0,  0,  3,  0,  0,  0,  0,  0,  3}, _
{  3,  0,  8,  2,  2,2, 14,  2,  9,  0, 11,  0,  8,  2, 14,  2,  2,  2,  9,  0,  3}, _
{  3,  0,  0,  0,  0,0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3}, _
{  4,  2,  2,  2,  2,2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  5} _
}
dim pantallaInicial(panMaxF,panMaxC) as ubyte => { _
{  6,  2,  2,  2,  2,2,  2,  2,  2,  2, 15,  2,  2,  2,  2,  2,  2,  2,  2,  2,  7}, _
{  3,  0,  0,  0,  0,0,  0,  0,  0,  0,  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3}, _
{  3,  1,  8,  2,  9,0,  8,  2,  9,  0, 11,  0,  8,  2,  9,  0,  8,  2,  9,  1,  3}, _
{  3,  0,  0,  0,  0,0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3}, _
{  3,  0,  8,  2,  9,0, 10,  0,  8,  2, 15,  2,  9,  0, 10,  0,  8,  2,  9,  0,  3}, _
{  3,  0,  0,  0,  0,0,  3,  0,  0,  0,  3,  0,  0,  0,  3,  0,  0,  0,  0,  0,  3}, _
{  4,  2,  2,  2,  7,0, 13,  2,  9,255, 11,255,  8,  2, 12,  0,  6,  2,  2,  2,  5}, _
{255,255,255,255,  3,0,  3,255,255,255,255,255,255,255,  3,  0,  3,255,255,255,255}, _
{255,255,255,255,  3,0,  3,255,  6,  9, 16,  8,  7,255,  3,  0,  3,255,255,255,255}, _
{  2,  2,  2,  2,  5,0, 11,255,  3,255,255,255,  3,255, 11,  0,  4,  2,  2,  2,  2}, _
{255,255,255,255,255,0,255,255,  3,255,255,255,  3,255,255,  0,255,255,255,255,255}, _
{  2,  2,  2,  2,  7,0, 10,255,  3,255,255,255,  3,255, 10,  0,  6,  2,  2,  2,  2}, _
{255,255,255,255,  3,0,  3,255,  4,  2,  2,  2,  5,255,  3,  0,  3,255,255,255,255}, _
{255,255,255,255,  3,0,  3,255,255,255,255,255,255,255,  3,  0,  3,255,255,255,255}, _
{  6,  2,  2,  2,  5,0, 11,255,  8,  2, 15,  2,  9,255, 11,  0,  4,  2,  2,  2,  7}, _
{  3,  0,  0,  0,  0,0,  0,  0,  0,  0,  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3}, _
{  3,  0,  8,  2,  7,0,  8,  2,  9,  0, 11,  0,  8,  2,  9,  0,  6,  2,  9,  0,  3}, _
{  3,  1,  0,  0,  3,0,  0,  0,  0,  0,255,  0,  0,  0,  0,  0,  3,  0,  0,  1,  3}, _
{ 13,  2,  9,  0, 11,0, 10,  0,  8,  2, 15,  2,  9,  0, 10,  0, 11,  0,  8,  2, 12}, _
{  3,  0,  0,  0,  0,0,  3,  0,  0,  0,  3,  0,  0,  0,  3,  0,  0,  0,  0,  0,  3}, _
{  3,  0,  8,  2,  2,2, 14,  2,  9,  0, 11,  0,  8,  2, 14,  2,  2,  2,  9,  0,  3}, _
{  3,  0,  0,  0,  0,0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3}, _
{  4,  2,  2,  2,  2,2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  5} _
}
 

SUB graphicsBank (bank as uByte)

 IF bank=0 then 
   UDG = @graphicsbank1
 ELSE 
   UDG = @graphicsbank2
 END IF

 RETURN

 graphicsbank1:
 ASM
 DEFB 000,000,000,024,024,000,000,000 ; A - Dot						0
 DEFB 000,024,060,126,126,060,024,000 ; B - Power Pill
 DEFB 000,255,255,000,000,255,255,000 ; C - Horizontal Wall
 DEFB 102,102,102,102,102,102,102,102 ; D - Vertical Wall			3
 DEFB 102,103,099,096,096,127,063,000 ; E - Bottom Left Corner
 DEFB 102,230,198,006,006,254,252,000 ; F - Bottom Right Corner
 DEFB 000,063,127,096,096,099,103,102 ; G - Top Left Corner			6
 DEFB 000,252,254,006,006,198,230,102 ; H - Top Right Corner		
 DEFB 000,063,127,096,096,127,063,000 ; I - Left Wall End
 DEFB 000,252,254,006,006,254,252,000 ; J - Right Wall End			9
 DEFB 000,060,126,102,102,102,102,102 ; K - Wall Top End
 DEFB 102,102,102,102,102,126,060,000 ; L - Wall Bottom End
 DEFB 102,230,198,006,006,198,230,102 ; M - T Junction left			12
 DEFB 102,103,099,096,096,099,103,102 ; N - T Junction Right
 DEFB 102,231,195,000,000,255,255,000 ; O - T Junction Up
 DEFB 000,255,255,000,000,195,231,102 ; P - T Junction Down			15
 DEFB 000,000,000,126,126,000,000,000 ; Q - Ghost Gate
 END ASM

 graphicsbank2:
 ASM
 DEFB 000,000,000,024,024,000,000,000 ; A - Dot
 DEFB 060,126,015,007,007,015,126,060 ; B - Pac-Man Left
 DEFB 060,126,240,224,224,240,126,060 ; C - Pac-Man Right
 DEFB 000,066,195,195,195,231,255,126 ; D - Pac-Man Up
 DEFB 060,126,255,231,195,195,066,000 ; E - Pac-Man Down
 DEFB 060,126,255,255,255,255,126,060 ; F - Pac-Man Closed Circle
 DEFB 060,030,031,015,015,031,030,060 ; G - Pac Man Dying Frame 2 (Left is Frame 1)
 DEFB 012,014,015,015,015,015,014,012 ; H - Pac Man Dying Frame 3 (50%)
 DEFB 000,002,007,007,007,007,002,000 ; I - Pac Man Dying Frame 4 (25%)
 DEFB 000,000,001,003,003,001,000,000 ; J - Pac Man Dying Frame 5 (12%)
 DEFB 066,036,000,000,102,000,036,066 ; K - Pac Man Dying (Pop!)
 DEFB 060,126,219,255,255,255,219,219 ; L - Ghost
 DEFB 001,003,003,006,014,062,124,224 ; M - Banana
 DEFB 002,004,030,063,063,063,063,030 ; N - Apple
 DEFB 004,012,018,054,111,111,118,032 ; O - Cherries
 END ASM

END SUB


sub pantallaMenu() 
	paper NEGRO: border NEGRO: ink NEGRO: cls
	memcopy(@menuScr,16384,6914)
	return

	menuScr:
	ASM
	incbin "pacmam-menu.bin"
	END ASM
end sub

sub pantallaJuego()
	dim f,g as ubyte
	' DIBUJAR PANTALLA
	for f = 0 to panMaxF
	  for g = 0 to panMaxC
		IF pantallaInicial(f,g) = 255 THEN continue for     
		elseIF pantallaInicial(f,g) > 1 THEN 
			print at f,g; INK AZUL; chr$(144+pantallaInicial(f,g))
		ELSEIF  pantallaInicial(f,g) = 1 THEN
			print at f,g; INK MORADO; chr$(144+pantallaInicial(f,g))	
		ELSE
			print at f,g; INK ROJO; chr$(144+pantallaInicial(f,g))
		END IF
	  next
	next
end sub

sub mostrarSprites()
	' pintar fantasmas y pacman
	print at FMSG1,CMSG; "       "
	print at FMSG2,CMSG; "       "
	print at fantasmas(RED,Y),fantasmas(RED,X); INK fantasmas(RED,COLORT); "\L"
	print at fantasmas(PINK,Y),fantasmas(PINK,X); INK fantasmas(PINK,COLORT); bright fantasmas(PINK,BRILLO); "\L"
	print at fantasmas(CYAN,Y),fantasmas(CYAN,X); INK fantasmas(CYAN,COLORT);"\L"
	print at FPACMAN,CPACMAN; ink AMARILLO; "\F"
end sub

function padnum(n as uinteger, lon as ubyte) as string
	dim s as string
	dim z as ubyte=0
	s=str(n)
	if lon>len(s) then
		z=lon-len(s)
		for i=1 to z
			s = "0" + s
		next i
	end if
	return s
end function

sub scrollTxt(msg as String)
' scoll en fila inferior (panMaxF+1) de col 0 a col panMaxC
	print at panMaxF+1,panMaxC-i; msg(1 TO i)
	i=i+1
end sub

sub mostrarTextos()
	print at FMSG1,CMSG; ink ROJO; " READY"
	print at FMSG2,CMSG; ink ROJO; "PLAYER!"

	print at FPUNT,CPUNT; ink CIELO; padnum(puntos,7) 
	print at FHIGH,CPUNT; ink CIELO; padnum(highsc,7)
end sub

sub mostrarVidas()
	' mostrar vidas
	c=CVIDAS
	for i = 1 to vidas
		print at FVIDAS,c;ink AMARILLO; paper AZUL; "\B" 'chr$(145)
		c=c+2
	next
end sub

sub muertePacman()
	dim i as ubyte
	for i=6 to 10
		print at y, x; ink AMARILLO; chr(144+i)
		pause 20
	next
	muerto=0
	'~ muerteseq=muerteseq+1
	'~ if muerteseq>10 then
		'~ muerteseq=6
		'~ muerto=0
	'~ end if
end sub

function canMove(c as ubyte, f as ubyte) as ubyte
	if (c>CSALIDAD or c<CSALIDAI) and f=FSALIDA then
		return 1
	else
		if pantalla(f,c) = 255 or pantalla(f,c)=0 or pantalla(f,c)=1 then
			return 1
		else
			return 0
		end if
	end if
end function

function moverFantasma(fantasma as ubyte, movindex as ubyte)
	dim f,c,fn,cn,i as ubyte
	dim mueve as ubyte = 1

	f=fantasmas(fantasma,Y): c=fantasmas(fantasma,X)
	fn=fantasmas(fantasma,Y)+rutas(fantasma,movindex,Y): cn=fantasmas(fantasma,X)+rutas(fantasma,movindex,X)

	' comprobar si se come a pacman
	if cn=x and fn=y then 
		muerto=1
		'~ mueve=0
		'~ return movindex
	end if

	' comprobar si hay otros fantasmas en medio que no puede atravesar
	for i=1 to FANTASMAS-1
		if fantasmas((fantasma+i) mod 3,X)=cn and fantasmas((fantasma+i) mod 3,Y)=fn then
			movindex=(movindex+1) mod 4		
			mueve=0
		end if
	next
	
	if canMove(cn,fn)=0 then
		mueve=0
	end if
	
	if mueve=1 then
	
		graphicsBank(0)
		if pantalla(f,c)=255 then
			print at f,c; " "
		else
			if pantalla(f,c)=0 then
				print at f,c; ink ROJO; chr(144+pantalla(f,c))
			ELSE
				print at f,c; ink MORADO; chr(144+pantalla(f,c))
			END IF
		end if
		graphicsBank(1)
		print at fn,cn; ink fantasmas(fantasma,COLORT); bright fantasmas(fantasma,BRILLO); "\L"
		fantasmas(fantasma,X)=cn: fantasmas(fantasma,Y)=fn
	else
		' se pasa al siguiente movimiento, pero no se mueve (print) hasta siguiente ciclo
		movindex=(movindex+1) mod 4	
	end if
print at 23,0; ink fantasmas(fantasma,COLORT); fn; ":" ; cn; "-"; movindex; "   " 	
	return movindex
end function

sub moverFantasmas()

	pinkmi=moverFantasma(PINK, pinkmi)
	cyanmi=moverFantasma(CYAN, cyanmi)
	
end sub

sub moverPacMan(dir as ubyte)
	dim f,c, sp as ubyte
	
	xv=x: yv=y

	If dir=DERECHA then
		if x=CSALIDAD and y=FSALIDA then
			x=CSALIDAI
		else
			x=x+1
		end if
		sp=144+2
	end if	
	If dir=IZQUIERDA then
		if x=CSALIDAI and y=FSALIDA then
			x=CSALIDAD
		else
			x=x-1
		end if
		sp=144+1
	end if
	If dir=ARRIBA then
		y=y-1
		sp=144+3
	end if
	If dir=ABAJO then
		y=y+1
		sp=144+4
	end if
	
	anim(0)=sp
	
	c=x : f=y
		
	if pantalla(f,c)=0 then 
		puntos=puntos+PUNTOSDOT
		pildoras=pildoras-1
	end if
	if pantalla(f,c)=1 then 
		puntos=puntos+PUNTOSPIL
		pildoras=pildoras-1
	end if

	pantalla(f,c)=255
	print at yv, xv; " "
	print at f,c; ink AMARILLO; chr(anim(fanim))
	fanim=1-fanim
	
end sub

function GameOver() as ubyte
	if pildoras=0 or vidas=0 then
		return 1
	else
		return 0
	end if
end function

sub inicializarJuego()
	dim f,g as ubyte
	puntos=0
	vidas=NVIDAS
	muerto=0
	'~ muerteseq=6
	x=CPACMAN
	y=FPACMAN
	xv=x
	yv=y
	fantasmas(RED, X)=CMSG
	fantasmas(RED, Y)=FMSG1+1
	fantasmas(RED, COLORT)=ROJO
	fantasmas(RED, BRILLO)=0
	fantasmas(PINK, X)=CMSG+6
	fantasmas(PINK, Y)=FMSG2-1
	fantasmas(PINK, COLORT)=MORADO
	fantasmas(PINK, BRILLO)=1
	fantasmas(CYAN, X)=CMSG+3
	fantasmas(CYAN, Y)=FMSG1
	fantasmas(CYAN, COLORT)=CIELO
	fantasmas(CYAN, BRILLO)=0

	for f = 0 to panMaxF
	  for g = 0 to panMaxC
		pantalla(f,g)=pantallaInicial(f,g)
	  next
	next
 	
 	graphicsBank(0)
 	pantallaMenu()
	pantallaJuego()
	pause 50
	graphicsBank(1)
	mostrarTextos()
	pause 0
	mostrarVidas()
	mostrarSprites()

end sub

sub juego()

	'CLS  ' el cls borra el menu!

	do until GameOver()=1
		'asm
		'halt
		'end asm
print at 23,7; muerto
print at 23,9; vidas

		if muerto=1 then 
			muertePacman()
			vidas=vidas-1
			mostrarVidas()		
			continue do
		end if
			
		moverFantasmas()
		
		'~ k=GetKeyScanCode()
		'~ print at panMaxF+1,7; k
		'~ 'if k=0 then continue do
		'~ if k=KEYQ then	
			'~ yv=y
			'~ y=y-1
		'~ end if
		'~ if k=KEYA then
			'~ yv=y
			'~ y=y-1
		'~ end if
		'~ if k=KEYO then
			'~ xv=x
			'~ x=x-1
		'~ end if
		'~ if k=KEYP then
			'~ xv=x
			'~ x=x+1
		'~ end if
		'~ if k=KEYSPACE then
		  '~ GameOver=1
		'~ end if
		
		k=INKEY()
		if k="q" and canMove(x,y-1)=1 then	
			moverPacMan(ARRIBA)
		end if
		if k="a" and canMove(x,y+1)=1  then
			moverPacMan(ABAJO)
		end if
		if k="o" and canMove(x-1,y)=1  then
			moverPacMan(IZQUIERDA)
		end if
		if k="p" and canMove(x+1,y)=1  then
			moverPacMan(DERECHA)		
		end if
		if k=" "  then
			exit do
		end if
		
		print at FPUNT,CPUNT; ink CIELO; padnum(puntos,7) 

		pause 10
'		beep .05,-6
		t=t+1
	loop
end sub

'******************************************
'* t    h     ee      gg  aa   m m    ee 
'* ttt  h    eeee    g  g   a m m m  eeee
'* t    hhh  e        gg  aaa m   m  e    
'*  ttt h  h  eee    ggg aaaa m   m   eee 
'******************************************

' FOREVER LOOP
do 
	inicializarJuego()
	juego()
	if puntos>highsc then 
		highsc=puntos
	end if
	pause 0
loop
